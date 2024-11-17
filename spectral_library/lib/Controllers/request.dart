import 'dart:convert';
import 'dart:io';

import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:http/http.dart' as http;

class Request {
  static String address = "https://localhost:7086/api";
  
  static Future<Response> get(User user, String url) async {
    try {
      final response = await http.get(Uri.parse('$address/$url'), headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${user.token}'
      });
      return Response.fromMap(jsonDecode(response.body));
    } catch (e) {
      if (e is SocketException) {
        return Response.fail(e.message.toString());
      } else {
        return Response.fail(e.toString());
      }
    }
  }

  static Future<Response> post(User user, String url, var body) async {
    try {
      final response = await http.post(Uri.parse('$address/$url'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer ${user.token}'
          },
          body: jsonEncode(body.toMap()));
      return Response.fromMap(jsonDecode(response.body));
    } catch (e) {
      if (e is SocketException) {
        return Response.fail(e.message.toString());
      } else {
        return Response.fail(e.toString());
      }
    }
  }

  static Future<Response> put(User user, String url, var body) async {
    try {
      final response = await http.put(Uri.parse('$address/$url'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer ${user.token}'
          },
          body: jsonEncode(body.toMap()));
      return Response.fromMap(jsonDecode(response.body));
    } catch (e) {
      if (e is SocketException) {
        return Response.fail(e.message.toString());
      } else {
        return Response.fail(e.toString());
      }
    }
  }
}
