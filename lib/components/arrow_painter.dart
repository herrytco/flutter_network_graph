import 'package:flutter/material.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/api/path/path_calculator.dart';
import 'package:network_graph/api/path/single_arrow_per_lane_calculator.dart';
import 'package:network_graph/api/tree.dart';

class ArrowPainter<T> extends CustomPainter {
  final Tree<T> tree;
  final Node? activeNode;
  final GraphSettings settings;

  final List<Edge<T>> edges = [];

  late PathCalculator pathCalculator;

  final Map<Node<T>, int> nextOutIndices = {};
  final Map<Node<T>, int> nextInIndices = {};
  final Map<int, int> laneEdges = {};

  ArrowPainter(
    this.tree,
    this.settings,
    this.activeNode,
  ) {
    _placeEdges(tree.root);

    _calculateNodeCardinalities();

    pathCalculator = SingleArrowPerLaneCalculator(settings, laneEdges, tree);
  }

  void _placeEdges(Node<T> to) {
    List<Node<T>> children = to.getChildren(tree.nodes);
    if (children.isEmpty) return;

    for (Node<T> child in children) {
      edges.add(
        Edge<T>(
          child,
          to,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = child == activeNode || to == activeNode
                ? settings.activeEdgeColor
                : settings.edgeColor
            ..strokeWidth = settings.edgeThickness
            ..isAntiAlias = true,
        ),
      );

      _placeEdges(child);
    }
  }

  void _calculateNodeCardinalities() {
    for (Edge<T> e in edges) {
      int nOut = edges.where((element) => element.from == e.from).length;
      e.nOutEdges = nOut;
      e.outIndex = nextOutIndices[e.from] ?? 0;
      nextOutIndices[e.from] = e.outIndex! + 1;

      int nIn = edges.where((element) => element.to == e.to).length;
      e.nInEdges = nIn;
      e.inIndex = nextInIndices[e.to] ?? 0;
      nextInIndices[e.to] = e.inIndex! + 1;

      int nLanes = laneEdges[tree.nodeColumns[e.from]] ?? 0;
      e.laneIndex = nLanes;
      nLanes++;
      laneEdges[tree.nodeColumns[e.from]!] = nLanes;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Edge<T> e in edges) {
      List<Offset> path = pathCalculator.calculatePath(e);

      Offset vm = Offset(path[1].dx, (path[1].dy + path[2].dy) / 2);

      Path p = Path();
      p.moveTo(path[0].dx, path[0].dy);
      p.quadraticBezierTo(path[1].dx, path[1].dy, vm.dx, vm.dy);
      p.quadraticBezierTo(path[2].dx, path[2].dy, path.last.dx, path.last.dy);
      canvas.drawPath(p, e.paint);

      // draw arrow joins
      canvas.drawCircle(
        path.first,
        settings.connectorSize,
        Paint()
          ..strokeWidth = e.paint.strokeWidth
          ..color = e.paint.color
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        path.last,
        settings.connectorSize,
        Paint()
          ..strokeWidth = e.paint.strokeWidth
          ..color = e.paint.color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Edge<T> {
  final Node<T> from;
  final Node<T> to;
  final Paint paint;

  int? nOutEdges;
  int? outIndex;

  int? nInEdges;
  int? inIndex;

  int? laneIndex;

  Edge(this.from, this.to, this.paint);

  @override
  String toString() {
    return "Edge(${from.label}->${to.label}, nOut:$nOutEdges, iOut:$outIndex, nIn:$nInEdges, iIn:$inIndex, lane:$laneIndex)";
  }
}
