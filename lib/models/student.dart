class Student {
  final String fio;
  final String studentId;

  Student({this.fio, this.studentId});
}

class AttendanceForGroupAndSubject {
  final Map<dynamic, dynamic> attendanceMap;
  final String date;

  AttendanceForGroupAndSubject({this.attendanceMap, this.date});
}
