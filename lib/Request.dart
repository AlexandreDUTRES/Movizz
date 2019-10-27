import 'dart:async';
import 'dart:convert';
import 'package:Movizz/all_translations.dart';

import 'package:http/http.dart' as http;

final apiKey = "061e411e417766bfc7b370d08d2fbd49";
final apiUrl = "https://api.themoviedb.org/3";

enum RequestType{
  get,
  post,
  put,
  delete
}

Future<Post> fetchPost(RequestType type, String route, Map<String, String> options) async {
  var response;
  var language = allTranslations.currentLanguage;
  var completeUrl = apiUrl + route + "?api_key=" + apiKey + "&language=" + language;

  const _invariableOptions = {
    "include_adult": "false",
    "include_video": "false"
  };
  completeUrl += generateStringUrlOptions(_invariableOptions);
  completeUrl += generateStringUrlOptions(options);

  print(completeUrl);

  switch (type) {
    case RequestType.get:
      response = await http.get(completeUrl);
      break;
    case RequestType.post:
      response = await http.post(completeUrl);
      break;
    case RequestType.put:
      response = await http.put(completeUrl);
      break;
    case RequestType.delete:
      response = await http.delete(completeUrl);
      break;
  }

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Post.fromJson(json.decode(response.body), response.statusCode);
  } else {
    // If that call was not successful, throw an error.
    return Post.fromJson({}, 499);
  }
}

String generateStringUrlOptions(Map<String,String> options) {
  String _finalString = "";

  options.forEach((key, value) {
    _finalString += '&$key=$value';
  });

  return _finalString;
}

class Post {
  final Map<String, dynamic> body;
  final int status;


  Post({this.body, this.status});


  factory Post.fromJson(Map<String, dynamic> body, int status) {
    return Post(
      status: status,
      body: body,
    );
  }
}