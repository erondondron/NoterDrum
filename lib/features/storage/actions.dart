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
            if (storage.viewMode) ...[
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
                  onPressed: storage.toggleNewFolderMode,
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
            if (!storage.newGrooveMode)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: storage.viewMode ? storage.close : storage.openFolder,
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Icon(
                    Icons.folder_outlined,
                    color: storage.viewMode ? selectedColor : null,
                    size: 30,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
