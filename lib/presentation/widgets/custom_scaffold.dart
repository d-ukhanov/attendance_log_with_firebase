// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';

// Project imports:
import 'package:attendance_log_with_firebase/core/domain/repositories/auth_repository.dart';
import 'package:attendance_log_with_firebase/presentation/pages/wrapper.dart';
import 'package:attendance_log_with_firebase/src/constants/constants_ui.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? body;
  final bool isExitButtonRequired;
  final bool automaticallyImplyLeading;
  final bool isHomePage;

  const CustomScaffold({
    super.key,
    required this.title,
    this.actions,
    this.body,
    this.isExitButtonRequired = true,
    this.automaticallyImplyLeading = true,
    this.isHomePage = false,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold>
    with TickerProviderStateMixin {
  late final AuthRepository _authRepository;
  late AnimationController _controller;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();

    _authRepository = GetIt.I.get();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _color = ConstantsUI.colorAppBarTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsUI.colorBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AnimatedBuilder(
          animation: _color,
          builder: (_, __) => AppBar(
            title: Text(widget.title),
            backgroundColor: _color.value,
            elevation: 0.0,
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            actions: _getAppbarActionButtons(context),
          ),
        ),
      ),
      body: widget.body,
    );
  }

  List<Widget> _getAppbarActionButtons(BuildContext context) {
    return [
      if (widget.isExitButtonRequired) _getSignOutButton(context),
      if (widget.isExitButtonRequired) const SizedBox(width: 5.0),
      ...?widget.actions,
    ];
  }

  Widget _getSignOutButton(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        Icons.person,
        color: ConstantsUI.colorBackground,
      ),
      label: const Text(
        'выйти',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        await _authRepository.signOut();

        if (mounted && !widget.isHomePage) {
          _toWrapper(context);
        }
      },
    );
  }

  void _toWrapper(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageTransition(
        child: Wrapper(),
        alignment: Alignment.bottomCenter,
        curve: Curves.easeInOut,
        type: PageTransitionType.leftToRight,
      ),
      (route) => false,
    );
  }
}
