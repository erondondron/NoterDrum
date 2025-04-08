import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';

class NewFolderSetupWindow extends StatelessWidget {
  const NewFolderSetupWindow({super.key, required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 60),
        Text("New folder:"),
        SizedBox(height: 15),
        TextFormField(
          initialValue: storage.newFolder,
          onChanged: (value) => storage.newFolder = value,
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
                storage.explorer.createFolder(name: storage.newFolder!);
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
