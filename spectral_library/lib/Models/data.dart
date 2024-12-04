class Data {
  double x;
  double y;
  Data({required this.x, required this.y});

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }

  /// Creates a Data object from a Map
  factory Data.fromMap(Map<String, dynamic> map) {
    return Data(
      x: map['x'] as double,
      y: map['y'] as double,
    );
  }
}
