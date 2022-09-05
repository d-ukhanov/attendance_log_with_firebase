// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/models/group.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/observers_repository.dart';
import 'package:attendance_log_with_firebase/core/domain/repositories/groups_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/home/observer_group_list.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/restart_widget.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/custom_scaffold.dart';
import 'package:attendance_log_with_firebase/presentation/widgets/loading.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ObserversRepository observersRepository;
  late final GroupsRepository groupsRepository;

  @override
  void initState() {
    super.initState();

    observersRepository = GetIt.I.get();
    groupsRepository = GetIt.I.get();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Журнал посещаемости',
      actions: _getAppbarActionButtons(),
      isHomePage: true,
      body: StreamBuilder<List<String>>(
        stream: observersRepository.getObserverGroupIds(widget.userId),
        builder: (context, observerSnap) {
          if (observerSnap.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (observerSnap.hasData &&
              (observerSnap.data?.isNotEmpty ?? false)) {
            return StreamBuilder<List<Group>>(
              stream: groupsRepository.groupsByIds(observerSnap.data!),
              builder: (context, groupsSnap) {
                if (groupsSnap.connectionState == ConnectionState.waiting) {
                  return Loading();
                }

                return ObserverGroupsList(groupsSnap.data);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  List<Widget> _getAppbarActionButtons() {
    return [_getRefreshButton()];
  }

  Widget _getRefreshButton() {
    return TextButton.icon(
      icon: Icon(
        Icons.autorenew,
        color: ConstantsUI.colorBackground,
      ),
      label: const Text(
        'обновить',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => RestartWidget.restartApp(context),
    );
  }
}
