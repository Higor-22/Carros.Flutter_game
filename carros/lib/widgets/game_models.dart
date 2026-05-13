class GameObject {
  double x;
  double y;
  
  GameObject({required this.x, required this.y});
  
  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }
  
  factory GameObject.fromMap(Map<String, dynamic> map) {
    return GameObject(
      x: map['x'],
      y: map['y'],
    );
  }
}