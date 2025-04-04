import 'dart:io';

import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:drums/features/storage/model.dart';
import 'package:drums/features/storage/creation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class StorageExplorerWidget extends StatelessWidget {
  const StorageExplorerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final blackoutColor = Theme.of(context).colorScheme.secondaryContainer;
    final folderColor = Theme.of(context).colorScheme.surface;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return Row(
          children: [
            SizedBox(
              width: width * 2 / 3,
              height: double.infinity,
              child: storage.newFolderMode
                  ? StorageFolderCreationWidget()
                  : ColoredBox(color: blackoutColor.withValues(alpha: 0.8)),
            ),
            Container(
              width: width / 3,
              decoration: BoxDecoration(
                color: folderColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: ListView(
                children: [
                  ...storage.selectedFolder!.folders.map(
                    (folder) => _StorageExplorerRowWidget(
                      storage: storage,
                      entity: folder,
                    ),
                  ),
                  ...storage.selectedFolder!.grooves.map(
                    (folder) => _StorageExplorerRowWidget(
                      storage: storage,
                      entity: folder,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StorageExplorerRowWidget extends StatelessWidget {
  const _StorageExplorerRowWidget({
    required this.storage,
    required this.entity,
  });

  final Storage storage;
  final FileSystemEntity entity;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return GestureDetector(
      onTap: () => storage.openFolder(
        folderPath: path.join(
          storage.selectedFolder!.relativePath,
          path.basename(entity.path),
        ),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              entity is Directory ? Icon(Icons.folder_outlined) : _DrumIcon(),
              SizedBox(width: 10),
              Text(path.basenameWithoutExtension(entity.path)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrumIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color!;
    final theme = ColorFilter.mode(color, BlendMode.srcIn);
    return SizedBox(
      height: NoteView.height,
      width: NoteView.height,
      child: SvgPicture.asset(
        Drum.snare.icon,
        colorFilter: theme,
        fit: BoxFit.none,
      ),
    );
  }
}
