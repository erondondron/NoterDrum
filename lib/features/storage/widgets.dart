import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorageActions extends StatelessWidget {
  const StorageActions({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return Row(
          children: [
            if (!storage.disabled) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                  icon: Icon(Icons.chevron_left, size: 30),
                  onPressed: null,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined, size: 30),
                  onPressed: null,
                ),
              ),
            ],
            if (!storage.viewMode)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                  icon: Icon(Icons.save_outlined, size: 30),
                  onPressed: null,
                ),
              ),
            if (!storage.saveMode)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.folder_outlined,
                    color: storage.viewMode ? selectedColor : null,
                    size: 30,
                  ),
                  onPressed: storage.view,
                ),
              ),
          ],
        );
      },
    );
  }
}

class StorageFolderWidget extends StatelessWidget {
  const StorageFolderWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final blackoutColor = Theme.of(context).colorScheme.secondaryContainer;
    final folderColor = Theme.of(context).colorScheme.surface;

    return Row(
      children: [
        child != null
            ? SizedBox(
                width: width * 2 / 3,
                child: child,
              )
            : Container(
                width: width * 2 / 3,
                color: blackoutColor.withValues(alpha: 0.8),
              ),
        Container(
          width: width / 3,
          decoration: BoxDecoration(
            color: folderColor,
            border: Border(
              top: BorderSide(color: blackoutColor, width: 2),
              left: BorderSide(color: blackoutColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
