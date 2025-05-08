class Pet {
  late String name, gender, age, breed, image, type;
  late int playful, friendly;

  Pet({
      required this.name,
      required this.gender,
      required this.age,
      required this.breed,
      required this.type,
      required this.image,
      required this.playful,
      required this.friendly
  });

  factory Pet.fromJson(Map<String, dynamic> json){
    return Pet(
      name: json['name'] ?? "",
      gender: json['gender'] ?? "",
      age: json['age'] ?? "",
      breed: json['breed'] ?? "",
      type: json['type'] ?? "",
      image: json['image'] ?? "",
      playful: json['playful'] ?? 0,
      friendly: json['friendly'] ?? 0,
    );
  }
}
