class GraphException implements Exception {
  final String message;

  GraphException(this.message);

  @override
  String toString() {
    return "GraphException: $message";
  }
}
