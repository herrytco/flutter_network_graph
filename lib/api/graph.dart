import 'dart:math';

import 'package:network_graph/api/node.dart';

class Graph {
  final List<Node> nodes;
  List<Node> headCandidates = [];
  int nRanks = 0;
  int nRows = 0;

  Map<int, int> rowIndices = {};

  static const minRank = 0;

  Graph(this.nodes) {
    _calculateRanking();
    _calculateRowing();
    _calculateComponenting();
  }

  void _calculateComponenting() {
    int componentIndex = 0;

    for (Node head in headCandidates) {
      int? currentComponent = _getCurrentComponentOfSubtree(head);

      if (currentComponent == null) {
        _setComponentIndexToSubtree([head], componentIndex++);
      } else {
        head.component = currentComponent;
      }
    }
  }

  void _setComponentIndexToSubtree(List<Node> roots, int index) {
    for (Node r in roots) {
      r.component ??= index;

      _setComponentIndexToSubtree(getChildren(r), index);
    }
  }

  int? _getCurrentComponentOfSubtree(Node root) {
    if (root.component != null) return root.component;

    List<Node> children = getChildren(root);
    List<int> childComponentValues = children
        .map((e) => _getCurrentComponentOfSubtree(e))
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    return childComponentValues.isNotEmpty ? childComponentValues[0] : null;
  }

  List<Node> getChildren(Node n) {
    if (n.nodesBefore.isEmpty) return [];

    return n.nodesBefore
        .map((e) => nodes.firstWhere((element) => element.label == e))
        .toList();
  }

  void _calculateRowing() {
    for (int i = 0; i < nRanks; i++) {
      rowIndices[i] = 0;
    }

    for (Node head in headCandidates) {
      _row([head]);

      int maxRow = rowIndices.values.reduce(max);

      for(int rowIndex in rowIndices.keys) {
        rowIndices[rowIndex] = maxRow;
      }
    }

    nRows = rowIndices.values.reduce(max);
  }

  void _row(List<Node> nodesToRow) {
    for (Node k in nodesToRow) {
      int nodeRow = rowIndices[k.rank!]!;
      rowIndices[k.rank!] = nodeRow + 1;

      k.row ??= nodeRow;

      if (k.nodesBefore.isNotEmpty) {
        List<Node> children = k.nodesBefore
            .map((e) => nodes.firstWhere((element) => element.label == e))
            .toList();

        _row(children);
      }
    }
  }

  void _calculateRanking() {
    headCandidates = List<Node>.from(nodes)
        .where((element) => _hasOnlyIncomingDependencies(element))
        .toList();

    _rank(headCandidates, nodes.length);

    bool isRank1Populated =
        nodes.where((element) => element.rank == minRank).isNotEmpty;

    // prune unused ranks
    while (!isRank1Populated) {
      for (Node n in nodes) {
        n.rank = n.rank! - 1;
      }

      isRank1Populated =
          nodes.where((element) => element.rank == minRank).isNotEmpty;
    }

    nRanks = (nodes
            .map((e) => e.rank!)
            .reduce((value, element) => value > element ? value : element)) +
        1;
  }

  void _rank(List<Node> nodesToRank, int rank) {
    List<Node> nextLayer = [];

    for (Node n in nodesToRank) {
      n.rank = rank;

      List<Node> children = n.nodesBefore
          .map(
            (childLabel) =>
                nodes.firstWhere((element) => element.label == childLabel),
          )
          .toList();

      for (var child in children) {
        nextLayer.add(child);
      }
    }

    if (nextLayer.isEmpty) return;

    _rank(nextLayer, rank - 1);
  }

  bool _hasOnlyIncomingDependencies(Node n) {
    for (Node t in nodes) {
      if (t == n) continue;

      if (t.nodesBefore.contains(n.label)) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    String result = "Graph(";

    for (Node node in nodes) {
      result += "$node\n";
    }

    result += ")";

    return result;
  }
}
