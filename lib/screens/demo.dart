import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/components/network_view.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<StatefulWidget> createState() => DemoState();
}

class DemoState extends State<DemoScreen> {
  List<Node> nodes = [];
  late Graph graph;

  @override
  void initState() {
    nodes = [
      Node([], "A"),
      Node(["A"], "B"),
      Node(["B", "D", "G"], "C"),
      Node([], "D"),
      Node(["D"], "E"),
      Node([], "F"),
      Node([], "G"),
      Node([], "H"),
      Node([], "J"),
      Node(["H", "J"], "I"),
    ];

    graph = Graph(nodes);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NetworkView(
            graph: graph,
            settings: GraphSettings(
              backgroundColor: Colors.green[100]!,
            ),
            nodeBuilder: (Node node) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: Text(node.label),
            ),
          ),
        ],
      ),
    );
  }
}
