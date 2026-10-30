import 'package:flutter/material.dart';

import 'dynamic_loader.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? DynamicLoader(
              label: 'Saving attendance',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : Icon(icon, size: 22),
      label: Text(isLoading ? 'Saving…' : label),
    ),
  );
}
