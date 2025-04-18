import 'package:drums/features/app_bar.dart';
import 'package:drums/features/sheet_music/actions/editing/model.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/widget.dart';
import 'package:drums/features/storage/model.dart';
import 'package:drums/features/storage/window.dart';
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
    return Consumer<Storage>(
      builder: (BuildContext context, Storage storage, _) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(NoterDrumAppBar.height),
            child: NoterDrumAppBar(),
          ),
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: storage.selectedGroove),
              ChangeNotifierProvider(create: (_) => DrumSetPanelController()),
              ChangeNotifierProvider(
                create: (_) => NotesEditingController(
                  drumSet: storage.selectedGroove.drumSet,
                ),
              ),
            ],
            child: Stack(
              children: [
                SheetMusicWindow(),
                if (storage.isActive) StorageWindow(),
              ],
            ),
          ),
        );
      },
    );
  }
}
