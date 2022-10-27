import 'package:flutter/material.dart';

class GraphSettings {
  const GraphSettings({
    this.laneWidth = 200,
    this.lanePadding = 40,
    this.rowHeight = 100,
    this.rowPadding = 20,
    this.laneMargin = 100,
    this.rowMargin = 10,
    this.backgroundColor = Colors.transparent,
    this.edgeColor = Colors.black,
    this.activeEdgeColor = Colors.red,
    this.connectorSize = 3,
    this.edgeThickness = 1,
    this.treeSpacing = 20,
  });

  final Color backgroundColor;

  final Color edgeColor;
  final Color activeEdgeColor;
  final double edgeThickness;

  final double connectorSize;

  ///
  /// full width of a lane including padding
  ///
  final double laneWidth;

  ///
  /// horizontal space between lane edge and node edge
  ///
  /// | lanePadding nodeWidth lanePadding |
  /// |            laneWidth              |
  ///
  final double lanePadding;

  /// space between lanes -> space where arrows are drawn
  final double laneMargin;

  final double treeSpacing;

  double get nodeWidth => laneWidth - 2 * lanePadding;

  ///
  /// full height of a row including padding
  ///
  final double rowHeight;

  final double rowPadding;
  final double rowMargin;

  double get nodeHeight => rowHeight - 2 * rowPadding;
}
