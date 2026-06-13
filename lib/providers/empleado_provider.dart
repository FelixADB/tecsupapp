import 'package:crud_test/models/empleado.dart';
import 'package:crud_test/services/api_service.dart';
import 'package:flutter/material.dart';

class EmpleadoProvider with ChangeNotifier {
  List<Empleado> _empleados = [];
  List<Empleado> get empleados => _empleados;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadEmpleados(int empresaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _empleados = await ApiService.getEmpleados(empresaId);
    } catch (e) {
      _errorMessage = 'Error al cargar empleados: ${e.toString()}';
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
      _errorMessage = 'Error al guardar empleado: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> remove(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await ApiService.deleteEmpleado(id);
      _empleados.removeWhere((x) => x.id == id);
    } catch (e) {
      _errorMessage = 'Error al eliminar empleado: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}