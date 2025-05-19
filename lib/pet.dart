class Pet {
  late String name, gender, age, breed, image, weight, id;
  late int playful, friendly;
  Pet(this.name, this.gender, this.age, this.breed, this.weight, this.image, this.playful, this.friendly, this.id);
}

final List<Pet> pets = [
  Pet("Test Cat", "Male", "4", "cat", "7.5kg", "assets/pets/cat.jpg", 3, 5, "catID"),
  Pet("Test Dog", "Female", "6", "dog",  "25.8kg", "assets/pets/dog.jpg", 4, 3, "dogID"),
  Pet("Test Hamster", "Male", "2", "hamster",  "1.65kg", "assets/pets/hamster.jpg", 5, 0, "hamsterID")
];
