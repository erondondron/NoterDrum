import 'package:drums/storage/model.dart';
import 'package:drums/storage/setup/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class MoveEntitySetupWidget extends StatefulWidget {
  const MoveEntitySetupWidget({super.key});

  @override
  State<MoveEntitySetupWidget> createState() => _MoveEntitySetupWidgetState();
}

class _MoveEntitySetupWidgetState extends State<MoveEntitySetupWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        var primaryColor = Theme.of(context).colorScheme.primary;

        var setupEntity = storage.setupEntity as MoveEntitySetup;
        setupEntity.newPath = path.join(
          storage.relativePath,
          path.basename(setupEntity.entityPath),
        );

        var entityName = path.basenameWithoutExtension(setupEntity.entityPath);
        var entityType =
            path.extension(setupEntity.entityPath) == Storage.grooveExtension
                ? "groove"
                : "folder";

        var fromDirectory =
            path.dirname(setupEntity.entityPath).replaceAll("/", " / ");
        var toDirectory =
            path.dirname(setupEntity.newPath).replaceAll("/", " / ");

        return ListView(
          children: [
            SizedBox(height: 60),
            Text.rich(
              TextSpan(text: "Move your $entityType ", children: [
                TextSpan(
                  text: entityName,
                  style: TextStyle(color: primaryColor),
                )
              ]),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text.rich(
                maxLines: null,
                TextSpan(text: "from: ", children: [
                  TextSpan(
                    text: fromDirectory,
                    style: TextStyle(color: primaryColor),
                  )
                ]),
              )
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.only(left: 25),
              child: Text.rich(
                maxLines: null,
                TextSpan(text: "to: ", children: [
                  TextSpan(
                    text: toDirectory,
                    style: TextStyle(color: primaryColor),
                  )
                ]),
              ),
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
                    try {
                      await storage.moveEntity();
                    } on StorageEntityAlreadyExistsError {
                      if (!context.mounted) return;
                      var replace = await showDialog<bool>(
                        context: context,
                        builder: (_) =>
                            _ReplaceEntityDialog(entity: entityType),
                      );
                      if (replace != true) return;
                      await storage.moveEntity(force: true);
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
