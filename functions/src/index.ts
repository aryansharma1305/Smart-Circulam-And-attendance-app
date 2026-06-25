import * as admin from "firebase-admin";

admin.initializeApp();

export { setUserRole } from "./setUserRole";
export { inviteUser } from "./inviteUser";
export { onUserCreate } from "./onUserCreate";
export {
  issueAttendanceQrToken,
  submitAttendanceQr,
} from "./attendanceQr";
export { reviewAttendanceException } from "./reviewAttendanceException";
