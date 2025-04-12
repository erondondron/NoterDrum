import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewGrooveSetupWidget extends StatefulWidget {
  const NewGrooveSetupWidget({super.key});

  @override
  State<NewGrooveSetupWidget> createState() => _NewGrooveSetupWidgetState();
}

class _NewGrooveSetupWidgetState extends State<NewGrooveSetupWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        storage.newGroove!.name = storage.getNewGrooveName();
        _controller.text = storage.newGroove!.name;
        return ListView(
          children: [
            SizedBox(height: 60),
            Text("Save your groove as:"),
            SizedBox(height: 15),
            TextFormField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: (_) => storage.newGroove!.name = _controller.text,
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
                  onPressed: storage.close,
                  child: Text("Cancel"),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await storage.saveNewGroove();
                    } on StorageEntityAlreadyExistsError {
                      if (!context.mounted) return;
                      var replace = await showDialog<bool>(
                        context: context,
                        builder: (_) => _ReplaceGrooveDialog(),
                      );
                      if (replace != true) return;
                      await storage.saveNewGroove(force: true);
                    }
                  },
                  child: Text("Accept"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ReplaceGrooveDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Replace existing groove?"),
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
