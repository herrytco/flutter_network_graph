import 'package:flutter/material.dart';
import 'package:network_graph/api/graph.dart';
import 'package:network_graph/api/graph_settings.dart';
import 'package:network_graph/api/node.dart';
import 'package:network_graph/components/network_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<StatefulWidget> createState() => DemoState();
}

class DemoState extends State<DemoScreen> {
  List<Node<String>> nodes = [];
  late Graph<String> graph;

  @override
  void initState() {
    nodes = [
      Node<String>([], "A"),
      Node<String>(["A"], "B"),
      Node<String>(["B", "E"], "C"),
      Node<String>([], "D"),
      Node<String>(["D"], "E"),
      Node<String>(["E"], "F"),
      Node<String>([], "G"),
      Node<String>([], "H"),
      Node<String>([], "J"),
      Node<String>(["H", "J"], "I"),
    ];

    graph = Graph(nodes);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          NetworkView<String>(
            graph: graph,
            settings: GraphSettings(
              backgroundColor: Colors.green[100]!,
            ),
            onClick: (String s) {
              print(s);
            },
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
