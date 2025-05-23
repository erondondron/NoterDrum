import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({super.key});

  @override
  State<StatefulWidget> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
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
            child: _isActive
                ? Icon(
                    Icons.pause,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Icon(Icons.play_arrow, size: 30),
          ),
        ),
      ),
    );
  }
}
