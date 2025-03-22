import 'package:drums/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DrumSetWidget extends StatefulWidget {
  const DrumSetWidget({super.key});

  @override
  State<DrumSetWidget> createState() => _DrumSetWidgetState();
}

class _DrumSetWidgetState extends State<DrumSetWidget> {
  static const double _rowHeight = 40;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Consumer<DrumSetModel>(
      builder: (BuildContext context, DrumSetModel drumSet, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controlRow(drumSet),
              ...drumSet.selected.map((drum) => selectedDrumRow(drum, drumSet)),
            ],
          ),
        );
      },
    );
  }

  Widget controlRow(DrumSetModel drumSet) {
    if (drumSet.isHidden) return hidingToggle(drumSet);

    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          addNewDrumButton(drumSet),
          hidingToggle(drumSet),
        ],
      ),
    );
  }

  Widget selectedDrumRow(Drums drum, DrumSetModel drumSet) {
    if (drumSet.isHidden) return drumIcon(drum.icon);

    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          rowLabel(drumIcon(drum.icon), drum.name),
          removeDrumButton(drum, drumSet),
        ],
      ),
    );
  }

  Widget rowLabel(Widget icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        Padding(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Text(label),
        ),
      ],
    );
  }

  Widget drumIcon(String asset) {
    final color = Theme.of(context).iconTheme.color!;
    final theme = ColorFilter.mode(color, BlendMode.srcIn);
    return SizedBox(
      height: _rowHeight,
      width: _iconSize,
      child: SvgPicture.asset(asset, colorFilter: theme, fit: BoxFit.none),
    );
  }

  Widget removeDrumButton(Drums drum, DrumSetModel drumSet) {
    return GestureDetector(
      onTap: () => drumSet.remove(drum),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _rowHeight,
        width: _iconSize,
        child: Icon(Icons.close_outlined, size: 15),
      ),
    );
  }

  Widget addNewDrumButton(DrumSetModel drumSet) {
    return PopupMenuButton<Drums>(
      child: rowLabel(Icon(Icons.add_outlined), "More"),
      onSelected: (Drums drum) => drumSet.add(drum),
      itemBuilder: (BuildContext context) {
        return drumSet.unselected
            .map(
              (drum) => PopupMenuItem(
                value: drum,
                child: rowLabel(drumIcon(drum.icon), drum.name),
              ),
            )
            .toList();
      },
    );
  }

  Widget hidingToggle(DrumSetModel drumSet) {
    return GestureDetector(
      onTap: drumSet.toggleHiding,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _rowHeight,
        width: _iconSize,
        child: drumSet.isHidden
            ? Icon(Icons.keyboard_double_arrow_right_outlined, size: 24)
            : Icon(Icons.keyboard_double_arrow_left_outlined, size: 18),
      ),
    );
  }
}
