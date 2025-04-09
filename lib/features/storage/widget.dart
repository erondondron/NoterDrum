import 'dart:math';

import 'package:drums/features/app_bar.dart';
import 'package:drums/features/storage/explorer/widget.dart';
import 'package:drums/features/storage/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:drums/features/storage/setup/new_folder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorageWindow extends StatelessWidget {
  const StorageWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final notchSize = MediaQuery.of(context).padding.left;
    final setupPadding = max(notchSize, NoterDrumAppBar.leftPadding);

    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final blackoutColor = Theme.of(context).colorScheme.secondaryContainer;
    final folderColor = Theme.of(context).colorScheme.surface;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return Row(
          children: [
            Container(
              width: width * 2 / 3,
              height: double.infinity,
              decoration: storage.setupIsActive
                  ? BoxDecoration(
                      color: folderColor,
                      border: Border(
                        top: BorderSide(color: borderColor, width: 1),
                        right: BorderSide(color: borderColor, width: 1),
                      ),
                    )
                  : BoxDecoration(color: blackoutColor.withValues(alpha: 0.8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: setupPadding),
                child: switch (storage.setupEntity) {
                  StorageNewFolder() => NewFolderSetupWindow(
                    storage: storage,
                    newFolder: storage.setupEntity as StorageNewFolder,
                  ),
                  _ => null,
                },
              ),
            ),
            Container(
              width: width / 3,
              decoration: BoxDecoration(
                color: folderColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: ChangeNotifierProvider.value(
                value: storage.explorer,
                child: StorageExplorerWidget(),
              ),
            ),
          ],
        );
      },
    );
  }
}
