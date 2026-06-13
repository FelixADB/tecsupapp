import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/models/empleado.dart';
import 'package:crud_test/providers/empresa_provider.dart';
import 'package:crud_test/providers/empleado_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _empresaId;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) { 
      final empresa = ModalRoute.of(context)!.settings.arguments as Empresa;
      _empresaId = empresa.id!;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<EmpresaProvider>(context, listen: false).clearError();
        Provider.of<EmpleadoProvider>(context, listen: false).loadEmpleados(_empresaId);
      });
      _isInit = true;
    }
  }

  Future<void> _confirmDelete(BuildContext context, int id, String nombre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Eliminación', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar "$nombre"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empresa eliminada'), backgroundColor: Colors.green));
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      } catch (e) {
        // Manejado por el provider
      }
    }
  }

  Future<void> _confirmDeleteEmpleado(BuildContext context, int id, String nombre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Desvincular Empleado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que deseas eliminar a "$nombre"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // ignore: use_build_context_synchronously
        await Provider.of<EmpleadoProvider>(context, listen: false).remove(id);
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empleado eliminado'), backgroundColor: Colors.green)
          );
        }
      } catch (e) {
        // El proveedor ya se encarga
      }
    }
  }

  void _mostrarFormularioEmpleado(BuildContext context, int idEmpresa) {
    final nombreCtrl = TextEditingController();
    final cargoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Registrar Empleado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 10),
            TextField(controller: cargoCtrl, decoration: const InputDecoration(labelText: 'Cargo / Puesto')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              if (nombreCtrl.text.isEmpty || cargoCtrl.text.isEmpty) return;
              final nuevoEmp = Empleado(nombre: nombreCtrl.text, cargo: cargoCtrl.text, empresaId: idEmpresa);
              await Provider.of<EmpleadoProvider>(context, listen: false).add(nuevoEmp);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmpresaProvider>(context);
    final isLoading = provider.isLoading;

    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: Colors.redAccent, onVisible: () => provider.clearError()),
        );
      });
    }

    final empresaActual = provider.empresas.firstWhere((e) => e.id == _empresaId, orElse: () => Empresa(id: -1, nombre: 'No encontrada', ruc: ''));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black87,
        title: const Text('Detalles', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _mostrarFormularioEmpleado(context, _empresaId),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(empresaActual.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.numbers, "RUC", empresaActual.ruc),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on_outlined, "Dirección", empresaActual.direccion ?? '-'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.category_outlined, "Rubro", empresaActual.rubro ?? '-'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: BorderSide(color: Colors.indigo.shade100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar'),
                        onPressed: isLoading ? null : () => Navigator.pushNamed(context, "/form", arguments: empresaActual),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.red.shade100),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text("Eliminar"),
                        onPressed: isLoading ? null : () => _confirmDelete(context, empresaActual.id!, empresaActual.nombre),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 8.0, top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Empleados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ),

          Expanded(
            child: Consumer<EmpleadoProvider>(
              builder: (context, empProvider, child) {
                if (empProvider.isLoading) return const Center(child: CircularProgressIndicator());
                if (empProvider.empleados.isEmpty) return Center(child: Text('No hay empleados registrados.', style: TextStyle(color: Colors.grey.shade500)));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: empProvider.empleados.length,
                  itemBuilder: (context, index) {
                    final empleado = empProvider.empleados[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: Text(empleado.nombre[0].toUpperCase(), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(empleado.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(empleado.cargo, style: TextStyle(color: Colors.grey.shade600)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDeleteEmpleado(context, empleado.id!, empleado.nombre),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}