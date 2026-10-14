import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      child: FilledButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
