import 'package:drums/features/edit_grid/configuration.dart';
import 'package:flutter/material.dart';

class FixHeightRow extends StatelessWidget {
  const FixHeightRow({super.key, this.children = const []});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: EditGridConfiguration.noteHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
