import 'dart:math';

import 'package:drums/models.dart';
import 'package:drums/sheet_music.dart';
import 'package:drums/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupSystem().then((_) => runApp(const Application()));
}

Future<void> setupSystem() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrumScribes',
      theme: darkTheme,
      home: const MainWindow(),
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  @override
  Widget build(BuildContext context) {
    double notchSize = MediaQuery.of(context).padding.left;
    double sidePadding = max(notchSize, 80);

    final sheetMusic = DrumSetModel();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          titleSpacing: sidePadding - notchSize,
          title: Text("NewGroove"),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: sidePadding, top: 25),
        child: ChangeNotifierProvider.value(
          value: sheetMusic,
          child: const SheetMusicWidget(),
        ),
      ),
    );
  }
}
