import 'package:drums/features/storage/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:flutter/material.dart';

class NewFolderSetupWindow extends StatelessWidget {
  const NewFolderSetupWindow({
    super.key,
    required this.storage,
    required this.newFolder,
  });

  final Storage storage;
  final StorageNewFolder newFolder;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 60),
        Text("New folder:"),
        SizedBox(height: 15),
        TextFormField(
          initialValue: newFolder.name,
          onChanged: (value) => newFolder.name = value,
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
              onPressed: () async {
                storage.explorer.createFolder(name: newFolder.name);
                storage.closeSetup();
              },
              child: Text("Accept"),
            ),
          ],
        ),
      ],
    );
  }
}
