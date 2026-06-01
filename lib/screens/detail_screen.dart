import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/providers/empresa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _empresaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final empresa = ModalRoute.of(context)!.settings.arguments as Empresa;
    _empresaId = empresa.id!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmpresaProvider>(context, listen: false).clearError();
    });
  }

  Future<void> _confirmDelete(BuildContext context, int id, String nombre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      final provider = Provider.of<EmpresaProvider>(context, listen: false);
      try {
        await provider.remove(id);
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Empresa eliminada'),
              backgroundColor: Colors.green,
            ),
          );
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      } catch (e) {
        // Error will be shown by provider.errorMessage listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmpresaProvider>(context);
    final isLoading = provider.isLoading;

    // Show snackbar if error exists
    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
            onVisible: () {
              provider.clearError();
            },
          ),
        );
      });
    }

    // Buscar la empresa actual por ID
    final empresaActual = provider.empresas.firstWhere(
      (e) => e.id == _empresaId,
      orElse: () => Empresa(id: -1, nombre: 'No encontrada', ruc: ''),
    );

    // Si la empresa fue eliminada, mostrar mensaje y retroceder
    if (empresaActual.id == -1 && !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Empresa no encontrada'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Empresa'),
      ),
      body: Column(
        children: [
          if (isLoading) LinearProgressIndicator(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(empresaActual.nombre, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("RUC: ${empresaActual.ruc}", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text("Direccion: ${empresaActual.direccion ?? '-'}", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        Text("Rubro: ${empresaActual.rubro ?? '-'}", style: TextStyle(fontSize: 18)),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.edit),
                              label: Text('Editar'),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pushNamed(context, "/form", arguments: empresaActual),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: Icon(Icons.delete),
                              label: Text("Eliminar"),
                              onPressed: isLoading
                                  ? null
                                  : () => _confirmDelete(context, empresaActual.id!, empresaActual.nombre),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}