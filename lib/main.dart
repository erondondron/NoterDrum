import 'dart:math';

import 'package:drums/models/drum_set.dart';
import 'package:drums/models/sheet_music.dart';
import 'package:drums/widgets/sheet_music.dart';
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
  late final double _notchSize = MediaQuery.of(context).padding.left;
  late final double _leftPadding = max(_notchSize, 80);
  static const double _otherPadding = 25;

  static const double _appBarHeight = 60;
  late final double _bodyHeight =
      MediaQuery.of(context).size.height - _appBarHeight - _otherPadding * 2;
  late final double _bodyWidth =
      MediaQuery.of(context).size.width - _leftPadding - _otherPadding;

  @override
  Widget build(BuildContext context) {
    final sheetMusic = SheetMusicModel();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: AppBar(
          titleSpacing: _leftPadding - _notchSize,
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
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sheetMusic),
          ChangeNotifierProvider(create: (_) => DrumSetPanelController()),
        ],
        child: InteractiveViewer(
          clipBehavior: Clip.antiAlias,
          constrained: false,
          panAxis: PanAxis.aligned,
          child: Padding(
            padding: EdgeInsets.only(
              left: _leftPadding,
              top: _otherPadding,
              right: _otherPadding,
              bottom: _otherPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: _bodyHeight,
                minWidth: _bodyWidth,
              ),
              child: SheetMusicWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
