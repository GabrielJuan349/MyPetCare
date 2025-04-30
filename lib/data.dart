class User{
  late String userId, apiKey, name,
      surname,email, password,
      phoneNumber,locality;
  User(this.userId, this.apiKey,
      this.name, this.surname, this.email,
      this.password, this.phoneNumber, this.locality);
}

User defaultUser = User(
  "testuser","apiKey","Ana","Moore",
  "ana.moore@gmail.com", "kkdah2364gddvyaa", "622889134","Barcelona"
);