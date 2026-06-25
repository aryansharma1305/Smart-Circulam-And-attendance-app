import { auth } from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * onUserCreate — Auth trigger.
 *
 * Fires whenever a new Firebase Auth user is created (including via the
 * inviteUser function or directly in the Firebase Console).
 *
 * Creates the `/users/{uid}` Firestore document if it does not already exist.
 * This is a safety net; inviteUser already creates the document for invited
 * users, so this function uses `set(..., { merge: true })` to avoid
 * overwriting existing data.
 */
export const onUserCreate = auth.user().onCreate(async (user) => {
  const now = admin.firestore.FieldValue.serverTimestamp();

  await admin
    .firestore()
    .collection("users")
    .doc(user.uid)
    .set(
      {
        uid: user.uid,
        name: user.displayName ?? "",
        email: user.email ?? "",
        phone: user.phoneNumber ?? "",
        photoUrl: user.photoURL ?? "",
        createdAt: now,
        lastActive: now,
        // Role is intentionally NOT set here — it comes from custom claims
        // via setUserRole or inviteUser only.
      },
      { merge: true } // don't overwrite data written by inviteUser
    );
});
