import 'package:drums/features/storage/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorageActions extends StatelessWidget {
  const StorageActions({super.key});

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.folder_outlined, size: 30),
                  onPressed: null,
                ),
              ),
          ],
        );
      },
    );
  }
}
