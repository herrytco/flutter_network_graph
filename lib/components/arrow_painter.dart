import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/api/path/path_calculator.dart';
import 'package:network_graph/api/path/single_arrow_per_lane_calculator.dart';

class ArrowPainter<T> extends CustomPainter {
  final Graph<T> graph;
  final Node? activeNode;
  final GraphSettings settings;
  final Map<int, List<Edge<T>>> components = {};
  final Map<T, int> nextOutIndices = {};
  final Map<T, int> nextInIndices = {};
  final Map<int, Map<int, int>> laneEdges = {};

  late PathCalculator pathCalculator;

  ArrowPainter(
    this.graph,
    this.settings,
    this.activeNode,
  ) {
    for (Node<T> head in graph.headCandidates) {
      _placeEdges(head);
    }

    _calculateNodeCardinalities();

    pathCalculator = SingleArrowPerLaneCalculator(settings, laneEdges);
  }

  void _calculateNodeCardinalities() {
    for (List<Edge<T>> component in components.values) {
      for (Edge<T> e in component) {
        int nOut = component.where((element) => element.from == e.from).length;
        e.nOutEdges = nOut;
        e.outIndex = nextOutIndices[e.from.label] ?? 0;
        nextOutIndices[e.from.label] = e.outIndex! + 1;

        int nIn = component.where((element) => element.to == e.to).length;
        e.nInEdges = nIn;
        e.inIndex = nextInIndices[e.to.label] ?? 0;
        nextInIndices[e.to.label] = e.inIndex! + 1;

        int cIndex = e.from.component!;

        Map<int, int> componentRankLaneEdges = laneEdges[cIndex] ?? {};
        int nLanes = componentRankLaneEdges[e.from.rank!] ?? 0;
        e.laneIndex = nLanes;
        nLanes++;
        componentRankLaneEdges[e.from.rank!] = nLanes;

        laneEdges[cIndex] = componentRankLaneEdges;
      }
    }
  }

  void _placeEdges(Node<T> to) {
    List<Node<T>> children = graph.getChildren(to);
    if (children.isEmpty) return;

    for (Node<T> child in children) {
      List<Edge<T>> edges = components[to.component!] ?? [];
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
      components[to.component!] = edges;

      _placeEdges(child);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int component in components.keys) {
      List<Edge<T>> edges = components[component]!;

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
