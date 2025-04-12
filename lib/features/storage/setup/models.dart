class StorageSetupEntity {}

class NewFolderSetup extends StorageSetupEntity {
  NewFolderSetup({required this.name});

  String name;
}

class NewGrooveSetup extends StorageSetupEntity {
  NewGrooveSetup({required this.name});

  String name;
}

class RenameEntitySetup extends StorageSetupEntity {
  RenameEntitySetup({
    required this.entityPath,
    required this.newName,
  });

  String entityPath;
  String newName;
}
