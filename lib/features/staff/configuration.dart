class FiveLinesSettings {
  static const int number = 5;
  static const double gap = 10;

  static const double topOffset = 65;
  static const double height = topOffset + 6 * gap;

  static const double center = height - 3 * gap;
  static const double top = center - 2 * gap;
  static const double bottom = center + 2 * gap;
}

class LinesWidthSettings {
  static const double base = 0.5;
  static const double bar = 1;
  static const double noteHead = 1.5;
  static const double stem = 1.5;
}

class NotesSettings {
  static const double headRadius = 0.5 * FiveLinesSettings.gap;

  static const double stemInclineAngle = 0.08727;
  static const double stemInclineDx = 0.0875;
  static const double stemOffset = headRadius - 0.5 * LinesWidthSettings.stem;
  static const double stemLength = 4 * FiveLinesSettings.gap;

  static const double flagWidth = FiveLinesSettings.gap;
  static const double beamThickness = 4;
  static const double beamInclineDx = 0.176 * 0.75;
}
