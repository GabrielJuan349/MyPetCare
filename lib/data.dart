import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart';

class Owner {
  /*
  firebaseUser contains: displayName, email, isEmailVerified, isAnonymous
  metadata, phoneNumber, photoURL, refreshToken, uid
  Now we're only using email password authentication
  So we'll only get from firebaseUser: email, uid, refreshToken
   */
  late User firebaseUser;
  late String name, surname, clinicInfo, phoneNumber, locality, accountType;

  Owner(this.firebaseUser);

  void setUserData(
      accountType, name, surname, clinicInfo, phoneNumber, locality) {
    this.accountType = accountType;
    this.name = name;
    this.surname = surname;
    this.clinicInfo = clinicInfo;
    this.phoneNumber = phoneNumber;
    this.locality = locality;
  }

  // Get all user data
  Map<String, dynamic> getUserData() {
    return {
      'accountType': accountType,
      'userId': firebaseUser.uid,
      'email': firebaseUser.email,
      'firstName': name,
      'lastName': surname,
      'phone': phoneNumber,
      'locality': locality,
      'clinicInfo': clinicInfo,
    };
  }


  // Transform to what is defined in the database
  // This will be used to update the user data in the firestore
  // So we'll only return the fields that can be changed
  Map<String, dynamic> toJson() {
    return {
      'firstName': name,
      'lastName': surname,
      'phone': phoneNumber,
      'locality': locality,
      'clinicInfo': clinicInfo,
    };
  }
}

class OwnerModel extends ChangeNotifier {
  Owner? _owner;
  List<Pet>? _pets;

  Owner? get owner => _owner;
  List<Pet>? get pets => _pets;

  void setOwner(Owner owner) {
    _owner = owner;
    notifyListeners();
  }

  void setPets(List<Pet> pets){
    _pets = pets;
    notifyListeners();
  }

  void addPet(Pet pet){
    _pets?.add(pet);
  }

  void clearOwner() {
    _owner = null;
    _pets = null;
    notifyListeners();
  }


  void updateOwner(Owner updatedOwner) {
    _owner = updatedOwner;
    notifyListeners();
    print("Owner updated: ${_owner?.name}");
  }
}


Future<void> setGlobalUser(BuildContext context) async{
  if(Provider.of<OwnerModel>(context, listen: false).owner == null){
    final firebaseUser = FirebaseAuth.instance.currentUser;
    Owner owner = Owner(firebaseUser!);
    await getUserInfo(owner);
    // Save user locally with Provider.
    Provider.of<OwnerModel>(context, listen: false).setOwner(owner);
  }
}

class Clinic {
  final String id;
  final String name;
  final String address;
  final String city;
  final String cp;
  final String email;
  final String phone;
  final String website;
  final List<String> categories;
  final List<String> geolocation;
  double parseCoordinate(String coord) {
    final pattern = RegExp(r'([0-9.]+)º?\s*([NSEW])', caseSensitive: false);
    final match = pattern.firstMatch(coord.trim());
    if (match != null) {
      double value = double.parse(match.group(1)!);
      String direction = match.group(2)!.toUpperCase();

      if (direction == 'S' || direction == 'W') {
        value = -value;
      }
      return value;
    } else {
      throw FormatException('Formato inválido para coordenada: $coord');
    }
  }
  double get latitude => parseCoordinate(geolocation[0]);
  double get longitude => parseCoordinate(geolocation[1]);

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.cp,
    required this.email,
    required this.phone,
    required this.website,
    required this.categories,
    required this.geolocation,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      cp: json['cp'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      categories: List<String>.from(json['categories'] ?? []),
      geolocation: List<String>.from(json['geolocation'] ?? []),
    );
  }
}
