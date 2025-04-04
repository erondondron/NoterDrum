import 'dart:math';

import 'package:drums/features/sheet_music/actions/editing/model.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/actions/widget.dart';
import 'package:drums/features/sheet_music/widget.dart';
import 'package:drums/features/storage/actions.dart';
import 'package:drums/features/storage/explorer.dart';
import 'package:drums/features/storage/model.dart';
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
      home: ChangeNotifierProvider(
        create: (_) => Storage(),
        child: const MainWindow(),
      ),
    );
  }
}

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final notchSize = MediaQuery.of(context).padding.left;
    final leftPadding = max(notchSize, 80.0);
    final bodyPadding = 25.0;
    final appBarHeight = 60.0;
    final actionsPadding = 20.0;
    final actionsSize = 50.0;

    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: AppBar(
              titleSpacing: leftPadding - notchSize,
              title: Text(
                storage.viewMode
                    ? storage.selectedFolder!.relativePath
                    : storage.selectedGroove.name,
              ),
              actions: [
                StorageActions(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                    icon: Icon(Icons.settings_outlined, size: 30),
                    onPressed: storage.viewMode ? null : null,
                  ),
                ),
                SizedBox(width: actionsPadding),
              ],
            ),
          ),
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: storage.selectedGroove),
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
                storage.viewMode
                    ? StorageExplorerWidget()
                    : Positioned(
                        right: actionsPadding,
                        bottom: actionsPadding,
                        child: ActionsPanel(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
