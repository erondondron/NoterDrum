import 'package:drums/features/actions/editing/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class NotesSelector extends StatelessWidget {
  const NotesSelector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesEditingModel>(
      builder: (BuildContext context, NotesEditingModel controller, _) {
        return Listener(
          onPointerDown: controller.isActive ? _onPointerDown : null,
          onPointerUp: controller.isActive ? _onPointerUp : null,
          child: child,
        );
      },
    );
  }

  void _onPointerDown(PointerEvent event) {}

  void _onPointerUp(PointerEvent event) {}
}
