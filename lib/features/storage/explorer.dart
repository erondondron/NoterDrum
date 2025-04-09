import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class StorageExplorerWidget extends StatelessWidget {
  const StorageExplorerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return ListView(
          children: [
            ...storage.folders.map(
              (folder) => _StorageExplorerRowWidget(
                storage: storage,
                entity: folder,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StorageExplorerRowWidget extends StatelessWidget {
  static const double height = 50;

  const _StorageExplorerRowWidget({
    required this.storage,
    required this.entity,
  });

  final Storage storage;
  final String entity;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return GestureDetector(
      onTap: () => storage.openFolder(name: entity),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Icon(Icons.folder_outlined),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  path.basenameWithoutExtension(entity),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      onTap: () => storage.removeFolder(name: entity),
                      child: Text("Remove"),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
