import 'dart:ui';

import 'package:network_graph/api/graph_settings.dart';

class Node<T> {
  final List<T> nodesBefore;
  final T label;
  int? rank;
  int? row;
  int? component;

  Node(this.nodesBefore, this.label);

  @override
  String toString() {
    return "Node($label, rank:$rank, row:$row, component:$component)";
  }

  Offset calculateOffset(NodePosition position, GraphSettings settings) {
    int rank = this.rank!;
    int row = this.row!;

    Offset topLeft = Offset(
      rank * (settings.laneWidth + settings.laneMargin) + settings.lanePadding,
      row * (settings.rowHeight + settings.rowMargin) + settings.rowPadding,
    );

    switch (position) {
      case NodePosition.topLeft:
        return topLeft;

      case NodePosition.topCenter:
        return Offset(
          topLeft.dx + settings.nodeWidth / 2,
          topLeft.dy,
        );

      case NodePosition.topRight:
        return Offset(
          topLeft.dx + settings.nodeWidth,
          topLeft.dy,
        );

      case NodePosition.centerLeft:
        return Offset(
          topLeft.dx,
          topLeft.dy + settings.nodeHeight / 2,
        );

      case NodePosition.center:
        return Offset(
          topLeft.dx + settings.nodeWidth / 2,
          topLeft.dy + settings.nodeHeight / 2,
        );

      case NodePosition.centerRight:
        return Offset(
          topLeft.dx + settings.nodeWidth,
          topLeft.dy + settings.nodeHeight / 2,
        );

      case NodePosition.bottomLeft:
        return Offset(
          topLeft.dx,
          topLeft.dy + settings.nodeHeight,
        );

      case NodePosition.bottomCenter:
        return Offset(
          topLeft.dx + settings.nodeWidth / 2,
          topLeft.dy + settings.nodeHeight,
        );

      case NodePosition.bottomRight:
        return Offset(
          topLeft.dx + settings.nodeWidth,
          topLeft.dy + settings.nodeHeight,
        );

      default:
        return topLeft;
    }
  }
}

enum NodePosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}
