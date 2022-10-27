import 'dart:ui';

import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/tree.dart';

class Node<T> {
  static int _nextId = 1;

  final List<T> nodesBefore;
  final T label;
  int id = _nextId++;

  Node(this.nodesBefore, this.label);

  factory Node.clone(Node<T> original) {
    return Node(original.nodesBefore, original.label);
  }

  @override
  String toString() {
    return "Node($id, $label)";
  }

  List<Node<T>> subtree(List<Node<T>> nodes) {
    List<Node<T>> children = getChildren(nodes);

    if (children.isEmpty) return [this];

    List<Node<T>> result = [this];

    for (Node<T> child in children) {
      result.addAll(child.subtree(nodes));
    }

    return result;
  }

  List<Node<T>> getChildren(List<Node<T>> nodes) {
    if (nodesBefore.isEmpty) return [];

    return nodesBefore
        .map((e) => nodes.firstWhere((element) => element.label == e))
        .toList();
  }

  bool isHead(List<Node<T>> nodes) {
    for (Node<T> other in nodes) {
      if (other == this) continue;

      if (other.nodesBefore.contains(label)) {
        return false;
      }
    }

    return true;
  }

  Offset calculateOffset(
    NodePosition position,
    GraphSettings settings,
    Tree<T> tree,
  ) {
    int column = tree.nodeColumns[this]!;
    int row = tree.nodeRows[this]!;

    Offset topLeft = Offset(
      column * (settings.laneWidth + settings.laneMargin) +
          settings.lanePadding,
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
