import 'package:crud_test/models/empleado.dart';
import 'package:crud_test/services/api_service.dart';
import 'package:flutter/material.dart';

class EmpleadoProvider with ChangeNotifier {
  List<Empleado> _empleados = [];
  List<Empleado> get empleados => _empleados;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadEmpleados(int empresaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _empleados = await ApiService.getEmpleados(empresaId);
    } catch (e) {
      print(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Empleado e) async {
    _isLoading = true;
    notifyListeners();
    try {
      final nuevo = await ApiService.createEmpleado(e);
      _empleados.add(nuevo);
    } catch (e) {
      print(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}