import 'dart:math';

import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class StorageFolderCreationWidget extends StatefulWidget {
  const StorageFolderCreationWidget({super.key});

  @override
  State<StorageFolderCreationWidget> createState() => _FolderCreationState();
}

class _FolderCreationState extends State<StorageFolderCreationWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  late StorageFolder _parentFolder;
  String _newFolder = "";

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      _controller.text = _folderPath;
      _controller.selection = TextSelection.collapsed(
        offset: _newFolder.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _folderPath {
    return !_focusNode.hasFocus
        ? path.join(_parentFolder.relativePath, _newFolder)
        : _newFolder;
  }

  @override
  Widget build(BuildContext context) {
    final notchSize = MediaQuery.of(context).padding.left;
    final horizontalPadding = max(notchSize, 80.0);

    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final folderColor = Theme.of(context).colorScheme.surface;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        _parentFolder = storage.selectedFolder!;
        return Container(
          decoration: BoxDecoration(
            color: folderColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
              right: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ListView(
              children: [
                SizedBox(height: 60),
                Text("New folder:"),
                SizedBox(height: 15),
                TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  onChanged: (value) => _newFolder = value,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: storage.toggleNewFolderMode,
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        storage.toggleNewFolderMode();
                        storage.openFolder(folderPath: _folderPath);
                      },
                      child: Text("Accept"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
