import 'package:flutter/material.dart';

class MetronomePanel extends StatefulWidget {
  const MetronomePanel({super.key});

  @override
  State<StatefulWidget> createState() => _MetronomePanelState();
}

class _MetronomePanelState extends State<MetronomePanel> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme.bodyMedium!.copyWith(height: 0.9);

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.all(Radius.circular(55)),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          width: 1.5,
        ),
      ),
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => setState(() => _isActive = !_isActive),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("120", style: textTheme.copyWith(fontSize: 20)),
                Text("BPM", style: textTheme.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
