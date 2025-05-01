import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lis_project/data.dart';
import 'package:lis_project/pet.dart';

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

Future<User> getUserInfo(String userId) async{
  Uri uri = Uri.parse("$BASE_URL/user/$userId");
  final responseBody = await sendRequest(uri, "GET");
  print("getUserInfo result:$responseBody");
  // TODO: Implement this to match the authentication part
  return User("a","b","c","d","e","f","g","h");
}

Future<List<Pet>> getUserPets(String userId) async{
  Uri uri = Uri.parse("$BASE_URL/api/getPet/$userId");
  final responseBody = await sendRequest(uri, "GET");
  print("getUserPets result:$responseBody");
  final List<dynamic> decoded = json.decode(responseBody);
  return decoded.map((json)=> Pet.fromJson(json)).toList();
}