import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/famille_membre.dart';

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  static String baseUrl = 'http://localhost/api-test/public';
  static const Duration _timeout = Duration(seconds: 12);

  static Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<ApiResult> testerConnexion() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/famille-membres'), headers: _jsonHeaders)
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: ok
            ? 'API connectée avec succès (HTTP ${response.statusCode}).'
            : (decoded['message']?.toString() ?? 'Réponse invalide.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Serveur inaccessible ($baseUrl) : $e',
      );
    }
  }

  static Future<ApiResult> inscrire(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/register'),
            headers: _jsonHeaders,
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: decoded['message']?.toString() ??
            (ok ? 'Compte créé avec succès.' : 'Échec de l\'inscription.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Erreur réseau : $e');
    }
  }

  static Future<ApiResult> seConnecter(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/login'),
            headers: _jsonHeaders,
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: decoded['message']?.toString() ??
            (ok ? 'Connexion réussie.' : 'Identifiants incorrects.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Erreur réseau : $e');
    }
  }

  static Future<List<FamilleMembre>> getFamilyMembers({
    String? query,
    String? parente,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (parente != null && parente.trim().isNotEmpty && parente != 'Tous') {
      params['parente'] = parente.trim();
    }

    final uri = Uri.parse('$baseUrl/famille-membres')
        .replace(queryParameters: params.isEmpty ? null : params);

    final response = await http.get(uri, headers: _jsonHeaders).timeout(_timeout);
    final decoded = _decodeBody(response.body);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Erreur chargement');
    }

    final rawList = decoded['data'];
    if (rawList is! List) return [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(FamilleMembre.fromJson)
        .toList();
  }

  static Future<FamilleStats> getStats() async {
    final response = await http
        .get(Uri.parse('$baseUrl/famille-membres/stats'), headers: _jsonHeaders)
        .timeout(_timeout);
    final decoded = _decodeBody(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true ||
        decoded['data'] is! Map<String, dynamic>) {
      throw Exception(decoded['message']?.toString() ?? 'Erreur statistiques');
    }
    return FamilleStats.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  static Future<ApiResult> ajouterMembre({
    required String nom,
    required String postnom,
    required String prenom,
    required String lieuNaissance,
    required String dateNaissance,
    required String parente,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/famille-membres'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'nom': nom.trim(),
              'postnom': postnom.trim(),
              'prenom': prenom.trim(),
              'lieu_naissance': lieuNaissance.trim(),
              'date_naissance': dateNaissance.trim(),
              'parente': parente.trim(),
            }),
          )
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: decoded['message']?.toString() ??
            (ok ? 'Membre ajouté avec succès.' : 'Échec de l\'ajout.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Erreur réseau : $e');
    }
  }

  static Future<ApiResult> modifierMembre({
    required int id,
    required String nom,
    required String postnom,
    required String prenom,
    required String lieuNaissance,
    required String dateNaissance,
    required String parente,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/famille-membres/$id'),
            headers: _jsonHeaders,
            body: jsonEncode({
              'nom': nom.trim(),
              'postnom': postnom.trim(),
              'prenom': prenom.trim(),
              'lieu_naissance': lieuNaissance.trim(),
              'date_naissance': dateNaissance.trim(),
              'parente': parente.trim(),
            }),
          )
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: decoded['message']?.toString() ??
            (ok ? 'Membre modifié avec succès.' : 'Échec de la modification.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Erreur réseau : $e');
    }
  }

  static Future<ApiResult> supprimerMembre(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/famille-membres/$id'),
            headers: _jsonHeaders,
          )
          .timeout(_timeout);
      final decoded = _decodeBody(response.body);
      final ok = response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['success'] == true;
      return ApiResult(
        success: ok,
        message: decoded['message']?.toString() ??
            (ok ? 'Membre supprimé avec succès.' : 'Échec de la suppression.'),
        data: decoded['data'],
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Erreur réseau : $e');
    }
  }

  static Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return {'success': false, 'message': 'Réponse vide du serveur.'};
    }
    try {
      final parsed = jsonDecode(body);
      return parsed is Map<String, dynamic>
          ? parsed
          : {'success': false, 'message': 'Format JSON inattendu.'};
    } catch (_) {
      return {'success': false, 'message': 'Réponse serveur non JSON.'};
    }
  }
}
