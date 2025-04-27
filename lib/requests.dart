import 'dart:convert';

import 'package:http/http.dart' as http;

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