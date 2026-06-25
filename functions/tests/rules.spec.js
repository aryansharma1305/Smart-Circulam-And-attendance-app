const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

let testEnv;

beforeAll(async () => {
  const rulesPath = path.resolve(__dirname, '../../firestore.rules');
  const rules = fs.readFileSync(rulesPath, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: 'smart-app-test',
    firestore: {
      host: process.env.FIRESTORE_EMULATOR_HOST?.split(':')[0] ?? '127.0.0.1',
      port: Number(process.env.FIRESTORE_EMULATOR_HOST?.split(':')[1] ?? 8080),
      rules,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

afterAll(async () => {
  await testEnv?.cleanup();
});

describe('Firestore Rules', () => {
  describe('/users/{uid}', () => {
    it('allows students to read their own profile', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('student_123').set({
          institutionId: 'inst-1',
          name: 'Student',
        });
      });

      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();
      await assertSucceeds(db.collection('users').doc('student_123').get());
    });

    it('denies students from reading other profiles', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
      }).firestore();
      await assertFails(db.collection('users').doc('other_student').get());
    });

    it('allows admins to write profiles in their institution', async () => {
      const db = testEnv.authenticatedContext('admin_1', {
        role: 'admin',
        institutionId: 'inst-1',
      }).firestore();
      await assertSucceeds(
        db.collection('users').doc('student_123').set({
          institutionId: 'inst-1',
          name: 'Test',
        })
      );
    });

    it('prevents clients from setting their own role', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();
      await assertFails(
        db.collection('users').doc('student_123').set({
          institutionId: 'inst-1',
          name: 'Test',
          role: 'admin',
        })
      );
    });

    it('allows users to create only known profile fields in their institution', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(
        db.collection('users').doc('student_123').set({
          uid: 'student_123',
          email: 'student@example.com',
          institutionId: 'inst-1',
          name: 'Student',
        })
      );

      const otherDb = testEnv.authenticatedContext('student_456', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertFails(
        otherDb.collection('users').doc('student_456').set({
          uid: 'student_456',
          email: 'student456@example.com',
          institutionId: 'inst-1',
          name: 'Student',
          status: 'active',
        })
      );
    });

    it('prevents users from moving themselves to another institution', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('student_123').set({
          institutionId: 'inst-1',
          name: 'Student',
        });
      });

      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertFails(
        db.collection('users').doc('student_123').update({
          institutionId: 'inst-2',
        })
      );
    });

    it('allows users to update mutable profile fields only', async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc('student_123').set({
          institutionId: 'inst-1',
          name: 'Student',
        });
      });

      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(
        db.collection('users').doc('student_123').update({
          name: 'Updated Student',
          phone: '+15555550100',
        })
      );
    });
  });

  describe('institution-scoped academic catalog', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('departments').doc('cse').set({
          institutionId: 'inst-1',
          code: 'CSE',
          name: 'Computer Science',
        });
      });
    });

    it('allows an admin to create catalog data for their institution', async () => {
      const db = testEnv.authenticatedContext('admin_1', {
        role: 'admin',
        institutionId: 'inst-1',
      }).firestore();
      await assertSucceeds(
        db.collection('rooms').doc('r1').set({
          institutionId: 'inst-1',
          code: 'B101',
        })
      );
    });

    it('denies cross-institution reads', async () => {
      const db = testEnv.authenticatedContext('admin_2', {
        role: 'admin',
        institutionId: 'inst-2',
      }).firestore();
      await assertFails(db.collection('departments').doc('cse').get());
    });

    it('denies student catalog writes', async () => {
      const db = testEnv.authenticatedContext('student_1', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();
      await assertFails(
        db.collection('subjects').doc('math').set({
          institutionId: 'inst-1',
          code: 'MATH',
        })
      );
    });
  });

  describe('/attendance/{sessionId}/records/{studentId}', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('sessions').doc('session_1').set({
          institutionId: 'inst-1',
          teacherId: 'teacher_1',
          state: 'live',
        });
      });
    });

    it('allows students to mark attendance once', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();
      const docRef = db
        .collection('attendance')
        .doc('session_1')
        .collection('records')
        .doc('student_123');

      await assertSucceeds(
        docRef.set({
          sessionId: 'session_1',
          studentId: 'student_123',
          status: 'present',
        })
      );

      await assertFails(
        docRef.set({
          sessionId: 'session_1',
          studentId: 'student_123',
          status: 'absent',
        })
      );
    });

    it('denies students from marking attendance for others', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();
      const docRef = db
        .collection('attendance')
        .doc('session_1')
        .collection('records')
        .doc('other_student');

      await assertFails(
        docRef.set({
          sessionId: 'session_1',
          studentId: 'other_student',
          status: 'present',
        })
      );
    });

    it('denies attendance writes for another institution session', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-2',
      }).firestore();
      const docRef = db
        .collection('attendance')
        .doc('session_1')
        .collection('records')
        .doc('student_123');

      await assertFails(
        docRef.set({
          sessionId: 'session_1',
          studentId: 'student_123',
          status: 'present',
        })
      );
    });
  });

  describe('/attendance_exceptions/{id}', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('sessions').doc('session_1').set({
          institutionId: 'inst-1',
          teacherId: 'teacher_1',
          state: 'live',
        });
        await context
          .firestore()
          .collection('attendance_exceptions')
          .doc('exception_1')
          .set({
            institutionId: 'inst-1',
            session_id: 'session_1',
            student_id: 'student_123',
            teacher_id: 'teacher_1',
            status: 'pending',
            type: 'wronglyMarkedAbsent',
            reason: 'I was present.',
            requested_at: new Date().toISOString(),
          });
      });
    });

    it('allows students to submit their own institution-scoped exception', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(
        db.collection('attendance_exceptions').doc('exception_2').set({
          institutionId: 'inst-1',
          session_id: 'session_1',
          student_id: 'student_123',
          teacher_id: 'teacher_1',
          status: 'pending',
          type: 'wronglyMarkedAbsent',
          reason: 'QR scan failed.',
          requested_at: new Date().toISOString(),
          requested_status: 'present',
        })
      );
    });

    it('denies client-side exception review updates', async () => {
      const db = testEnv.authenticatedContext('teacher_1', {
        role: 'teacher',
        institutionId: 'inst-1',
      }).firestore();

      await assertFails(
        db.collection('attendance_exceptions').doc('exception_1').update({
          status: 'approved',
          reviewed_by: 'teacher_1',
        })
      );
    });

    it('allows only assigned teachers to read assigned exceptions', async () => {
      const teacherDb = testEnv.authenticatedContext('teacher_1', {
        role: 'teacher',
        institutionId: 'inst-1',
      }).firestore();
      await assertSucceeds(
        teacherDb.collection('attendance_exceptions').doc('exception_1').get()
      );

      const otherTeacherDb = testEnv.authenticatedContext('teacher_2', {
        role: 'teacher',
        institutionId: 'inst-1',
      }).firestore();
      await assertFails(
        otherTeacherDb.collection('attendance_exceptions').doc('exception_1').get()
      );
    });
  });

  describe('/announcements/{id}', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('announcements').doc('a1').set({
          institutionId: 'inst-1',
          senderId: 'teacher_1',
          title: 'Exam',
          message: 'Midterm tomorrow',
          readBy: [],
        });
      });
    });

    it('allows sender to create an institution-scoped announcement', async () => {
      const db = testEnv.authenticatedContext('teacher_1', {
        role: 'teacher',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(
        db.collection('announcements').doc('a2').set({
          institutionId: 'inst-1',
          senderId: 'teacher_1',
          title: 'Class update',
          message: 'Lab moved online',
          readBy: [],
        })
      );
    });

    it('denies cross-institution announcement reads', async () => {
      const db = testEnv.authenticatedContext('student_2', {
        role: 'student',
        institutionId: 'inst-2',
      }).firestore();

      await assertFails(db.collection('announcements').doc('a1').get());
    });
  });

  describe('/notifications/{id}', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('notifications').doc('n1').set({
          institutionId: 'inst-1',
          recipientId: 'student_123',
          title: 'Exception reviewed',
          message: 'Approved',
          type: 'exception',
          createdAt: new Date(),
          readAt: null,
        });
      });
    });

    it('allows users to read and mark their own notification as read', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(db.collection('notifications').doc('n1').get());
      await assertSucceeds(
        db.collection('notifications').doc('n1').update({
          readAt: new Date(),
        })
      );
    });

    it('denies users from changing notification content', async () => {
      const db = testEnv.authenticatedContext('student_123', {
        role: 'student',
        institutionId: 'inst-1',
      }).firestore();

      await assertFails(
        db.collection('notifications').doc('n1').update({
          title: 'Tampered',
        })
      );
    });
  });

  describe('/audit_logs/{id}', () => {
    beforeEach(async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('audit_logs').doc('log_1').set({
          institutionId: 'inst-1',
          type: 'attendance_exception_reviewed',
        });
      });
    });

    it('allows admins to read audit logs for their institution', async () => {
      const db = testEnv.authenticatedContext('admin_1', {
        role: 'admin',
        institutionId: 'inst-1',
      }).firestore();

      await assertSucceeds(db.collection('audit_logs').doc('log_1').get());
    });

    it('denies client writes to audit logs', async () => {
      const db = testEnv.authenticatedContext('admin_1', {
        role: 'admin',
        institutionId: 'inst-1',
      }).firestore();

      await assertFails(
        db.collection('audit_logs').doc('log_2').set({
          institutionId: 'inst-1',
          type: 'tamper',
        })
      );
    });
  });
});
