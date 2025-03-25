import 'package:flutter/material.dart';

class NotesEditingModel extends ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  void toggle() {
    _isActive = !_isActive;
    notifyListeners();
  }
}
