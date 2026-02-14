import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/lead_model.dart';

class LeadRepository {
  // 🌍 Universal Base URL
  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  static String get baseUrl => "$_base/api";

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
