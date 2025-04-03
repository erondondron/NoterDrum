import 'dart:math';

import 'package:drums/features/sheet_music/actions/editing/model.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/sheet_music/actions/widget.dart';
import 'package:drums/features/sheet_music/widget.dart';
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
      title: 'NoterDrums',
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
    final notchSize = MediaQuery.of(context).padding.left;
    final leftPadding = max(notchSize, 80.0);
    final bodyPadding = 25.0;
    final appBarHeight = 60.0;
    final actionsPadding = 20.0;
    final actionsSize = 50.0;

    final sheetMusic = SheetMusic.generate();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          titleSpacing: leftPadding - notchSize,
          title: Text(sheetMusic.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: null,
            ),
          ],
        ),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sheetMusic),
          ChangeNotifierProvider(create: (_) => DrumSetPanelController()),
          ChangeNotifierProvider(create: (_) => NotesEditingController()),
        ],
        child: Stack(
          children: [
            InteractiveViewer(
              clipBehavior: Clip.antiAlias,
              constrained: false,
              panAxis: PanAxis.aligned,
              child: Padding(
                padding: EdgeInsets.only(
                  left: leftPadding,
                  top: bodyPadding,
                  right: bodyPadding + actionsPadding + actionsSize,
                  bottom: bodyPadding + actionsPadding + actionsSize,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        appBarHeight -
                        bodyPadding * 2,
                    minWidth: MediaQuery.of(context).size.width -
                        leftPadding -
                        bodyPadding,
                  ),
                  child: SheetMusicWidget(),
                ),
              ),
            ),
            Positioned(
              right: actionsPadding,
              bottom: actionsPadding,
              child: ActionsPanel(),
            ),
          ],
        ),
      ),
    );
  }
}
