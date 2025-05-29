class Pet {
  late String name, id, gender, breed, type, owner, age;
  late double weight;

  String? image, cartilla, chip, birthDate;
  int? playful, friendly;

  Pet({
      required this.id,
      required this.name,
      required this.gender,
      required this.age,
      required this.breed,
      required this.type,
      this.image,
      this.cartilla,
      required this.weight,
      required this.owner,
      this.chip,
      this.birthDate,
      this.playful,
      this.friendly,
  });

  factory Pet.fromJson(Map<String, dynamic> json){
    return Pet(
      id: json['id'].toString() ?? "",
      name: json['name'].toString() ?? "",
      gender: json['gender'].toString() ?? "",
      age: json['age'].toString() ?? "",
      breed: json['breed'].toString() ?? "",
      type: json['type'].toString() ?? "",
      image: json['photoUrls'].toString() ?? "",
      cartilla: json['cartilla'].toString() ?? "",
      chip: json['chip'].toString() ?? "",
      weight: double.tryParse(json['weight']?.toString() ?? "") ?? 0.0,
      owner: json['owner'].toString() ?? "",
      birthDate: json['birthDate'].toString() ?? "",
    );
  }
}
