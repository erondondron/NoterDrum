import 'package:drums/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class InstrumentsPanel extends StatefulWidget {
  const InstrumentsPanel({super.key});

  @override
  State<InstrumentsPanel> createState() => _InstrumentsPanelState();
}

class _InstrumentsPanelState extends State<InstrumentsPanel> {
  static const double _rowHeight = 40;
  static const double _iconSize = 24;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusic>(
      builder: (BuildContext context, SheetMusic sheetMusic, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              controlRow(sheetMusic),
              ...sheetMusic.selectedDrums
                  .map((drum) => selectedDrumRow(drum, sheetMusic)),
            ],
          ),
        );
      },
    );
  }

  Widget controlRow(SheetMusic sheetMusic) {
    if (!_isExpanded) return panelExpansionToggle();

    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          addNewDrumButton(sheetMusic),
          panelExpansionToggle(),
        ],
      ),
    );
  }

  Widget selectedDrumRow(Drums drum, SheetMusic sheetMusic) {
    if (!_isExpanded) return drumIcon(drum.icon);

    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          rowLabel(drumIcon(drum.icon), drum.name),
          removeDrumButton(drum, sheetMusic),
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

  Widget removeDrumButton(Drums drum, SheetMusic controller) {
    return GestureDetector(
      onTap: () => controller.removeDrum(drum),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _rowHeight,
        width: _iconSize,
        child: Icon(Icons.close_outlined, size: 15),
      ),
    );
  }

  Widget addNewDrumButton(SheetMusic controller) {
    return PopupMenuButton<Drums>(
      child: rowLabel(Icon(Icons.add_outlined), "More"),
      onSelected: (Drums drum) => controller.addDrum(drum),
      itemBuilder: (BuildContext context) {
        return controller.unselectedDrums
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

  Widget panelExpansionToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: _rowHeight,
        width: _iconSize,
        child: _isExpanded
            ? Icon(Icons.keyboard_double_arrow_left_outlined, size: 18)
            : Icon(Icons.keyboard_double_arrow_right_outlined, size: 24),
      ),
    );
  }
}
