class Pet {
  late String name, gender, breed, type, owner, age;
  late double weight;

  String? image, chip, birthDate;

  Pet({
      required this.name,
      required this.gender,
      required this.age,
      required this.breed,
      required this.type,
      this.image,
      required this.weight,
      required this.owner,
      this.chip,
      this.birthDate
  });

  factory Pet.fromJson(Map<String, dynamic> json){
    return Pet(
      name: json['name'].toString() ?? "",
      gender: json['gender'].toString() ?? "",
      age: json['age'] ?? "0",
      breed: json['breed'].toString() ?? "",
      type: json['type'].toString() ?? "",
      image: json['image'].toString() ?? "",
      chip: json['chip'].toString() ?? "",
      weight: double.tryParse(json['weight'] ?? 0.0) ?? 0.0,
      owner: json['owner'].toString() ?? "",
      birthDate: json['birthDate'].toString() ?? "",
    );
  }
}
