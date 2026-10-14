import 'package:flutter/material.dart';

class SliverAppBarWidget extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;
  final Widget? leading;

  const SliverAppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),
      actions: actions,
      pinned: pinned,
      floating: floating,
      leading: leading,
      expandedHeight: 120,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }
}
