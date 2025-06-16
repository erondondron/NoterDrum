import 'package:drums/features/edit_grid/configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color!;
    final theme = ColorFilter.mode(color, BlendMode.srcIn);
    return SizedBox(
      height: EditGridConfiguration.noteHeight,
      width: EditGridConfiguration.noteHeight,
      child: SvgPicture.asset(asset, colorFilter: theme, fit: BoxFit.none),
    );
  }
}
