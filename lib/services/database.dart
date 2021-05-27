import 'package:attendance_log_with_firebase/models/subject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/models/student.dart';

class DatabaseService {
  final String uid;
  final String groupId;
  final String subjectId;

  DatabaseService({this.uid, this.groupId, this.subjectId});

  final CollectionReference attendanceCollection =
      Firestore.instance.collection('attendance');

  //Create or update an existing document in firebase with student attendance data for a specific lesson
  Future updateAttendanceForStudent(date, String groupId, String subjectId,
      {String studentId = " ", String state = "", String changeDate}) async {
    await attendanceCollection
        .where('group_id', isEqualTo: groupId)
        .where('subject_id', isEqualTo: subjectId)
        .where('date', isEqualTo: date)
        .limit(1)
        .getDocuments()
        .then((event) {
      if (event.documents.isNotEmpty) {
        String documentId =
            event.documents.first.documentID; //if it is a single document
        try {
          if (changeDate != null)
            return attendanceCollection.document(documentId).updateData({
              'date': changeDate,
            });
          else
            return attendanceCollection.document(documentId).updateData({
              'student_id.$studentId': "$state",
            });
        } on Exception catch (e) {
          print(e);
        }
      } else {
        return attendanceCollection.document().setData({
          'date': date,
          'group_id': groupId,
          'subject_id': subjectId,
          'student_id': {studentId: state}
        });
      }
    }).catchError((e) => print(e));
  }

  //Delete document in firebase with student attendance data for a specific lesson
  Future deleteAttendanceForStudent(
      date, String groupId, String subjectId) async {
    await attendanceCollection
        .where('group_id', isEqualTo: groupId)
        .where('subject_id', isEqualTo: subjectId)
        .where('date', isEqualTo: date)
        .limit(1)
        .getDocuments()
        .then((event) {
      if (event.documents.isNotEmpty) {
        String documentId =
            event.documents.first.documentID; //if it is a single document
        try {
          return attendanceCollection.document(documentId).delete();
        } on Exception catch (e) {
          print(e);
        }
      }
    });
  }

  List<Group> _groupListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Group(
        name: doc.data['group_name'].toString() ?? '',
        groupId: doc.data['group_id'].toString() ?? '',
      );
    }).toList();
  }

  List<Subject> _subjectListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Subject(
        name: doc.data['subject_name'].toString() ?? '',
        uid: doc.data['subject_id'].toString() ?? '',
      );
    }).toList();
  }

  List<Student> _studentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Student(
        fio: doc.data['fio'].toString() ?? '',
        studentId: doc.data['student_id'].toString() ?? '',
      );
    }).toList();
  }

  List<AttendanceForGroupAndSubject> _attendanceFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return AttendanceForGroupAndSubject(
        attendanceMap: doc["student_id"] ?? {"": ""},
        date: doc['date'] ?? '',
      );
    }).toList();
  }

  static var groupIdArray = [];

  //Reading data from different collections in firebase

  Stream<QuerySnapshot> get monitor {
    Query monitorsCollection = Firestore.instance
        .collection('monitors')
        .where('monitor_id', isEqualTo: uid);
    return monitorsCollection.snapshots();
  }

  Stream<List<Group>> get monitors {
    monitor.listen((snap) {
      snap.documents.forEach((element) {
        for (var id in element.data['groups_id']) {
          groupIdArray.add(id);
        }
      });
    });
    Query groupsCollection = Firestore.instance
        .collection('groups')
        .where('group_id', whereIn: groupIdArray.toList() ?? '');
    groupIdArray.clear();
    return groupsCollection.snapshots().map(_groupListFromSnapshot);
  }

  Stream<List<Subject>> get subjects {
    final Query subjectsCollection = Firestore.instance
        .collection('subjects')
        .where('groups_id', arrayContainsAny: [groupId]);
    return subjectsCollection.snapshots().map(_subjectListFromSnapshot);
  }

  Stream<List<Student>> get students {
    final Query subjectsCollection = Firestore.instance
        .collection('students')
        .where('group_id', whereIn: [groupId]);
    return subjectsCollection.snapshots().map(_studentListFromSnapshot);
  }

  Stream<List<AttendanceForGroupAndSubject>> get attendance {
    var attendanceForGroupAndSubject = attendanceCollection
        .where('group_id', isEqualTo: groupId)
        .where('subject_id', isEqualTo: subjectId);
    return attendanceForGroupAndSubject
        .snapshots()
        .map(_attendanceFromSnapshot);
  }
}