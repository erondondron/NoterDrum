import 'package:drums/features/storage/explorer/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class StorageExplorerWidget extends StatelessWidget {
  const StorageExplorerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageExplorer>(
      builder: (BuildContext context, StorageExplorer explorer, _) {
        return ListView(
          children: [
            ...explorer.folders.map(
              (folder) => _StorageExplorerRowWidget(
                explorer: explorer,
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
    required this.explorer,
    required this.entity,
  });

  final StorageExplorer explorer;
  final String entity;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return GestureDetector(
      onTap: () => explorer.openFolder(name: entity),
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
                      onTap: () => explorer.removeFolder(name: entity),
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
