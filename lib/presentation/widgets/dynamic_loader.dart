import 'package:flutter/material.dart';

class DynamicLoader extends StatelessWidget {
  const DynamicLoader({
    super.key,
    this.label = 'Loading',
    this.color,
    this.size = 20,
  });
  final String label;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      color: color,
      semanticsLabel: label,
    ),
  );
}
