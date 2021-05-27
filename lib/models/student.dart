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

class StudentStates {
  final String typeState;
  final int countStates;
  final color;

  StudentStates(this.typeState, this.countStates, this.color);
}