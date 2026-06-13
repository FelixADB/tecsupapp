import 'dart:convert';

import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/models/empleado.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  //usar ip en caso de utilizar dispositivo real
  static const base = 'http://10.0.2.2:3000/api/empresas';
  //static const base = 'https://tecsupapp-backend.onrender.com/api/empresas';
  static const authBase = 'http://10.0.2.2:3000/api/auth';
  static const empleadoBase = 'http://10.0.2.2:3000/api/empleados';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<bool> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$authBase/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      return true;
    } else {
      return false; // Credenciales incorrectas
    }
  }

  static Future<List<Empresa>> getEmpresas() async {
    final res = await http.get(Uri.parse(base), headers: await _getHeaders());
    if(res.statusCode == 200){
      final List data = jsonDecode(res.body);
      return data.map((e) => Empresa.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar. Código: ${res.statusCode}');
    }
  }

  static Future<Empresa> createEmpresa(Empresa e) async {
    final res = await http.post(
      Uri.parse(base),
      headers: await _getHeaders(),
      body: json.encode(e.toJson()),
    );
    if (res.statusCode == 201) {
      return Empresa.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error al crear');
    }
  }

  static Future<Empresa> updateEmpresa(int id, Empresa e) async {
    final res = await http.put(
      Uri.parse('$base/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(e.toJson()),
    );
    if(res.statusCode == 200) {
      return Empresa.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error al actualizar');
    } 
  }

  static Future<void> deleteEmpresa(int id) async {
    final res = await http.delete(Uri.parse('$base/$id'), headers: await _getHeaders());
    if (res.statusCode != 200) throw Exception('Error al eliminar');
  }

  static Future<List<Empleado>> getEmpleados(int empresaId) async {
    final res = await http.get(Uri.parse('$empleadoBase/empresa/$empresaId'), headers: await _getHeaders());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Empleado.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar empleados');
    }
  }

  static Future<Empleado> createEmpleado(Empleado e) async {
    final res = await http.post(
      Uri.parse(empleadoBase),
      headers: await _getHeaders(),
      body: jsonEncode(e.toJson()),
    );
    if (res.statusCode == 201) {
      return Empleado.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error al registrar empleado');
    }
  }

  static Future<void> deleteEmpleado(int id) async {
    final res = await http.delete(
      Uri.parse('$empleadoBase/$id'), 
      headers: await _getHeaders()
    );
    if (res.statusCode != 200) throw Exception('Error al eliminar empleado');
  }
}