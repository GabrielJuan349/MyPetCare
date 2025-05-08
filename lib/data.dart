import 'package:firebase_auth/firebase_auth.dart';

class Owner{
  // firebaseUser contains: displayName, email, isEmailVerified, isAnonymous
  // metadata, phoneNumber, photoURL, refreshToken, uid
  // Now we're only using email password authentication
  // So we'll only get from firebaseUser: email, uid, refreshToken
  late User firebaseUser;
  late String name, surname, clinicInfo, phoneNumber, locality, accountType;
  Owner(this.firebaseUser);

  void addData(accountType,name, surname, clinicInfo, phoneNumber, locality){
    this.accountType = accountType;
    this.name = name;
    this.surname = surname;
    this.clinicInfo = clinicInfo;
    this.phoneNumber = phoneNumber;
    this.locality = locality;
  }

  Map<String, dynamic> getUserData(){
    return{
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
  Map<String, dynamic> toJson(){
    return{
      'firstName': name,
      'lastName': surname,
      'phone': phoneNumber,
      'locality': locality,
      'clinicInfo': clinicInfo,
    };
  }
}