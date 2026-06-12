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
        return true;
      } catch (e) {
        // Error will be shown by provider.errorMessage listener
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => provider.buscarEmpresa(value),
              decoration: InputDecoration(
                labelText: 'Buscar por Nombre o RUC',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (provider.isLoading) LinearProgressIndicator(),
          Expanded(
            child: provider.empresas.isEmpty
                ? const Center(child: Text('No hay empresas registradas'))
                : RefreshIndicator(
                    onRefresh: () async {
                      // Esto se ejecuta al jalar la lista hacia abajo
                      await provider.load(); 
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: provider.empresas.length,
                      itemBuilder: (_, i) {
                        final Empresa e = provider.empresas[i];
                        
                        // 3. NUEVO: Envolvemos la Card en un Dismissible
                        return Dismissible(
                          key: Key(e.id.toString()), // Llave única obligatoria
                          direction: DismissDirection.endToStart, // Solo deslizar de derecha a izquierda
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: const Icon(Icons.delete, color: Colors.white, size: 30),
                          ),
                          // Confirmación antes de borrar al deslizar
                          confirmDismiss: (direction) async {
                            return await _confirmDelete(context, e.id!, e.nombre);
                          },
                          // El contenido original (tu Card se mantiene igual, solo le quitamos el botón de borrar porque ya se hace deslizando)
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                            child: ListTile(
                              title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("RUC: ${e.ruc}"),
                              onTap: () => Navigator.pushNamed(context, "/detail", arguments: e),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.indigo),
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
        heroTag: null,
        onPressed: provider.isLoading ? null : () => Navigator.pushNamed(context, "/form"),
        child: Icon(Icons.add),
      ),
    );
  }
}
