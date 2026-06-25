import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const FINAL_STATUSES = new Set(["approved", "rejected"]);
const REVIEWABLE_STATUSES = new Set(["pending", "underReview"]);
const ALLOWED_ATTENDANCE_STATUSES = new Set([
  "present",
  "late",
  "absent",
  "leave",
]);

function requireAuth(request: {
  auth?: { token: admin.auth.DecodedIdToken; uid: string };
}): { institutionId: string; role: string; uid: string } {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const institutionId = request.auth.token["institutionId"] as
    | string
    | undefined;
  const role = request.auth.token["role"] as string | undefined;
  if (!institutionId) {
    throw new HttpsError(
      "failed-precondition",
      "Account has no institutionId claim."
    );
  }
  if (role !== "teacher" && role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only teachers/admins can review attendance exceptions."
    );
  }

  return { institutionId, role, uid: request.auth.uid };
}

function assertTransition(current: string, next: string): void {
  if (!REVIEWABLE_STATUSES.has(current)) {
    throw new HttpsError(
      "failed-precondition",
      "Only pending or under-review exceptions can be reviewed."
    );
  }
  if (!FINAL_STATUSES.has(next) && next !== "underReview") {
    throw new HttpsError(
      "invalid-argument",
      "`status` must be underReview, approved, or rejected."
    );
  }
  if (current === "underReview" && next === "underReview") {
    throw new HttpsError(
      "failed-precondition",
      "Exception is already under review."
    );
  }
}

export const reviewAttendanceException = onCall(async (request) => {
  const caller = requireAuth(request);
  const exceptionId = request.data?.exceptionId as string | undefined;
  const nextStatus = request.data?.status as string | undefined;
  const comments = request.data?.comments as string | undefined;

  if (!exceptionId || !nextStatus) {
    throw new HttpsError(
      "invalid-argument",
      "`exceptionId` and `status` are required."
    );
  }

  const db = admin.firestore();
  const exceptionRef = db.collection("attendance_exceptions").doc(exceptionId);

  const result = await db.runTransaction(async (tx) => {
    const exceptionSnap = await tx.get(exceptionRef);
    if (!exceptionSnap.exists) {
      throw new HttpsError("not-found", "Exception request not found.");
    }

    const exception = exceptionSnap.data()!;
    if (exception.institutionId !== caller.institutionId) {
      throw new HttpsError("permission-denied", "Wrong institution.");
    }

    const currentStatus = exception.status as string;
    assertTransition(currentStatus, nextStatus);

    const sessionId = exception.session_id as string | undefined;
    const studentId = exception.student_id as string | undefined;
    if (!sessionId || !studentId) {
      throw new HttpsError(
        "failed-precondition",
        "Exception is missing session/student linkage."
      );
    }

    const sessionRef = db.collection("sessions").doc(sessionId);
    const sessionSnap = await tx.get(sessionRef);
    if (!sessionSnap.exists) {
      throw new HttpsError("not-found", "Linked attendance session not found.");
    }
    const session = sessionSnap.data()!;
    if (session.institutionId !== caller.institutionId) {
      throw new HttpsError("permission-denied", "Wrong session institution.");
    }
    if (caller.role === "teacher" && session.teacherId !== caller.uid) {
      throw new HttpsError(
        "permission-denied",
        "Teachers can review only their own session exceptions."
      );
    }

    let attendanceAfter: Record<string, unknown> | null = null;
    const attendanceRef = db
      .collection("attendance")
      .doc(sessionId)
      .collection("records")
      .doc(studentId);

    if (nextStatus === "approved") {
      const requestedStatus = exception.requested_status as string | undefined;
      if (
        !requestedStatus ||
        !ALLOWED_ATTENDANCE_STATUSES.has(requestedStatus)
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Approved exceptions require a valid requested_status."
        );
      }

      const attendanceSnap = await tx.get(attendanceRef);
      if (!attendanceSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Linked attendance record does not exist."
        );
      }

      const attendance = attendanceSnap.data()!;
      if (
        attendance.sessionId !== sessionId ||
        attendance.studentId !== studentId ||
        attendance.institutionId !== caller.institutionId
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Exception does not match the attendance record."
        );
      }

      tx.update(attendanceRef, {
        status: requestedStatus,
        method: "manual",
        correctedBy: caller.uid,
        correctedAt: admin.firestore.FieldValue.serverTimestamp(),
        correctionReason: comments ?? exception.reason ?? "",
        exceptionId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      attendanceAfter = {
        ...attendance,
        status: requestedStatus,
        method: "manual",
      };
    }

    tx.update(exceptionRef, {
      status: nextStatus,
      reviewed_at: admin.firestore.FieldValue.serverTimestamp(),
      reviewed_by: caller.uid,
      reviewer_comments: comments ?? "",
    });

    const auditRef = db.collection("audit_logs").doc();
    tx.set(auditRef, {
      type: "attendance_exception_reviewed",
      institutionId: caller.institutionId,
      exceptionId,
      sessionId,
      studentId,
      statusBefore: currentStatus,
      statusAfter: nextStatus,
      attendanceAfter,
      performedBy: caller.uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      exception: {
        ...exception,
        id: exceptionId,
        status: nextStatus,
        reviewed_by: caller.uid,
        reviewer_comments: comments ?? "",
      },
      studentId,
    };
  });

  try {
    await db.collection("notifications").add({
      institutionId: caller.institutionId,
      recipientId: result.studentId,
      title: "Attendance exception reviewed",
      message:
        nextStatus === "approved"
          ? "Your attendance exception request was approved."
          : nextStatus === "rejected"
            ? "Your attendance exception request was rejected."
            : "Your attendance exception request is under review.",
      type: "exception",
      referenceType: "attendance_exception",
      referenceId: exceptionId,
      actionRoute: "/student/ledger",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readAt: null,
      metadata: {
        status: nextStatus,
      },
    });
  } catch (err) {
    await db.collection("notification_failures").add({
      institutionId: caller.institutionId,
      recipientId: result.studentId,
      referenceType: "attendance_exception",
      referenceId: exceptionId,
      error: err instanceof Error ? err.message : String(err),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return {
    success: true,
    exception: result.exception,
  };
});
