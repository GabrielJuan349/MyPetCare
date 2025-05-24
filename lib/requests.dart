import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lis_project/pet.dart';
import 'package:lis_project/data.dart';
import 'prescription.dart';
import 'report.dart';

// Change to the url of your actual backend
const String BASE_URL = "http://localhost:6055";
// const String BASE_URL = "http://10.0.2.2:6055";

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

Future<Map<String, dynamic>?> validateUser(String uid) async {
  try {
    final uri = Uri.parse("$BASE_URL/user/$uid");
    final responseBody = await sendRequest(uri, "GET");
    final Map<String, dynamic> userMap = json.decode(responseBody);

    final accountType = userMap['accountType'];
    if (accountType != 'Pet owner') {
      return null; // Usuario no válido
    }

    return userMap; // Usuario válido
  } catch (e) {
    print("Error fetching user info: $e");
    return null;
  }
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
  final url = Uri.parse("$BASE_URL/api/pet/$petId");
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

Future<List<dynamic>> getAllNews() async{
  final uri = Uri.parse('$BASE_URL/api/getAllNews');
  final response = await sendRequest(uri, "GET");
  return json.decode(response);
}

Future<List<Map<String, dynamic>>> getAdoptionsByClinic(String clinicId) async {
  final url = Uri.parse("$BASE_URL/api/getAdoptionsByClinic/$clinicId");

  final response = await http.get(url);
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception("Failed to fetch adoptions from clinic $clinicId");
  }
}

Future<List<Prescription>> fetchPrescriptions(String petId) async {
  final response = await http.get(
    Uri.parse('$BASE_URL/api/getPrescriptionByPet/pet/$petId'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Prescription.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las recetas');
  }
}

Future<void> deletePrescription(String id) async {
  final response = await http.delete(
    Uri.parse('$BASE_URL/api/deletePrescription/$id'),
  );

  if (response.statusCode != 200) {
    print('❌ Error al eliminar la receta con id: $id');
  } else {
    print('✅ Receta eliminada: $id');
  }
}

Future<List<ReportMessage>> getReportsByPet(String petId) async {
  final uri = Uri.parse('$BASE_URL/api/getReportsByPet/pet/$petId');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ReportMessage.fromJson(json)).toList();
  } else {
    throw Exception('Error del servidor al obtener los reportes');
  }
}

Future<List<dynamic>> getAppointmentsByUserId(String userId) async{
  final uri = Uri.parse('$BASE_URL/api/appointmentsByUser/$userId');
  final response = await sendRequest(uri, "GET");
  //TODO: Hardcoded, change linking to back
  //return json.decode(response);
  // Hard coded
  return [
    {
      'date': '24/05/2025',
      'time': '10:15',
      'reason': 'Moquillo canino',
      'type': 'Vaccination',
      'pet': 'Firu',
      'vet': 'Anna',
    },
    {
      'date': '30/05/2025',
      'time': '16:30',
      'reason': 'Vomiting and diarrhea',
      'type': 'Sick visit',
      'pet': "Firu",
      'vet': 'Jacob',
    },
    {
      'date': '03/06/2025',
      'time': '09:00',
      'reason': 'Dental cleaning',
      'type': 'General checkup',
      'pet': "Firu",
      'vet': 'Sandy',
    },
  ];
}

Future<List<String>> getAppointmentsByClinicId(String clinicId,
    DateTime date) async{
  final uri = Uri.parse('$BASE_URL/api/appointmentsByClinic/$clinicId');
  final response = await sendRequest(uri, "GET");
  // TODO: Connect with back
  return[
    "09:00",
    "12:15",
    "13:30",
    "16:45",
  ];
}

Future<List> getVetsById(String clinicId) async{
  final uri = Uri.parse('$BASE_URL/api/getVetsByClinic/$clinicId');
  final response = await sendRequest(uri, "GET");
  final List<dynamic> data = json.decode(response);
  return data.map((item) => Vet.fromJson(item)).toList();
}