import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

const VALID_ROLES = ["admin", "teacher", "student", "parent", "counselor"];

/**
 * setUserRole — Admin-only callable Cloud Function.
 *
 * Sets the `role` custom claim on a Firebase Auth user.
 * This is the ONLY mechanism through which roles can be assigned.
 * The Flutter client cannot set roles directly.
 *
 * Request body:
 *   { uid: string, role: "admin" | "teacher" | "student" | "parent" | "counselor" }
 *
 * The caller must have the `admin` role in their own custom claims.
 */
export const setUserRole = onCall(async (request) => {
  // 1. Verify the caller is authenticated.
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  // 2. Verify the caller is an admin.
  const callerRole = request.auth.token["role"] as string | undefined;
  if (callerRole !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Only admins can assign roles."
    );
  }

  // 3. Validate input.
  const { uid, role } = request.data as { uid?: string; role?: string };

  if (!uid || typeof uid !== "string") {
    throw new HttpsError("invalid-argument", "`uid` is required.");
  }
  if (!role || !VALID_ROLES.includes(role)) {
    throw new HttpsError(
      "invalid-argument",
      `\`role\` must be one of: ${VALID_ROLES.join(", ")}.`
    );
  }

  // 4. Prevent self-demotion (safety guard).
  if (uid === request.auth.uid && role !== "admin") {
    throw new HttpsError(
      "invalid-argument",
      "Admins cannot demote themselves."
    );
  }

  // 5. Preserve institution scope while changing the role.
  const callerInstitutionId = request.auth.token["institutionId"] as
    | string
    | undefined;
  if (!callerInstitutionId) {
    throw new HttpsError(
      "failed-precondition",
      "Admin account has no institutionId claim."
    );
  }
  const target = await admin.auth().getUser(uid);
  if (
    target.customClaims?.["institutionId"] &&
    target.customClaims["institutionId"] !== callerInstitutionId
  ) {
    throw new HttpsError(
      "permission-denied",
      "Cannot modify a user from another institution."
    );
  }
  await admin.auth().setCustomUserClaims(uid, {
    ...target.customClaims,
    role,
    institutionId: callerInstitutionId,
  });

  // 6. Log to Firestore for audit trail.
  await admin.firestore().collection("audit_logs").add({
    type: "role_change",
    targetUid: uid,
    newRole: role,
    institutionId: callerInstitutionId,
    performedBy: request.auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, uid, role };
});
