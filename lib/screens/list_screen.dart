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

  Future<bool> _confirmDelete(BuildContext context, int id, String nombre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Eliminación', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<EmpresaProvider>(context, listen: false);
      try {
        await provider.remove(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empresa eliminada'), backgroundColor: Colors.green),
          );
        }
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmpresaProvider>(context);

    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.redAccent,
            onVisible: () => provider.clearError(),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black87,
        title: const Text('Directorio', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => provider.buscarEmpresa(value),
              decoration: InputDecoration(
                hintText: 'Buscar por Nombre o RUC',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),
          if (provider.isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: provider.empresas.isEmpty
                ? const Center(child: Text('No hay empresas registradas', style: TextStyle(color: Colors.grey)))
                : RefreshIndicator(
                    onRefresh: () async => await provider.load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.empresas.length,
                      itemBuilder: (_, i) {
                        final Empresa e = provider.empresas[i];
                        return Dismissible(
                          key: Key(e.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async => await _confirmDelete(context, e.id!, e.nombre),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text("RUC: ${e.ruc}", style: TextStyle(color: Colors.grey.shade600)),
                              ),
                              onTap: () => Navigator.pushNamed(context, "/detail", arguments: e),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.indigo),
                                onPressed: () => Navigator.pushNamed(context, "/form", arguments: e),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: provider.isLoading ? null : () => Navigator.pushNamed(context, "/form"),
        child: const Icon(Icons.add),
      ),
    );
  }
}