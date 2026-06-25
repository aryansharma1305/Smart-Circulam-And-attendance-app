import { createHmac, randomBytes, timingSafeEqual } from "crypto";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const TOKEN_PREFIX = "ssaqr";
const TOKEN_VERSION = 1;
const TOKEN_TTL_MS = 30_000;

type Claims = {
  expiresAtMs: number;
  issuedAtMs: number;
  nonce: string;
  sessionId: string;
  teacherId: string;
  timetableEntryId: string;
  version: number;
};

function signingSecret(): string {
  const secret = process.env.QR_SIGNING_SECRET;
  if (!secret) {
    throw new HttpsError(
      "failed-precondition",
      "QR_SIGNING_SECRET is not configured."
    );
  }
  return secret;
}

function canonicalJson(claims: Claims): string {
  return JSON.stringify({
    expiresAtMs: claims.expiresAtMs,
    issuedAtMs: claims.issuedAtMs,
    nonce: claims.nonce,
    sessionId: claims.sessionId,
    teacherId: claims.teacherId,
    timetableEntryId: claims.timetableEntryId,
    version: claims.version,
  });
}

function encodeClaims(claims: Claims): string {
  return Buffer.from(canonicalJson(claims), "utf8").toString("base64url");
}

function signPayload(payload: string): string {
  return createHmac("sha256", signingSecret())
    .update(payload)
    .digest("base64url");
}

function issueToken(claims: Claims): string {
  const payload = encodeClaims(claims);
  return `${TOKEN_PREFIX}.${TOKEN_VERSION}.${payload}.${signPayload(payload)}`;
}

function verifyToken(rawToken: string, nowMs: number): Claims {
  const parts = rawToken.split(".");
  if (parts.length !== 4 || parts[0] !== TOKEN_PREFIX) {
    throw new HttpsError("invalid-argument", "Invalid QR token format.");
  }
  if (Number(parts[1]) !== TOKEN_VERSION) {
    throw new HttpsError("invalid-argument", "Unsupported QR token version.");
  }

  const payload = parts[2];
  const signature = parts[3];
  const expected = signPayload(payload);
  const signatureBytes = Buffer.from(signature);
  const expectedBytes = Buffer.from(expected);
  if (
    signatureBytes.length !== expectedBytes.length ||
    !timingSafeEqual(signatureBytes, expectedBytes)
  ) {
    throw new HttpsError("permission-denied", "Invalid QR token signature.");
  }

  let claims: Claims;
  try {
    claims = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
  } catch {
    throw new HttpsError("invalid-argument", "Invalid QR token payload.");
  }

  if (
    claims.version !== TOKEN_VERSION ||
    !claims.sessionId ||
    !claims.teacherId ||
    !claims.nonce ||
    !claims.issuedAtMs ||
    !claims.expiresAtMs
  ) {
    throw new HttpsError("invalid-argument", "QR token is missing claims.");
  }
  if (nowMs >= claims.expiresAtMs) {
    throw new HttpsError("deadline-exceeded", "QR token has expired.");
  }
  if (claims.issuedAtMs > nowMs + 5_000) {
    throw new HttpsError("invalid-argument", "QR token was issued in future.");
  }

  return claims;
}

function requireInstitution(request: {
  auth?: { token: admin.auth.DecodedIdToken; uid: string };
}): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }
  const institutionId = request.auth.token["institutionId"] as
    | string
    | undefined;
  if (!institutionId) {
    throw new HttpsError(
      "failed-precondition",
      "Account has no institutionId claim."
    );
  }
  return institutionId;
}

export const issueAttendanceQrToken = onCall(async (request) => {
  const institutionId = requireInstitution(request);
  const role = request.auth!.token["role"];
  if (role !== "teacher" && role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only teachers/admins can issue attendance QR tokens."
    );
  }

  const sessionId = request.data?.sessionId as string | undefined;
  if (!sessionId) {
    throw new HttpsError("invalid-argument", "`sessionId` is required.");
  }

  const sessionRef = admin.firestore().collection("sessions").doc(sessionId);
  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) {
    throw new HttpsError("not-found", "Attendance session not found.");
  }
  const session = sessionSnap.data()!;
  if (session.institutionId !== institutionId) {
    throw new HttpsError("permission-denied", "Wrong institution.");
  }
  if (session.state !== "live") {
    throw new HttpsError("failed-precondition", "Session is not live.");
  }
  if (role === "teacher" && session.teacherId !== request.auth!.uid) {
    throw new HttpsError(
      "permission-denied",
      "Teachers can issue QR only for their own sessions."
    );
  }

  const issuedAtMs = Date.now();
  const token = issueToken({
    expiresAtMs: issuedAtMs + TOKEN_TTL_MS,
    issuedAtMs,
    nonce: randomBytes(16).toString("base64url"),
    sessionId,
    teacherId: session.teacherId as string,
    timetableEntryId: (session.timetableEntryId ??
      session.timetableId ??
      "") as string,
    version: TOKEN_VERSION,
  });

  return {
    token,
    expiresAtMs: issuedAtMs + TOKEN_TTL_MS,
    rotationSeconds: TOKEN_TTL_MS / 1000,
  };
});

export const submitAttendanceQr = onCall(async (request) => {
  const institutionId = requireInstitution(request);
  const role = request.auth!.token["role"];
  if (role !== "student") {
    throw new HttpsError(
      "permission-denied",
      "Only students can submit QR attendance."
    );
  }

  const token = request.data?.token as string | undefined;
  if (!token) {
    throw new HttpsError("invalid-argument", "`token` is required.");
  }

  const claims = verifyToken(token, Date.now());
  const sessionRef = admin.firestore().collection("sessions").doc(claims.sessionId);
  const sessionSnap = await sessionRef.get();
  if (!sessionSnap.exists) {
    throw new HttpsError("not-found", "Attendance session not found.");
  }
  const session = sessionSnap.data()!;
  if (session.institutionId !== institutionId || session.state !== "live") {
    throw new HttpsError(
      "permission-denied",
      "Session is not available for this student."
    );
  }

  const studentId = request.auth!.uid;
  if (!session.sectionId || !session.subjectId || !session.termId) {
    throw new HttpsError(
      "failed-precondition",
      "Session is missing section/subject/term enrollment metadata."
    );
  }

  const enrollment = await admin
    .firestore()
    .collection("enrollments")
    .where("institutionId", "==", institutionId)
    .where("studentId", "==", studentId)
    .where("sectionId", "==", session.sectionId)
    .where("subjectId", "==", session.subjectId)
    .where("termId", "==", session.termId)
    .where("status", "==", "active")
    .limit(1)
    .get();
  if (enrollment.empty) {
    throw new HttpsError(
      "permission-denied",
      "Student is not enrolled in this session."
    );
  }

  const recordRef = admin
    .firestore()
    .collection("attendance")
    .doc(claims.sessionId)
    .collection("records")
    .doc(studentId);

  const result = await admin.firestore().runTransaction(async (tx) => {
    const existing = await tx.get(recordRef);
    if (existing.exists) {
      return { alreadyMarked: true };
    }

    tx.set(recordRef, {
      sessionId: claims.sessionId,
      studentId,
      institutionId,
      status: "present",
      method: "qr",
      tokenNonce: claims.nonce,
      deviceHash: request.data?.deviceHash ?? "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { alreadyMarked: false };
  });

  return {
    success: true,
    sessionId: claims.sessionId,
    studentId,
    ...result,
  };
});
