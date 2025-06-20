import 'package:drums/actions/editing/model.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/note_value.dart';
import 'package:drums/shared/svg_icon.dart';
import 'package:drums/shared/text_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesEditingPanel extends StatelessWidget {
  const NotesEditingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesEditingController>(
      builder: (BuildContext context, NotesEditingController controller, _) {
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
                if (controller.isActive)
                  _NotesEditingActions(controller: controller),
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
  const _NotesEditingActions({required this.controller});

  final NotesEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _NoteValuesSelector(controller: controller),
        ),
        VerticalDivider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: _StrokeTypesSelector(controller: controller),
        ),
        VerticalDivider(),
      ],
    );
  }
}

class _NoteValuesSelector extends StatelessWidget {
  const _NoteValuesSelector({required this.controller});

  final NotesEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NoteValue>(
      child: Text("Note value"),
      onSelected: (NoteValue noteValue) =>
          controller.changeSelectedNotesValues(noteValue),
      itemBuilder: (BuildContext context) {
        return controller
            .possibleNoteValues()
            .map(
              (NoteValue noteValue) => PopupMenuItem(
                value: noteValue,
                child: TextWithIcon(
                  icon: SvgIcon(asset: noteValue.icon),
                  text: Text(noteValue.name),
                ),
              ),
            )
            .toList();
      },
    );
  }
}

class _StrokeTypesSelector extends StatelessWidget {
  const _StrokeTypesSelector({required this.controller});

  final NotesEditingController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<StrokeType>(
      child: Text("Stroke type"),
      onSelected: (StrokeType strokeType) =>
          controller.changeSelectedStrokeTypes(strokeType),
      itemBuilder: (BuildContext context) {
        return controller
            .possibleStrokes()
            .map(
              (StrokeType strokeType) => PopupMenuItem(
                value: strokeType,
                child: TextWithIcon(
                  icon: SvgIcon(asset: strokeType.icon),
                  text: Text(strokeType.name),
                ),
              ),
            )
            .toList();
      },
    );
  }
}

class _ActivationButton extends StatelessWidget {
  const _ActivationButton({required this.controller});

  final NotesEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: controller.toggleActiveStatus,
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
