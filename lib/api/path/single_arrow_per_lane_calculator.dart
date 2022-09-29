import 'dart:math';
import 'dart:ui';

import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/api/path/path_calculator.dart';
import 'package:network_graph/components/arrow_painter.dart';

class SingleArrowPerLaneCalculator implements PathCalculator {
  final GraphSettings settings;
  final Map<int, Map<int, int>> laneEdges;

  SingleArrowPerLaneCalculator(this.settings, this.laneEdges);

  @override
  List<Offset> calculatePath(Edge e) {
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
}
