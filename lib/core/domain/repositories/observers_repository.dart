// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ObserversRepository {
  Stream<QuerySnapshot> observerFromUserUid(String uid);

  Stream<List<String>> getObserverGroupIds(String uid);
}
