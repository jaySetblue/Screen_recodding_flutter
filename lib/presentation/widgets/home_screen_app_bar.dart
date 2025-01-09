import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreenAppBar extends ConsumerStatefulWidget {
  const HomeScreenAppBar({super.key});

  @override
  ConsumerState<HomeScreenAppBar> createState() => _HomeScreenAppBarState();
}

class _HomeScreenAppBarState extends ConsumerState<HomeScreenAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar();
  }
}
