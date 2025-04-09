class StorageSetupEntity {}

class StorageNewFolder extends StorageSetupEntity {
  StorageNewFolder({this.name = "NewFolder"});

  String name;
}

class StorageNewGroove extends StorageSetupEntity {
  StorageNewGroove({this.name = "NewGroove"});

  String name;
}
