import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log_with_firebase/models/group.dart';
import 'package:attendance_log_with_firebase/screens/home/group_tile.dart';

class MonitorGroupList extends StatefulWidget {
  @override
  _MonitorGroupListState createState() => _MonitorGroupListState();
}

class _MonitorGroupListState extends State<MonitorGroupList> {
  @override
  Widget build(BuildContext context) {
    final monitorGroups = Provider.of<List<Group>>(context) ?? [];

    return ListView.separated(
      itemCount: monitorGroups.length,
      itemBuilder: (context, index) {
        return GroupTile(group: monitorGroups[index]);
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
