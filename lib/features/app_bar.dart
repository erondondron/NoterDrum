import 'dart:math';

import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoterDrumAppBar extends StatelessWidget {
  static const double height = 60;
  static const double leftPadding = 80;
  static const double rightPadding = 25;
  static const double buttonSize = 30;

  const NoterDrumAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var notchSize = MediaQuery.of(context).padding.left;
    var padding = max(notchSize, leftPadding) - notchSize;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return PreferredSize(
          preferredSize: Size.fromHeight(height),
          child: AppBar(
            titleSpacing: padding,
            title: Text(
              storage.explorer.isActive
                  ? storage.explorer.displayedPath
                  : storage.selectedGroove.name,
            ),
            actions: [
              _ReturnBackButton(storage: storage),
              _NewFolderButton(storage: storage),
              _SaveGrooveButton(storage: storage),
              _ExplorerButton(storage: storage),
              _SettingsButton(storage: storage),
              SizedBox(width: rightPadding),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).colorScheme.onSecondaryContainer;

    return SizedBox(
      height: NoterDrumAppBar.height,
      width: NoterDrumAppBar.height,
      child: Icon(
        Icons.settings_outlined,
        size: NoterDrumAppBar.buttonSize,
        color: disabledColor,
      ),
    );
  }
}

class _ExplorerButton extends StatelessWidget {
  const _ExplorerButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: storage.explorer.isActive ? storage.close : storage.open,
      child: SizedBox(
        height: NoterDrumAppBar.height,
        width: NoterDrumAppBar.height,
        child: Icon(
          Icons.folder_outlined,
          color: storage.explorer.isActive ? selectedColor : null,
          size: NoterDrumAppBar.buttonSize,
        ),
      ),
    );
  }
}

class _SaveGrooveButton extends StatelessWidget {
  const _SaveGrooveButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    if (storage.explorer.isActive) return SizedBox.shrink();
    final disabledColor = Theme.of(context).colorScheme.onSecondaryContainer;

    return SizedBox(
      height: NoterDrumAppBar.height,
      width: NoterDrumAppBar.height,
      child: Icon(
        Icons.save_outlined,
        size: NoterDrumAppBar.buttonSize,
        color: disabledColor,
      ),
    );
  }
}

class _NewFolderButton extends StatelessWidget {
  const _NewFolderButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    if (!storage.explorer.isActive) return SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: storage.createFolder,
      child: SizedBox(
        height: NoterDrumAppBar.height,
        width: NoterDrumAppBar.height,
        child: Icon(
          Icons.create_new_folder_outlined,
          size: NoterDrumAppBar.buttonSize,
        ),
      ),
    );
  }
}

class _ReturnBackButton extends StatelessWidget {
  const _ReturnBackButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    if (!storage.explorer.isActive) return SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await storage.explorer.closeFolder();
        if (!storage.explorer.isActive) storage.closeSetup();
      },
      child: SizedBox(
        height: NoterDrumAppBar.height,
        width: NoterDrumAppBar.height,
        child: Icon(
          Icons.chevron_left,
          size: NoterDrumAppBar.buttonSize,
        ),
      ),
    );
  }
}
