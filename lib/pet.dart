class Pet {
  late String name, gender, breed, image, type, id;
  late int playful, friendly;
  late double weight, age;
  Pet({
      required this.id,
      required this.name,
      required this.gender,
      required this.age,
      required this.breed,
      required this.type,
      required this.image,
      required this.playful,
      required this.friendly,
      required this.weight
  });

  factory Pet.fromJson(Map<String, dynamic> json){
    return Pet(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      gender: json['gender'] ?? "",
      age: json['age'] ?? 0.0,
      breed: json['breed'] ?? "",
      type: json['type'] ?? "",
      image: json['image'] ?? "",
      playful: json['playful'] ?? 0,
      friendly: json['friendly'] ?? 0,
      weight: json['weight'] ?? 0.0
    );
  }
}
