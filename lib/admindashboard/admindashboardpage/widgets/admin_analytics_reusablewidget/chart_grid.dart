import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartGrid {
  static FlGridData build() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 5,
      verticalInterval: 1,
      checkToShowHorizontalLine: (value) => value % 10 == 0 || value % 5 == 0,
      getDrawingHorizontalLine: (value) {
        if (value % 10 == 0) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 0.8,
            dashArray: [1, 0],
          );
        }
        return FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 0.5,
          dashArray: [4, 4],
        );
      },
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.grey[200]!,
        strokeWidth: 0.5,
        dashArray: [4, 4],
      ),
      checkToShowVerticalLine: (value) => value % 2 == 0,
    );
  }
}
