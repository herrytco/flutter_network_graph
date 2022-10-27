import 'package:network_graph/api/graph_exception.dart';
import 'package:network_graph/api/node.dart';
import 'package:test/test.dart';
import 'package:network_graph/api/graph.dart';

void main() {
  test("test graph layout (empty)", () {
    Graph graph = Graph([]);

    assert(graph.forest.isEmpty);
  });

  test("test graph layout (A->B->C)", () {
    Graph<String> graph = Graph([
      Node<String>([], "A"),
      Node<String>(["A"], "B"),
      Node<String>(["B"], "C"),
    ]);

    assert(graph.forest.length == 1);
  });

  test("test graph layout (A->B->C + D->E->F)", () {
    Graph<String> graph = Graph([
      Node<String>([], "A"),
      Node<String>(["A"], "B"),
      Node<String>(["B"], "C"),
      Node<String>([], "D"),
      Node<String>(["D"], "E"),
      Node<String>(["E"], "F"),
    ]);

    assert(graph.forest.length == 2);
  });

  test("test graph layout (split, base)", () {
    Graph<String> graph = Graph([
      Node<String>([], "A"),
      Node<String>(["A"], "B"),
      Node<String>(["B", "D"], "C"),
      Node<String>([], "D"),
    ]);

    assert(graph.forest.length == 1);
  });

  test("test graph layout (split, base)", () {
    Graph<String> graph = Graph([
      Node<String>([], "A"),
      Node<String>(["A"], "B"),
      Node<String>(["B", "D"], "C"),
      Node<String>([], "D"),
      Node<String>(["D"], "E"),
    ]);

    assert(graph.forest.length == 2);
  });

  test("test graph layout (missing node)", () {
    expect(
      () => Graph([
        Node<String>(["A"], "B"),
      ]),
      throwsA(isA<GraphException>()),
    );
  });

  test("test graph layout (circle 1)", () {
    expect(
      () => Graph([
        Node<String>(["B"], "A"),
        Node<String>(["A"], "B"),
      ]),
      throwsA(isA<GraphException>()),
    );
  });

  test("test graph layout (circle 2)", () {
    expect(
      () => Graph([
        Node<String>(["C"], "A"),
        Node<String>(["A"], "B"),
        Node<String>(["B"], "C"),
      ]),
      throwsA(isA<GraphException>()),
    );
  });

  test("test graph layout (circle 3)", () {
    expect(
      () => Graph([
        Node<String>(["A"], "A"),
      ]),
      throwsA(isA<GraphException>()),
    );
  });
}
