import 'dart:math';

import 'package:drums/features/app_bar.dart';
import 'package:drums/features/storage/explorer.dart';
import 'package:drums/features/storage/model.dart';
import 'package:drums/features/storage/setup/models.dart';
import 'package:drums/features/storage/setup/new_folder.dart';
import 'package:drums/features/storage/setup/new_groove.dart';
import 'package:drums/features/storage/setup/rename_entity.dart';
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
        var setupWidget = switch (storage.setupEntity) {
          NewFolderSetup() => NewFolderSetupWidget(
              newFolder: storage.setupEntity as NewFolderSetup,
            ),
          RenameEntitySetup() => RenameEntitySetupWidget(
            renameEntity: storage.setupEntity as RenameEntitySetup,
            storage: storage,
          ),
          _ => storage.newGroove != null ? NewGrooveSetupWidget() : null
        };

        return Row(
          children: [
            Container(
              width: width * 2 / 3,
              height: double.infinity,
              decoration: setupWidget != null
                  ? BoxDecoration(
                      color: folderColor,
                      border: Border(
                        top: BorderSide(color: borderColor, width: 1),
                        right: BorderSide(color: borderColor, width: 1),
                      ),
                    )
                  : BoxDecoration(color: blackoutColor.withValues(alpha: 0.85)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: setupPadding),
                child: setupWidget,
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
              child: StorageExplorerWidget(),
            ),
          ],
        );
      },
    );
  }
}
