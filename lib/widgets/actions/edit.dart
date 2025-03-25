import 'package:flutter/material.dart';

class NoteEditPanel extends StatefulWidget {
  const NoteEditPanel({super.key});

  @override
  State<NoteEditPanel> createState() => _NoteEditPanelState();
}

class _NoteEditPanelState extends State<NoteEditPanel> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: !_isActive ? 55 : null,
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
            if (_isActive) ...[
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
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _isActive = !_isActive),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.edit,
                  color:
                      _isActive ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
