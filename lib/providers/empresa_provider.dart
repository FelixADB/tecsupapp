import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/services/api_service.dart';
import 'package:flutter/material.dart';

class EmpresaProvider with ChangeNotifier {
  List<Empresa> _empresas = [];
  List<Empresa> get empresas => _empresas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> load() async {
    _setLoading(true);
    _setError(null);
    try {
      _empresas = await ApiService.getEmpresas();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> add(Empresa e) async {
    _setLoading(true);
    _setError(null);
    try {
      final nuevo = await ApiService.createEmpresa(e);
      _empresas.add(nuevo);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> update(int id, Empresa e) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await ApiService.updateEmpresa(id, e);
      final i = empresas.indexWhere((x) => x.id == id);
      if (i != -1) {
        _empresas[i] = updated;
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> remove(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      await ApiService.deleteEmpresa(id);
      _empresas.removeWhere((x) => x.id == id);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}