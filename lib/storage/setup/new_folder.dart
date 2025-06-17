import 'package:drums/storage/model.dart';
import 'package:drums/storage/setup/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewFolderSetupWidget extends StatefulWidget {
  const NewFolderSetupWidget({super.key, required this.newFolder});

  final NewFolderSetup newFolder;

  @override
  State<StatefulWidget> createState() => _NewFolderSetupWidgetState();
}

class _NewFolderSetupWidgetState extends State<NewFolderSetupWidget> {
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
        widget.newFolder.name = storage.getNewFolderName();
        _controller.text = widget.newFolder.name;
        return ListView(
          children: [
            SizedBox(height: 60),
            Text("Save your folder as:"),
            SizedBox(height: 15),
            TextFormField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: (_) => widget.newFolder.name = _controller.text,
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
                  onPressed: storage.closeSetup,
                  child: Text("Cancel"),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: storage.saveNewFolder,
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
