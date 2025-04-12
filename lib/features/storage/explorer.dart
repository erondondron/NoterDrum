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
            ...storage.grooves.map(
              (groove) => _StorageExplorerRowWidget(
                storage: storage,
                entity: groove,
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
    var isFile = entity.endsWith(Storage.grooveExtension);

    return GestureDetector(
      onTap: isFile
          ? () => storage.openGroove(name: entity)
          : () => storage.openFolder(name: entity),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Icon(isFile ? Icons.queue_music_outlined : Icons.folder_outlined),
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
                      onTap: () => storage.setupRenameEntity(name: entity),
                      child: Text("Rename"),
                    ),
                    PopupMenuItem(
                      onTap: () => storage.setupMoveEntity(name: entity),
                      child: Text("Move"),
                    ),
                    PopupMenuItem(
                      onTap: () => storage.removeFileSystemEntity(name: entity),
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
