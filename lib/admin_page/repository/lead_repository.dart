import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/lead_model.dart';

class LeadRepository {
  final String baseUrl = "http://192.168.1.13:8000/api";

  String? token;

  LeadRepository([this.token]);  

  void updateToken(String newToken) {
    token = newToken;
    print("LeadRepository token updated → $newToken");
  }

  Future<bool> createLead(Lead lead) async {
    if (token == null || token!.isEmpty) {
      throw Exception("Token not set for LeadRepository");
    }

    final url = Uri.parse("$baseUrl/leads/");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(lead.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}

