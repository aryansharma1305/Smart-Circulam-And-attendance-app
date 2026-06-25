import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

/**
 * inviteUser — Admin-only callable Cloud Function.
 *
 * Creates a Firebase Auth user with a temporary password, assigns their role
 * via custom claim, creates their Firestore profile, and writes an invitation
 * document so the app can show a "complete your profile" prompt on first login.
 *
 * Request body:
 *   {
 *     email: string,
 *     name: string,
 *     role: "teacher" | "student",
 *     institutionCode?: string,
 *     department?: string,
 *     section?: string,
 *   }
 */
export const inviteUser = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const callerRole = request.auth.token["role"] as string | undefined;
  if (callerRole !== "admin") {
    throw new HttpsError("permission-denied", "Only admins can invite users.");
  }

  const callerInstitutionId = request.auth.token["institutionId"] as
    | string
    | undefined;
  if (!callerInstitutionId) {
    throw new HttpsError(
      "failed-precondition",
      "Admin account has no institutionId claim."
    );
  }

  const { email, name, role, institutionCode, department, section } =
    request.data as {
      email?: string;
      name?: string;
      role?: string;
      institutionCode?: string;
      department?: string;
      section?: string;
    };

  if (!email || !name || !role) {
    throw new HttpsError(
      "invalid-argument",
      "`email`, `name`, and `role` are required."
    );
  }

  if (!["teacher", "student"].includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      "`role` must be 'teacher' or 'student'."
    );
  }

  try {
    // Create Firebase Auth user.
    const userRecord = await admin.auth().createUser({
      email,
      displayName: name,
      // Require password change on first login.
      emailVerified: false,
    });

    // Set custom claim.
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role,
      institutionId: callerInstitutionId,
    });

    const now = admin.firestore.FieldValue.serverTimestamp();

    // Create Firestore profile.
    await admin.firestore().collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      name,
      email,
      phone: "",
      institutionCode: institutionCode ?? "",
      institutionId: callerInstitutionId,
      department: department ?? "",
      section: section ?? "",
      subjects: [],
      createdAt: now,
      lastActive: now,
    });

    // Create invitation document for first-login detection.
    await admin.firestore().collection("invitations").doc(userRecord.uid).set({
      email,
      name,
      role,
      institutionId: callerInstitutionId,
      invitedBy: request.auth.uid,
      createdAt: now,
      accepted: false,
    });

    // Send password reset email so the user can set their own password.
    await admin.auth().generatePasswordResetLink(email);

    // Audit log.
    await admin.firestore().collection("audit_logs").add({
      type: "user_invited",
      targetUid: userRecord.uid,
      email,
      role,
      performedBy: request.auth.uid,
      timestamp: now,
    });

    return { success: true, uid: userRecord.uid };
  } catch (err: unknown) {
    if (
      err instanceof Error &&
      (err as NodeJS.ErrnoException).code === "auth/email-already-exists"
    ) {
      throw new HttpsError(
        "already-exists",
        "A user with that email already exists."
      );
    }
    throw new HttpsError("internal", "Failed to create user.");
  }
});
