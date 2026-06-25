# SmartStudy+ Production Roadmap

## 1. Objective

Turn the current Flutter demonstration into a secure, deployable attendance product for one educational institution first, while keeping the data model capable of supporting multiple institutions later.

The first production release covers:

- Admin-managed users, courses, sections, subjects, rooms, and enrollments.
- Student, teacher, and administrator authentication and authorization.
- Teacher-created attendance sessions with short-lived QR codes.
- Student attendance submission with server-side validation.
- Teacher roster, manual corrections, and a complete audit trail.
- Student attendance history and exception requests.
- Basic announcements, notifications, and reports.

Counsellor, parent, task coaching, goals, NFC, BLE, facial recognition, and advanced analytics are not part of the first production release.

## 2. Engineering rules

Every phase must satisfy its exit criteria before the next phase starts.

- `flutter analyze` must have no errors in production source code.
- Every completed feature must use a repository/service abstraction; screens must not access Firebase directly.
- Authorization and attendance validity must be enforced on the server, not only in Flutter.
- Demo data must be explicitly isolated behind a demo build configuration.
- New behavior must include automated tests.
- User-visible actions must have loading, empty, success, and error states.
- Sensitive actions must create audit records.
- No new feature is accepted when its navigation target is missing or its primary action is a placeholder.

## 3. Target architecture

```text
Flutter UI
  -> Riverpod controllers/providers
    -> Domain use cases
      -> Repository interfaces
        -> Firebase repositories (production)
        -> In-memory repositories (tests/demo only)

Firebase Auth
Firestore
Cloud Functions or Cloud Run validation endpoints
Firebase Storage
Firebase Cloud Messaging
Crashlytics / structured logs
```

Suggested source structure:

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    config/
    errors/
    logging/
    result/
  features/
    auth/
      data/
      domain/
      presentation/
    institutions/
    academics/
    attendance/
    exceptions/
    announcements/
    reports/
  shared/
    widgets/
```

Migration should be incremental. Existing screens can be retained temporarily, but new business logic must follow this structure.

## 4. Core data model

Use immutable typed models with consistent `fromJson` and `toJson` behavior.

### Institution

- `id`, `name`, `code`, `timezone`, `attendancePolicy`, `createdAt`, `updatedAt`

### User

- `id`, `institutionId`, `name`, `email`, `phone`, `role`, `status`, `createdAt`, `updatedAt`
- Roles for release one: `admin`, `teacher`, `student`
- Role values are assigned by privileged backend operations, never trusted from registration input.

### AcademicTerm

- `id`, `institutionId`, `name`, `startsAt`, `endsAt`, `status`

### Course and Section

- Course: `id`, `institutionId`, `code`, `name`, `departmentId`
- Section: `id`, `institutionId`, `courseId`, `termId`, `name`, `year`

### Subject and Enrollment

- Subject: `id`, `institutionId`, `code`, `name`, `creditHours`
- Enrollment: `id`, `institutionId`, `studentId`, `sectionId`, `subjectId`, `termId`, `status`
- Teaching assignment: `id`, `teacherId`, `sectionId`, `subjectId`, `termId`

### TimetableEntry

- `id`, `institutionId`, `sectionId`, `subjectId`, `teacherId`, `roomId`, `weekday`, `startsAt`, `endsAt`

### AttendanceSession

- `id`, `institutionId`, `timetableEntryId`, `teacherId`, `sectionId`, `subjectId`
- `status`, `startsAt`, `endsAt`, `lateAfter`, `closesAt`
- `locationPolicy`, `createdAt`, `closedAt`

### AttendanceRecord

- `id`, `institutionId`, `sessionId`, `studentId`
- `status`, `method`, `submittedAt`, `verifiedAt`
- `distanceMeters`, `locationAccuracyMeters`, `deviceIdHash`
- `source`, `createdBy`, `updatedAt`
- Enforce a unique logical key of `(sessionId, studentId)`.

### AttendanceException

- `id`, `institutionId`, `attendanceRecordId`, `studentId`, `reasonType`, `reason`
- `attachmentPaths`, `status`, `reviewedBy`, `reviewComment`, timestamps

### AuditEvent

- `id`, `institutionId`, `actorId`, `action`, `entityType`, `entityId`
- `before`, `after`, `reason`, `createdAt`, `requestMetadata`

## 5. Delivery phases

### Phase 0: Scope and baseline

Purpose: freeze the first-release scope and record the current condition.

Tasks:

1. Adopt this roadmap as the working scope.
2. Confirm Flutter and Firebase project ownership.
3. Select development, staging, and production Firebase projects.
4. Decide supported platforms. Recommended first target: Android and responsive web admin.
5. Record current analyzer, build, and test results in the repository.

Exit criteria:

- Release-one scope is accepted.
- Platform and environment decisions are documented.
- No credentials are committed to source control.

### Phase 1: Stabilize the Flutter project

Status: completed on 2026-06-21 for the retained demo application.

Delivered:

- Isolated 41 unreachable legacy prototype files from production analysis.
- Reduced analyzer errors from 268 to zero; 284 non-fatal legacy warnings and
  migration notices remain visible for later cleanup.
- Removed duplicate teacher routes and deferred counsellor/demo entry points.
- Protected admin routes with the existing authentication guard.
- Replaced broken admin and teacher navigation actions with real destinations
  or removed unavailable actions.
- Made role selection scroll correctly on constrained screens.
- Replaced the default counter test with onboarding and auth-guard smoke tests.
- Added reachable-source formatting checks and GitHub Actions CI.
- Verified formatting, analysis, two widget tests, web debug build, and Android
  debug APK build.
- Increased Gradle build memory and disabled unnecessary Jetifier transforms.

The quarantined files remain in the repository for reference. They must be
migrated into the Phase 2 architecture or deleted; they must not be imported
back into production without first passing analysis and tests.

Purpose: create a trustworthy development baseline without changing the product behavior.

Tasks:

1. Separate reachable production code from old prototypes and demos.
2. Remove or archive duplicate implementations:
   - Multiple QR scanners.
   - Multiple attendance services.
   - Simple/full duplicate analytics and session screens.
   - Duplicate attendance enums and models.
3. Fix syntax errors in retained source files.
4. Make dependency declarations match imported packages.
5. Fix routing:
   - Remove duplicate `/teacher/sessions`.
   - Standardize on `/counsellor` or remove counsellor routes from release one.
   - Remove dashboard links to missing routes.
   - Add typed route arguments where session/class data is required.
6. Replace the counter test with an app startup/navigation smoke test using `ProviderScope`.
7. Add CI commands for formatting, analysis, tests, and a debug build.
8. Add a build configuration that clearly labels demo mode.

Exit criteria:

- `dart format --output=none --set-exit-if-changed lib test` passes.
- `flutter analyze` reports zero errors for retained application source.
- `flutter test` passes.
- Android debug and web debug builds pass.
- Every visible dashboard action either navigates to a real screen or is removed.

### Phase 2: Domain and repository foundation

Status: audited and repaired on 2026-06-22; rechecked on 2026-06-25.
Repository interfaces, in-memory adapters, controllers, error types,
serialization tests, and Riverpod overrides compile with zero analyzer errors.

Purpose: stop screens from owning sample data and establish testable business boundaries.

Tasks:

1. Add typed domain models listed above.
2. Add repository interfaces for authentication, academics, attendance, exceptions, and announcements.
3. Add in-memory repository implementations for deterministic tests.
4. Move dashboard hard-coded lists into repositories.
5. Introduce controllers for each feature and standard UI states.
6. Define error types for authorization, validation, network, conflict, and unavailable services.
7. Add unit tests for serialization and domain rules.

Exit criteria:

- Core screens load only through providers/controllers.
- Repositories can be replaced through Riverpod overrides.
- Domain and controller tests pass without Firebase.

### Phase 3: Firebase and role authorization

Status: code-complete locally on 2026-06-22 and hardened/deployed to
development and staging Firestore on 2026-06-25. Firebase is opt-in through
`USE_FIREBASE`; the default development build uses deterministic in-memory
repositories. Auth claims now preserve `institutionId`, role routes are
guarded, Functions compile configuration is present, and Firestore rules are
institution-scoped. User profile writes now protect `role`, `status`, and
`institutionId` from client self-modification.

Firebase projects created/configured:

- `smart-circulam-dev`
- `smart-circulam-staging`

FlutterFire options were generated for development and staging. Firestore
databases were created in `nam5`, and Firestore rules/indexes were deployed to
both projects. Email/password authentication is enabled for both projects via
Firebase Auth provider config deployment. Production project creation is blocked
by the Firebase/GCP project quota on the current account. Cloud Functions
deployment is blocked until the dev/staging projects are upgraded to the Blaze
plan; local Functions TypeScript build and Firestore emulator rules tests pass.

Purpose: replace demo authentication and data storage.

Tasks:

1. Create separate Firebase configurations for development, staging, and production.
2. Add Firebase Auth, Firestore, Storage, App Check, and Crashlytics dependencies.
3. Initialize Firebase before `runApp` and expose initialization failures clearly.
4. Implement email/password authentication first; add phone OTP only if required.
5. Provision users through admin invitations/imports.
6. Assign roles through custom claims or a protected backend workflow.
7. Implement role-aware GoRouter redirects.
8. Write Firestore security rules and emulator-based rule tests.
9. Persist authentication and implement sign-out/account recovery.

Exit criteria:

- Unauthenticated users cannot open protected routes.
- Students cannot access teacher/admin data or operations.
- Teachers can only access assigned sections and sessions.
- Admin privileges cannot be self-assigned from the client.
- Emulator authorization tests pass.

### Phase 4: Academic setup and timetable

Status: local feature implementation completed on 2026-06-22.

Delivered:

- Typed departments, terms, subjects, sections, rooms, enrollments, teaching
  assignments, and timetable slots.
- In-memory and Firestore academic administration repositories.
- Institution-aware Riverpod controller and admin academic setup screen.
- Timetable collision rejection for teacher, room, and section overlaps.
- Enrollment logical-key duplicate prevention.
- CSV preview with row-level validation and idempotent email checks.
- Institution-scoped Firestore rules and required composite indexes.
- Cloud Functions institution-claim preservation.
- Unit tests for catalog isolation, collisions, enrollments, and imports.

Production deployment remains gated by the Phase 3 Firebase configuration
step described above.

Purpose: create the authoritative data required by attendance.

Tasks:

1. Admin CRUD for departments, courses, subjects, sections, rooms, and terms.
2. Teacher assignment and student enrollment.
3. Timetable CRUD with collision validation for teachers, rooms, and sections.
4. CSV import with preview, validation, row-level errors, and idempotency.
5. Teacher/student timetable views backed by Firestore.
6. Audit all administrative changes.

Exit criteria:

- An admin can configure one term from an empty database.
- Imported users and enrollments are validated before commit.
- Teachers and students see only their assigned schedules.

### Phase 5: Secure QR attendance

Status: local and backend-source foundation completed on 2026-06-25.
Deployment of callable QR Functions remains blocked until the Firebase dev and
staging projects are upgraded to Blaze.

Delivered:

- Signed QR token model and verifier using HMAC-SHA256.
- Existing Flutter QR generation now emits signed, expiring tokens instead of
  demo-only base64 payloads.
- QR validation rejects tampered payloads, expired tokens, and wrong-session
  scans.
- Attendance QR submission service validates QR token, live session state,
  enrollment, and duplicate `(sessionId, studentId)` writes before persisting.
- Callable Cloud Functions source for issuing QR tokens and submitting
  attendance (`issueAttendanceQrToken`, `submitAttendanceQr`) is implemented
  and compiles.
- Firestore composite index for backend enrollment validation was added and
  deployed to development and staging.
- Unit tests cover token success, tampering, expiry, wrong session,
  unenrolled students, and duplicate attendance.

Purpose: deliver the main product workflow.

Tasks:

1. Teacher starts a session from an assigned timetable entry.
2. Backend issues a signed token containing session ID, nonce, and short expiry.
3. QR display rotates the token at a configurable interval.
4. Student scans using a real camera package.
5. Backend validates:
   - Authentication and enrollment.
   - Active session and expiry.
   - Token signature and nonce.
   - Duplicate attendance.
   - Optional location policy and accuracy.
   - Server timestamp and late threshold.
6. Return an idempotent result for repeated submissions.
7. Teacher sees a real-time roster and closes the session.
8. Teacher may correct a record only with a reason; each change creates an audit event.

Exit criteria:

- QR replay after expiry is rejected.
- A student cannot mark attendance for another student.
- One student/session produces one authoritative record.
- Offline or repeated requests cannot create duplicates.
- Session totals reconcile with stored attendance records.

### Phase 6: Exceptions and notifications

Status: code-complete locally on 2026-06-25; Firestore rules/indexes deployed
to dev and staging on 2026-06-25. Cloud Functions source compiles, but function
deployment is still blocked until the Firebase projects are upgraded to Blaze.
Firebase Storage rules are present locally, but Storage deployment is blocked
until Firebase Storage is initialized from the console for dev and staging.

Purpose: handle legitimate corrections without informal database changes.

Tasks:

1. Student submits an exception against an attendance record.
2. Optional evidence is uploaded to protected Firebase Storage.
3. Assigned teacher reviews, approves, or rejects the request.
4. Approval updates attendance transactionally and creates an audit event.
5. Add announcements targeted by institution, course, section, or user.
6. Add FCM notifications and an in-app inbox.
7. Define notification preferences and retry behavior.

Exit criteria:

- Exception status transitions are validated server-side.
- Attachments are accessible only to authorized users.
- Approval cannot update an unrelated attendance record.
- Notification failure does not roll back the authoritative action.

Implemented foundation:

- `reviewAttendanceException` callable Function validates institution scope,
  reviewer role/session ownership, status transitions, and attendance-record
  linkage before updating anything.
- Approved exceptions update the linked attendance record and create an
  `audit_logs` event in the same Firestore transaction.
- Student inbox notifications are written after the authoritative transaction;
  notification failures are captured separately and do not roll back approval.
- Firestore rules now block client-side exception review updates and client
  audit-log writes.
- In-app notification model/repository/provider path is implemented with
  Firebase and in-memory implementations.
- Student notification UI now reads repository-backed inbox data instead of
  static mock data.
- `storage.rules` defines protected evidence and announcement attachment paths.

Remaining production steps:

- Upgrade Firebase dev/staging projects to Blaze, then deploy Functions.
- In Firebase Console, initialize Firebase Storage for
  `smart-circulam-dev` and `smart-circulam-staging`, then deploy Storage rules.
- Add real FCM/APNs/Web Push credentials before enabling push fan-out.
- Add notification preferences UI and scheduled retry processing.

### Phase 7: Reports and compliance

Purpose: provide trustworthy operational outputs.

Tasks:

1. Student attendance by subject and term.
2. Teacher session and section reports.
3. Admin institution-wide summaries.
4. Configurable shortage thresholds and at-risk lists.
5. CSV export first, PDF second.
6. Ensure all percentages define the denominator and treatment of cancelled classes.
7. Add retention settings and audit-log export.

Exit criteria:

- Report totals reconcile with raw sessions and attendance records.
- Export files contain the same filtered data shown in the UI.
- Date/time calculations use the institution timezone.

### Phase 8: Offline reliability and release hardening

Purpose: prepare for real classrooms and production distribution.

Tasks:

1. Add local persistence for read-only schedules and queued attendance submissions.
2. Use idempotency keys and explicit sync states.
3. Add retry/backoff and conflict handling.
4. Add accessibility and responsive-layout testing.
5. Add integration tests for primary role workflows.
6. Add monitoring, alerting, crash reporting, and privacy-safe logs.
7. Perform security review, load test, backup/restore test, and staged rollout.

Exit criteria:

- A queued attendance request safely synchronizes once after reconnection.
- No sensitive token or personal location is written to logs.
- Crash-free startup and primary workflows meet agreed targets.
- Release builds are signed and produced by CI.

## 6. Deferred roadmap

Evaluate only after release one is stable and used in real classes:

- Parent portal and threshold alerts.
- Counsellor referrals and appointments.
- Goal/task planning.
- BLE/NFC as secondary attendance signals.
- Advanced analytics and anomaly detection.
- Multi-institution self-service onboarding.

Do not implement facial recognition without a separate legal, privacy, consent, retention, security, and anti-spoofing project.

## 7. Immediate execution sequence

The next implementation work is Phase 1 in this order:

1. Inventory reachable routes and remove broken navigation actions.
2. Choose canonical attendance, QR, storage, and analytics implementations.
3. Move unused/broken prototype files out of production analysis scope or delete them after confirming no route depends on them.
4. Fix retained dependencies and syntax errors.
5. Replace the default test and add route smoke tests.
6. Add CI and verify Android/web builds.

Phase 1 should not connect production Firebase. Its purpose is to make the existing Flutter application structurally reliable before backend migration begins.
