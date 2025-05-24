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

  void setPets(List<Pet> pets) {
    _pets = pets;
    notifyListeners();
  }

  void addPet(Pet pet) {
    _pets?.add(pet);
  }

  void removePet(Pet pet){
    _pets?.remove(pet);
  }

  void updatePet(Pet pet) {
    for (int i = 0; i < _pets!.length; i++) {
      if (_pets![i].id == pet.id) {
        _pets![i] = pet;
        break;
      }
    }
    notifyListeners();
  }

  List<String> getPetNames() {
    return _pets?.map((pet) => pet.name).toList() ?? [];
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

Future<void> setGlobalUser(BuildContext context) async {
  if (Provider.of<OwnerModel>(context, listen: false).owner == null) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    Owner owner = Owner(firebaseUser!);
    await getUserInfo(owner);
    final pets = await getUserPets(owner.firebaseUser.uid);
    // Save user data locally with Provider.
    Provider.of<OwnerModel>(context, listen: false).setOwner(owner);
    Provider.of<OwnerModel>(context, listen: false).setPets(pets);
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
  final double latitude;
  final double longitude;

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
    required this.latitude,
    required this.longitude,
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
      categories: (json['categories']?['values'] as List<dynamic>?)
              ?.map((e) => e['stringValue'] as String)
              .toList() ??
          [],
      latitude: (json['latitude'] is double)
          ? json['latitude']
          : double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: (json['longitude'] is double)
          ? json['longitude']
          : double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }
}

class Vet{
  final String clinicInfo, clinicId, name, surname, accountType;
  Vet({
    required this.clinicInfo,
    required this.clinicId,
    required this.name,
    required this.surname,
    required this.accountType
  });
  factory Vet.fromJson(Map<String, dynamic> json) {
    return Vet(
      name: json['firstName'],
      surname: json['lastName'],
      accountType: json['accountType'],
      clinicInfo: json['clinicInfo'],
      clinicId: json['clinicId'],
    );
  }
}