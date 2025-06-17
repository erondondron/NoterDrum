import 'dart:math';

import 'package:drums/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoterDrumAppBar extends StatefulWidget {
  static const double height = 60;
  static const double leftPadding = 80;
  static const double rightPadding = 25;
  static const double buttonSize = 30;

  const NoterDrumAppBar({super.key});

  @override
  State<NoterDrumAppBar> createState() => _NoterDrumAppBarState();
}

class _NoterDrumAppBarState extends State<NoterDrumAppBar> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var notchSize = MediaQuery.of(context).padding.left;
    var padding = max(notchSize, NoterDrumAppBar.leftPadding) - notchSize;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return PreferredSize(
          preferredSize: Size.fromHeight(NoterDrumAppBar.height),
          child: AppBar(
            titleSpacing: padding,
            title: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(storage.displayedTitle, overflow: TextOverflow.fade),
            ),
            actions: [
              _ReturnBackButton(storage: storage),
              _NewFolderButton(storage: storage),
              _SaveGrooveButton(storage: storage),
              _ExplorerButton(storage: storage),
              _SettingsButton(storage: storage),
              SizedBox(width: NoterDrumAppBar.rightPadding),
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
    GestureTapCallback? onTap = storage.openFolder;
    Color? color;

    if (storage.newGroove != null) {
      color = Theme.of(context).colorScheme.onSecondaryContainer;
      onTap = null;
    } else if (storage.isActive) {
      color = Theme.of(context).colorScheme.primary;
      onTap = storage.close;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        height: NoterDrumAppBar.height,
        width: NoterDrumAppBar.height,
        child: Icon(
          Icons.folder_outlined,
          color: color,
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
    GestureTapCallback? onTap = storage.setupNewGroove;
    Color? color;

    if (storage.newGroove != null) {
      color = Theme.of(context).colorScheme.primary;
      onTap = storage.close;
    } else if (storage.isActive) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        height: NoterDrumAppBar.height,
        width: NoterDrumAppBar.height,
        child: Icon(
          Icons.save_outlined,
          color: color,
          size: NoterDrumAppBar.buttonSize,
        ),
      ),
    );
  }
}

class _NewFolderButton extends StatelessWidget {
  const _NewFolderButton({required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    if (!storage.isActive) return SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: storage.setupNewFolder,
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
    if (!storage.isActive) return SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: storage.returnBack,
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
