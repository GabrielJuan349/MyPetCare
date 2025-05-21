import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lis_project/pet.dart';
import 'package:lis_project/data.dart';

// Change to the url of your actual backend
const String BASE_URL = "http://localhost:6055";

Future<String> sendRequest(Uri uri, String action, {Map<String, dynamic>? req_body}) async{
  late final http.Response response;
  switch (action){
    case 'GET':
      response = await http.get(uri);
      break;
    case 'POST':
      response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(req_body));
      break;
    case 'PUT':
      response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(req_body));
      break;
    case 'DELETE':
      response = await http.delete(uri);
      break;
  }
  if(response.statusCode == 200){
    print("statusCode=${response.statusCode}");
    print(response.body);
    return response.body;
  }else{
    print("statusCode=${response.statusCode}");
    //throw Exception('Failed to get answer to endpoint $uri');
    print("statusCode=${response.statusCode}");
    print(response.body);
    return response.body;
  }
}


Future<String> updateUserInfo(String userId, Map<String, dynamic>? body) async{
  Uri uri = Uri.parse("$BASE_URL/user/$userId");
  final String responseBody = await sendRequest(uri, "PUT", req_body: body);
  return responseBody;
}

Future deleteUser(String userId) async{
  Uri uri = Uri.parse("$BASE_URL/user/$userId");
  final String responseBody = await sendRequest(uri, "DELETE");
  return responseBody;
}

Future<String> addUser(Map<String, dynamic>? body) async{
  Uri uri = Uri.parse("$BASE_URL/api/registerUser");
  final String responseBody = await sendRequest(uri, "POST", req_body: body);
  return responseBody;
}

Future<void> getUserInfo(Owner owner) async{
  Uri uri = Uri.parse("$BASE_URL/user/${owner.firebaseUser.uid}");
  print("Parsed url is $uri");
  final responseBody = await sendRequest(uri, "GET");
  final Map<String, dynamic> userMap = json.decode(responseBody);
  owner.setUserData(
      userMap['accountType'] ?? "user",
      userMap['firstName'] ?? "unknown",
      userMap['lastName'] ?? "unknown",
      userMap['clinicInfo'] ?? "unknown",
      userMap['phone'] ?? "unknown",
      userMap['locality'] ?? "unknown",
  );
}

Future<List<Pet>> getUserPets(String userId) async {
  Uri uri = Uri.parse("$BASE_URL/api/getPet/$userId");
  final responseBody = await sendRequest(uri, "GET");
  print("getUserPets result:$responseBody");

  try {
    final decoded = json.decode(responseBody);
    if (decoded is List) {
      return decoded.map((json) => Pet.fromJson(json)).toList();
    } else {
      print("Expected a list but got: $decoded");
      return [];
    }
  } catch (e) {
    print("Error decoding pets: $e");
    return [];
  }
}

Future<String> addPet(Map<String, dynamic>? body) async{
  Uri uri = Uri.parse("$BASE_URL/api/pet");
  final String responseBody = await sendRequest(uri, "POST", req_body: body);
  final decoded = json.decode(responseBody);

  return decoded["id"];
}

Future<String> updatePet(String petId, Map<String, dynamic>? body) async{
  Uri uri = Uri.parse("$BASE_URL/api/pet/$petId");
  final String responseBody = await sendRequest(uri, "PUT", req_body: body);
  return responseBody;
}

Future<List<Clinic>> getAllClinics() async {
  Uri uri = Uri.parse("$BASE_URL/api/getClinics");
  final responseBody = await sendRequest(uri, "GET");
  final List<dynamic> decoded = json.decode(responseBody);
  final clinics = decoded.map((json) => Clinic.fromJson(json)).toList();

  for (var clinic in clinics) {
    print("Clinic: ${clinic.name}, Latitude: ${clinic.latitude}, Longitude: ${clinic.longitude}");
  }

  return clinics;
}
Future<List<Map<String, dynamic>>> getClinics() async {
  final url = Uri.parse("$BASE_URL/api/getClinics");
  print('Requesting clinics from: $url');
  final response = await http.get(url);

  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    print('Decoded JSON: $decoded');
    return List<Map<String, dynamic>>.from(decoded);
  } else {
    throw Exception('Failed to load clinics');
  }
}


Future<void> deletePet(String petId) async {
  final url = Uri.parse("http://localhost:6055/api/pet/$petId");
  final response = await http.delete(url);

  if (response.statusCode != 200) {
    throw Exception("Failed to delete pet: ${response.body}");
  }
}

Future<List<dynamic>> getVaccinesByPetId(String petId) async {
  final uri = Uri.parse('$BASE_URL/api/getVaccineByPetID/pet/$petId');
  
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al obtener vacunas');
  }
}


Future<void> createVaccine(Map<String, String> vaccine) async {
  final uri = Uri.parse('$BASE_URL/api/vaccine');

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "Date": vaccine['Date'],
      "PetId": vaccine['PetId'],
      "name": vaccine['name'],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception("Error al crear la vacuna: ${response.body}");
  }
}



