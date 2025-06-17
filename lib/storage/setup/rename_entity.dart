import 'package:drums/storage/model.dart';
import 'package:drums/storage/setup/models.dart';
import 'package:flutter/material.dart';

class RenameEntitySetupWidget extends StatefulWidget {
  const RenameEntitySetupWidget({
    super.key,
    required this.storage,
    required this.renameEntity,
  });

  final Storage storage;
  final RenameEntitySetup renameEntity;

  @override
  State<RenameEntitySetupWidget> createState() =>
      _RenameEntitySetupWidgetState();
}

class _RenameEntitySetupWidgetState extends State<RenameEntitySetupWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.renameEntity.newName;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var entity =
        widget.renameEntity.entityPath.endsWith(Storage.grooveExtension)
            ? "groove"
            : "folder";
    return ListView(
      children: [
        SizedBox(height: 60),
        Text("Rename your $entity as:"),
        SizedBox(height: 15),
        TextFormField(
          focusNode: _focusNode,
          controller: _controller,
          onChanged: (_) => widget.renameEntity.newName = _controller.text,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onTap: () {
            if (_focusNode.hasFocus) return;
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.value.text.length,
            );
          },
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: widget.storage.closeSetup,
              child: Text("Cancel"),
            ),
            SizedBox(width: 10),
            OutlinedButton(
              onPressed: () async {
                try {
                  await widget.storage.renameEntity();
                } on StorageEntityAlreadyExistsError {
                  if (!context.mounted) return;
                  var replace = await showDialog<bool>(
                    context: context,
                    builder: (_) => _ReplaceEntityDialog(entity: entity),
                  );
                  if (replace != true) return;
                  await widget.storage.renameEntity(force: true);
                }
              },
              child: Text("Accept"),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReplaceEntityDialog extends StatelessWidget {
  const _ReplaceEntityDialog({required this.entity});

  final String entity;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Replace existing $entity?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
