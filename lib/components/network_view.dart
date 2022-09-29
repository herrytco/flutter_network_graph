import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/components/arrow_painter.dart';

class NetworkView<T> extends StatefulWidget {
  const NetworkView({
    super.key,
    required this.graph,
    required this.nodeBuilder,
    this.settings = const GraphSettings(),
  });

  final Graph<T> graph;
  final GraphSettings settings;
  final Widget Function(Node<T>) nodeBuilder;

  @override
  State<StatefulWidget> createState() => _NetworkViewState<T>();
}

class _NetworkViewState<T> extends State<NetworkView> {
  Map<int, int> lanePositions = {};

  double get containerWidth =>
      widget.settings.laneWidth * widget.graph.nRanks +
      widget.settings.laneMargin * (widget.graph.nRanks - 1);

  double get containerHeight =>
      widget.settings.rowHeight * widget.graph.nRows +
      widget.settings.rowMargin * (widget.graph.nRows - 1);

  static const bool _renderLaneIndicators = false;
  static const bool _renderRowIndicators = false;
  static const bool _renderArrows = true;
  static const bool _renderNodes = true;

  Node? _selectedNode;

  @override
  void initState() {
    for (int i = 0; i < widget.graph.nRanks; i++) {
      lanePositions[i + 1] = 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(
        color: widget.settings.backgroundColor,
      ),
      child: Stack(
        children: [
          if (_renderRowIndicators)
            for (int i = 0; i < widget.graph.nRows; i++)
              // lane templates
              Positioned(
                top:
                    i * (widget.settings.rowHeight + widget.settings.rowMargin),
                left: 0,
                child: Container(
                  width: containerWidth,
                  height: widget.settings.rowHeight,
                  color: Colors.lightGreenAccent,
                ),
              ),

          if (_renderLaneIndicators)
            for (int i = 0; i < widget.graph.nRanks; i++)
              // lane templates
              Positioned(
                top: 0,
                left: i *
                    (widget.settings.laneWidth + widget.settings.laneMargin),
                child: Container(
                  height: containerHeight,
                  width: widget.settings.laneWidth,
                  color: Colors.green,
                ),
              ),

          // arrow stuff
          if (_renderArrows)
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: ArrowPainter(
                widget.graph,
                widget.settings,
                _selectedNode,
              ),
            ),

          if (_renderNodes)
            ...widget.graph.nodes
                .map(
                  (node) => _NetworkGraphNode(
                    width: widget.settings.nodeWidth,
                    height: widget.settings.nodeHeight,
                    offset: node.calculateOffset(
                        NodePosition.topLeft, widget.settings),
                    child: widget.nodeBuilder(node),
                    onEnter: () {
                      setState(() {
                        _selectedNode = node;
                      });
                    },
                    onExit: () {
                      setState(() {
                        _selectedNode = null;
                      });
                    },
                  ),
                )
                .toList(),
        ],
      ),
    );
  }
}

class _NetworkGraphNode extends StatelessWidget {
  final Offset offset;
  final double width;
  final double height;
  final Widget child;
  final Function onEnter;
  final Function onExit;

  const _NetworkGraphNode({
    super.key,
    required this.width,
    required this.height,
    required this.offset,
    required this.child,
    required this.onEnter,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: MouseRegion(
        onEnter: (event) => onEnter(),
        onExit: (event) => onExit(),
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}
