import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/api/tree.dart';
import 'package:network_graph/components/arrow_painter.dart';

class NetworkView<T> extends StatefulWidget {
  const NetworkView({
    super.key,
    required this.graph,
    required this.nodeBuilder,
    this.settings = const GraphSettings(),
    this.onClick,
  });

  final Graph<T> graph;
  final GraphSettings settings;
  final Widget Function(Node<T>) nodeBuilder;
  final void Function(T)? onClick;

  void reportClick(Node<T> node) {
    if (onClick == null) return;

    onClick!(node.label);
  }

  @override
  State<StatefulWidget> createState() => _NetworkViewState<T>();
}

class _NetworkViewState<T> extends State<NetworkView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.graph.height(widget.settings),
      width: widget.graph.width(widget.settings),
      decoration: BoxDecoration(
        color: widget.settings.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.graph.forest
            .map((tree) => Padding(
                  padding: EdgeInsets.only(
                    top: widget.graph.forest.indexOf(tree) > 0
                        ? widget.settings.treeSpacing
                        : 0,
                  ),
                  child: _TreeRendering(
                    widget.settings,
                    tree,
                    widget.reportClick,
                    widget.nodeBuilder,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TreeRendering<T> extends StatefulWidget {
  final GraphSettings settings;
  final Tree<T> tree;
  final void Function(Node<T>)? onNodeClick;
  final Widget Function(Node<T>) nodeBuilder;

  static const bool _renderLaneIndicators = false;
  static const bool _renderRowIndicators = false;
  static const bool _renderNodes = true;
  static const bool _renderArrows = true;

  const _TreeRendering(
    this.settings,
    this.tree,
    this.onNodeClick,
    this.nodeBuilder,
  );

  @override
  State<_TreeRendering<T>> createState() => _TreeRenderingState<T>();
}

class _TreeRenderingState<T> extends State<_TreeRendering<T>> {
  Node? _selectedNode;

  void _onClick(Node<T> node) {
    if (widget.onNodeClick != null) widget.onNodeClick!(node);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.tree.height(widget.settings),
      width: widget.tree.width(widget.settings),
      decoration: BoxDecoration(
        // color: settings.backgroundColor,
        color: Colors.blue[100],
      ),
      child: Stack(
        children: [
          if (_TreeRendering._renderRowIndicators)
            for (int i = 0; i < widget.tree.nRows; i++)
              // row templates
              Positioned(
                top:
                    i * (widget.settings.rowHeight + widget.settings.rowMargin),
                left: 0,
                child: Container(
                  width: widget.tree.width(widget.settings),
                  height: widget.settings.rowHeight,
                  color: Colors.red[100],
                ),
              ),
          if (_TreeRendering._renderLaneIndicators)
            for (int i = 0; i < widget.tree.nRanks; i++)
              // lane templates
              Positioned(
                top: 0,
                left: i *
                    (widget.settings.laneWidth + widget.settings.laneMargin),
                child: Container(
                  height: widget.tree.height(widget.settings),
                  width: widget.settings.laneWidth,
                  color: Colors.yellow[100],
                ),
              ),
          // // arrow stuff
          if (_TreeRendering._renderArrows)
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: ArrowPainter(
                widget.tree,
                widget.settings,
                _selectedNode,
              ),
            ),
          if (_TreeRendering._renderNodes)
            ...widget.tree.nodes
                .map(
                  (node) => _NetworkGraphNode(
                    width: widget.settings.nodeWidth,
                    height: widget.settings.nodeHeight,
                    offset: node.calculateOffset(
                      NodePosition.topLeft,
                      widget.settings,
                      widget.tree,
                    ),
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
                    onClick: () => _onClick(node),
                    child: widget.nodeBuilder(node),
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
  final void Function() onEnter;
  final void Function() onExit;
  final void Function() onClick;

  const _NetworkGraphNode({
    required this.width,
    required this.height,
    required this.offset,
    required this.child,
    required this.onEnter,
    required this.onExit,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onTap: () => onClick(),
        child: MouseRegion(
          onEnter: (event) => onEnter(),
          onExit: (event) => onExit(),
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );
  }
}
