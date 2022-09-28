import 'dart:math';

import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';

class ArrowPainter extends CustomPainter {
  final Graph graph;
  final Node? activeNode;
  final GraphSettings settings;
  final Map<int, List<Edge>> components = {};
  final Map<String, int> nextOutIndices = {};
  final Map<String, int> nextInIndices = {};
  final Map<int, Map<int, int>> laneEdges = {};

  ArrowPainter(
    this.graph,
    this.settings,
    this.activeNode,
  ) {
    for (Node head in graph.headCandidates) {
      _placeEdges(head);
    }

    _calculateNodeCardinalities();
  }

  void _calculateNodeCardinalities() {
    for (List<Edge> component in components.values) {
      for (Edge e in component) {
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

  void _placeEdges(Node to) {
    List<Node> children = graph.getChildren(to);
    if (children.isEmpty) return;

    for (Node child in children) {
      List<Edge> edges = components[to.component!] ?? [];
      edges.add(
        Edge(
          child,
          to,
          Paint()
            ..color = child == activeNode || to == activeNode ? settings.activeEdgeColor : settings.edgeColor
            ..strokeWidth = 1,
        ),
      );
      components[to.component!] = edges;

      _placeEdges(child);
    }
  }

  double _calculateNodeY(Offset pivot, double yTop, int nEdges, int edgeIndex) {
    double yOut = pivot.dy;
    if (nEdges > 1) {
      int pointsPerSide = nEdges ~/ 2;

      double yCenter = pivot.dy;

      double d = (yCenter - yTop) / (pointsPerSide + 1);

      if (nEdges % 2 == 0 || edgeIndex > 0) {
        yOut = yCenter + pow(-1, edgeIndex + 1) * d;
      }
    }

    return yOut;
  }

  List<Offset> _calculatePath(Edge e) {
    Offset origin = e.from.calculateOffset(NodePosition.centerRight, settings);
    Offset dest = e.to.calculateOffset(NodePosition.centerLeft, settings);

    double yOut = _calculateNodeY(
      origin,
      e.from.calculateOffset(NodePosition.topRight, settings).dy,
      e.nOutEdges!,
      e.outIndex!,
    );

    double yIn = _calculateNodeY(
      dest,
      e.to.calculateOffset(NodePosition.topLeft, settings).dy,
      e.nInEdges!,
      e.inIndex!,
    );

    double dx = (dest.dx - origin.dx);
    double xCenter = origin.dx + dx / 2;
    double xLeft = origin.dx;

    int nLanes = laneEdges[e.from.component!]![e.from.rank!]!;

    double d = (xCenter - xLeft) / (nLanes + 1);

    double xLane = xCenter + pow(-1, e.laneIndex!) * d * e.laneIndex! ~/ 2;

    List<Offset> path = [];

    path.add(Offset(origin.dx, yOut));
    path.add(Offset(xLane, yOut));
    path.add(Offset(xLane, yIn));
    path.add(Offset(dest.dx, yIn));

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int component in components.keys) {
      List<Edge> edges = components[component]!;

      for (Edge e in edges) {
        List<Offset> path = _calculatePath(e);

        for (int i = 0; i < path.length - 1; i++) {
          canvas.drawLine(path[i], path[i + 1], e.paint);

          // draw arrow joins
          canvas.drawCircle(
            path.first,
            settings.connectorSize,
            e.paint,
          );
          canvas.drawCircle(
            path.last,
            settings.connectorSize,
            e.paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Edge {
  final Node from;
  final Node to;
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
