import 'dart:math';

import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';

class Tree<T> {
  final List<Node<T>> nodes;
  late Node<T> root;

  int component;
  late int nRanks;
  late int nRows;

  int rowOffset = 0;

  static const minRank = 0;

  Map<Node<T>, int> nodeColumns = {};
  Map<Node<T>, int> nodeRows = {};

  Tree(this.component, this.nodes) {
    List<Node<T>> headCandidates = List<Node<T>>.from(nodes)
        .where((element) => element.isHead(nodes))
        .toList();
    if (headCandidates.length > 1) {
      throw Exception("Multiple roots for subtree detected!");
    }
    root = headCandidates.first;

    //  determine columns
    _setSubtreeRank(root, 0);
    int minRank = nodeColumns.values.reduce(min);
    for (Node<T> node in nodes) {
      nodeColumns[node] = nodeColumns[node]! - minRank;
    }
    nRanks = nodeColumns.values.reduce(max) + 1;

    // determine rows
    Map<int, int> rowIndices = {};
    for (int i = 0; i < nRanks; i++) {
      rowIndices[i] = 0;
    }
    for (Node<T> node in nodes) {
      nodeRows[node] = rowIndices[nodeColumns[node]!]!;
      rowIndices[nodeColumns[node]!] = rowIndices[nodeColumns[node]!]! + 1;
    }

    nRows = nodeRows.values.reduce(max) + 1;
  }

  double height(GraphSettings settings) =>
      settings.rowHeight * nRows + settings.rowMargin * (nRows - 1);

  double width(GraphSettings settings) =>
      settings.laneWidth * nRanks + settings.laneMargin * (nRanks - 1);

  _setSubtreeRank(Node<T> root, int rank) {
    nodeColumns[root] = rank;

    root
        .getChildren(nodes)
        .forEach((element) => _setSubtreeRank(element, rank - 1));
  }

  @override
  String toString() {
    return "Tree(c$component, ($nRanks x $nRows) ${nodes.length} nodes $nodes)";
  }
}
