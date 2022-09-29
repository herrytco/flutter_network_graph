import 'dart:math';

import 'package:network_graph/api/node.dart';

class Graph<T> {
  final List<Node<T>> nodes;
  List<Node<T>> headCandidates = [];
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

    for (Node<T> head in headCandidates) {
      int? currentComponent = _getCurrentComponentOfSubtree(head);

      if (currentComponent == null) {
        _setComponentIndexToSubtree([head], componentIndex++);
      } else {
        head.component = currentComponent;
      }
    }
  }

  void _setComponentIndexToSubtree(List<Node<T>> roots, int index) {
    for (Node<T> r in roots) {
      r.component ??= index;

      _setComponentIndexToSubtree(getChildren(r), index);
    }
  }

  int? _getCurrentComponentOfSubtree(Node<T> root) {
    if (root.component != null) return root.component;

    List<Node<T>> children = getChildren(root);
    List<int> childComponentValues = children
        .map((e) => _getCurrentComponentOfSubtree(e))
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    return childComponentValues.isNotEmpty ? childComponentValues[0] : null;
  }

  List<Node<T>> getChildren(Node<T> n) {
    if (n.nodesBefore.isEmpty) return [];

    return n.nodesBefore
        .map((e) => nodes.firstWhere((element) => element.label == e))
        .toList();
  }

  void _calculateRowing() {
    for (int i = 0; i < nRanks; i++) {
      rowIndices[i] = 0;
    }

    for (Node<T> head in headCandidates) {
      _row([head]);

      int maxRow = rowIndices.values.reduce(max);

      for (int rowIndex in rowIndices.keys) {
        rowIndices[rowIndex] = maxRow;
      }
    }

    nRows = rowIndices.values.reduce(max);
  }

  void _row(List<Node<T>> nodesToRow) {
    for (Node<T> k in nodesToRow) {
      int nodeRow = rowIndices[k.rank!]!;
      rowIndices[k.rank!] = nodeRow + 1;

      k.row ??= nodeRow;

      if (k.nodesBefore.isNotEmpty) {
        List<Node<T>> children = k.nodesBefore
            .map((e) => nodes.firstWhere((element) => element.label == e))
            .toList();

        _row(children);
      }
    }
  }

  void _calculateRanking() {
    headCandidates = List<Node<T>>.from(nodes)
        .where((element) => _hasOnlyIncomingDependencies(element))
        .toList();

    _rank(headCandidates, nodes.length);

    bool isRank1Populated =
        nodes.where((element) => element.rank == minRank).isNotEmpty;

    // prune unused ranks
    while (!isRank1Populated) {
      for (Node<T> n in nodes) {
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

  void _rank(List<Node<T>> nodesToRank, int rank) {
    List<Node<T>> nextLayer = [];

    for (Node<T> n in nodesToRank) {
      n.rank = rank;

      List<Node<T>> children = n.nodesBefore
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

  bool _hasOnlyIncomingDependencies(Node<T> n) {
    for (Node<T> t in nodes) {
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

    for (Node<T> node in nodes) {
      result += "$node\n";
    }

    result += ")";

    return result;
  }
}
