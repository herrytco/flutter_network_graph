import 'package:flutter/material.dart';
import 'package:network_graph/components/arrow_painter.dart';

abstract class PathCalculator {
  List<Offset> calculatePath(Edge edge);
}