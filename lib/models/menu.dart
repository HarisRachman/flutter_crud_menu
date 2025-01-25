class Menu {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is String ? double.parse(json['price']) : json['price'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
