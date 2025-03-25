import 'package:drums/features/actions/editing/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesEditingPanel extends StatelessWidget {
  const NotesEditingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesEditingModel>(
      builder: (BuildContext context, NotesEditingModel controller, _) {
        return Container(
          width: !controller.isActive ? 55 : null,
          height: 55,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(55)),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isActive) _NotesEditingActions(),
                _ActivationButton(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotesEditingActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Note value"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: VerticalDivider(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Stroke type"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: VerticalDivider(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}

class _ActivationButton extends StatelessWidget {
  const _ActivationButton({required this.controller});

  final NotesEditingModel controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: controller.toggle,
      child: SizedBox(
        height: 50,
        width: 50,
        child: Icon(
          Icons.edit,
          color: controller.isActive
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
    );
  }
}
