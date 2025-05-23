import 'package:drums/features/edit_grid/note.dart';
import 'package:flutter/material.dart';

class FixHeightRow extends StatelessWidget {
  const FixHeightRow({super.key, this.children = const []});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NoteView.height,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
