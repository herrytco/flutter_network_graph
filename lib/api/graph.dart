import 'dart:math';

import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/api/tree.dart';

class Graph<T> {
  final List<Node<T>> nodes;
  final List<Tree<T>> forest = [];

  List<Node<T>> headCandidates = [];
  int get nRanks => forest.map((e) => e.nRanks).reduce(max);
  int get nRows => forest.map((e) => e.nRows).reduce((v1, v2) => v1 + v2);

  Map<int, int> rowIndices = {};

  Graph(this.nodes) {
    _verify();

    List<Node<T>> heads = List<Node<T>>.from(nodes)
        .where((element) => element.isHead(nodes))
        .toList();

    for (Node<T> head in heads) {
      Node<T> headNew = Node.clone(head);

      forest.add(Tree<T>(
        forest.length,
        List.from(headNew.subtree(nodes).map((e) => Node.clone(e))),
      ));
    }

    int offset = 0;
    for (Tree<T> tree in forest) {
      tree.rowOffset = offset;
      offset += tree.nRows;
    }
  }

  double height(GraphSettings settings) =>
      forest
          .map((e) => e.height(settings))
          .reduce((value, element) => value + element) +
      (forest.length - 1) * settings.treeSpacing;

  double width(GraphSettings settings) =>
      forest.map((e) => e.width(settings)).reduce(max);

  /// checks if all nodes referenced are present in the graph. Throws an Exception
  /// if a node is missing.
  void _verify() {
    // 1. check for missing nodes
    for (Node<T> node in nodes) {
      for (T neighbour in node.nodesBefore) {
        nodes.firstWhere((element) => element.label == neighbour,
            orElse: () => throw Exception(
                "Node with label '$neighbour' does not exist in the graph!"));
      }
    }

    // TODO 2. check for circles
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
