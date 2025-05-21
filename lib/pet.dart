class Pet {
  late String name, gender, breed, type, owner, age, id;
  late double weight;

  String? image, chip, birthDate;
  int? playful, friendly;

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
      this.birthDate,
      required this.id,
      this.playful,
      this.friendly,
  });

  factory Pet.fromJson(Map<String, dynamic> json){
    return Pet(
      name: json['name'].toString() ?? "",
      gender: json['gender'].toString() ?? "",
      age: json['age'].toString() ?? "0",
      breed: json['breed'].toString() ?? "",
      type: json['type'].toString() ?? "",
      image: json['photoUrls'].toString() ?? "",
      chip: json['chip'].toString() ?? "",
      weight: json['weight'],
      owner: json['owner'].toString() ?? "",
      birthDate: json['birthDate'].toString() ?? "",
      id: json['id'].toString() ?? "",
    );
  }
}
