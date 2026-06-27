import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Segmented control to switch between Inch / CM / MM / Feet. Selecting a
/// unit re-triggers calculation immediately (no submit step).
class UnitSelector extends StatelessWidget {
  final LengthUnit selected;
  final ValueChanged<LengthUnit> onChanged;

  const UnitSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<LengthUnit>(
        segments: LengthUnit.values
            .map(
              (u) => ButtonSegment<LengthUnit>(
                value: u,
                label: Text(u.label),
              ),
            )
            .toList(),
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}
