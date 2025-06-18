import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

StaffNoteGroup createNestedGroup() {
  var firstNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 30)),
      StaffNoteStack(start: NoteDuration(value: 24)),
      StaffNoteStack(start: NoteDuration(value: 36)),
    ],
  );

  var secondNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 60)),
      StaffNoteStack(start: NoteDuration(value: 54)),
    ],
  );

  var firstSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 42)),
    ],
    subgroups: {
      NoteDuration(value: 24): firstNestedSubgroup,
      NoteDuration(value: 54): secondNestedSubgroup,
    },
  );

  var thirdNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 90)),
      StaffNoteStack(start: NoteDuration(value: 96)),
    ],
  );

  var secondSubgroup = StaffNoteGroup(
    subgroups: {NoteDuration(value: 90): thirdNestedSubgroup},
  );

  return StaffNoteGroup(stacks: [
    StaffNoteStack(start: NoteDuration(value: 102)),
    StaffNoteStack(start: NoteDuration(value: 66)),
    StaffNoteStack(start: NoteDuration(value: 0)),
  ], subgroups: {
    NoteDuration(value: 24): firstSubgroup,
    NoteDuration(value: 90): secondSubgroup,
  });
}

StaffNoteGroup createExpectedGroup() {
  var firstNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 24)),
      StaffNoteStack(start: NoteDuration(value: 30)),
      StaffNoteStack(start: NoteDuration(value: 36)),
    ],
  );

  var secondNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 54)),
      StaffNoteStack(start: NoteDuration(value: 60)),
    ],
  );

  var firstSubgroup = StaffNoteGroup(
    stacks: [
      ...firstNestedSubgroup.stacks,
      StaffNoteStack(start: NoteDuration(value: 42)),
      ...secondNestedSubgroup.stacks,
    ],
    subgroups: {
      NoteDuration(value: 24): firstNestedSubgroup,
      NoteDuration(value: 54): secondNestedSubgroup,
    },
  );

  var thirdNestedSubgroup = StaffNoteGroup(
    stacks: [
      StaffNoteStack(start: NoteDuration(value: 90)),
      StaffNoteStack(start: NoteDuration(value: 96)),
    ],
  );

  var secondSubgroup = StaffNoteGroup(
    stacks: thirdNestedSubgroup.stacks.toList(),
    subgroups: {NoteDuration(value: 90): thirdNestedSubgroup},
  );

  return StaffNoteGroup(stacks: [
    StaffNoteStack(start: NoteDuration(value: 0)),
    ...firstSubgroup.stacks,
    StaffNoteStack(start: NoteDuration(value: 66)),
    ...secondSubgroup.stacks,
    StaffNoteStack(start: NoteDuration(value: 102)),
  ], subgroups: {
    NoteDuration(value: 24): firstSubgroup,
    NoteDuration(value: 90): secondSubgroup,
  });
}

void main() {
  test("should collect and sort stacks from subgroups", () {
    var actual = createNestedGroup();
    var expected = createExpectedGroup();
    StaffConverter.collectStacksFromSubgroups(actual);
    compareNoteGroups(actual, expected);
  });
}
