mixin ConstantsFirebase {
  //Monitors collection
  static const monitorsCollection = 'monitors';
  static const monitorsFieldMonitorId = 'monitor_id';
  static const monitorsFieldGroupsId = 'groups_id';
  static const monitorsFieldFIO = 'fio';

  //Groups collection
  static const groupsCollection = 'groups';
  static const groupsFieldGroupId = 'group_id';
  static const groupsFieldGroupName = 'group_name';

  //Students collection
  static const studentsCollection = 'students';
  static const studentsFieldStudentId = 'student_id';
  static const studentsFieldFIO = 'fio';
  static const studentsFieldGroupId = 'group_id';

  //Subjects collection
  static const subjectsCollection = 'subjects';
  static const subjectsFieldGroupsId = 'groups_id';
  static const subjectsFieldSubjectName = 'subject_name';
  static const subjectsFieldSubjectId = 'subject_id';

  //Attendance collection
  static const attendanceCollection = 'attendance';
  static const attendanceFieldGroupId = 'group_id';
  static const attendanceFieldSubjectId = 'subject_id';
  static const attendanceFieldStudentsAttendance = 'students_attendance';
  static const attendanceFieldDate = 'date';
}
