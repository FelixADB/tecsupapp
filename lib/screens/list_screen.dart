import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/providers/empresa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {   
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
   
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmpresaProvider>(context, listen: false).load();
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
        }
      } catch (e) {
        // Error will be shown by provider.errorMessage listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmpresaProvider>(context);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          if (provider.isLoading) LinearProgressIndicator(),
          Expanded(
            child: provider.empresas.isEmpty
                ? Center(child: Text('No hay empresas registradas'))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: provider.empresas.length,
                    itemBuilder: (_, i) {
                      final Empresa e = provider.empresas[i];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                        child: ListTile(
                          title: Text(e.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("RUC: ${e.ruc}"),
                          onTap: () => Navigator.pushNamed(context, "/detail", arguments: e),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () => Navigator.pushNamed(context, "/form", arguments: e),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, e.id!, e.nombre),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: provider.isLoading ? null : () => Navigator.pushNamed(context, "/form"),
        child: Icon(Icons.add),
      ),
    );
  }
}
