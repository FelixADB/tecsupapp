import 'package:crud_test/models/empresa.dart';
import 'package:crud_test/providers/empresa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreCtrl;
  late TextEditingController rucCtrl;
  late TextEditingController direccionCtrl;
  late TextEditingController rubroCtrl;

  Empresa? empresa;
  bool _initialized = false;

   @override
   void initState(){
     super.initState();
     nombreCtrl = TextEditingController();
     rucCtrl = TextEditingController();
     direccionCtrl = TextEditingController();
     rubroCtrl = TextEditingController();
   }

   @override
   void dispose() {
     nombreCtrl.dispose();
     rucCtrl.dispose();
     direccionCtrl.dispose();
     rubroCtrl.dispose();
     super.dispose();
   }

    @override
    void didChangeDependencies(){
      super.didChangeDependencies();
      if (!_initialized) {
        empresa = ModalRoute.of(context)!.settings.arguments as Empresa?;
        if (empresa != null){
          nombreCtrl.text = empresa!.nombre;
          rucCtrl.text = empresa!.ruc;
          direccionCtrl.text = empresa!.direccion ?? "";
          rubroCtrl.text = empresa!.rubro ?? "";
        }
        _initialized = true;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<EmpresaProvider>(context, listen: false).clearError();
      });
    }

   InputDecoration _flatInputDecoration(String label) {
     return InputDecoration(
       labelText: label,
       filled: true,
       fillColor: Colors.white,
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey.shade200),
       ),
       enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey.shade200),
       ),
     );
   }

   @override
   Widget build(BuildContext context) {
     final provider = Provider.of<EmpresaProvider>(context, listen: true);
     final isLoading = provider.isLoading;
     
     return Scaffold(
       backgroundColor: Colors.grey.shade50,
       appBar: AppBar(
         elevation: 0,
         backgroundColor: Colors.grey.shade50,
         foregroundColor: Colors.black87,
         title: Text(empresa == null ? "Nueva Empresa" : "Editar Empresa", style: const TextStyle(fontWeight: FontWeight.bold)),
       ),
       body: Form(
         key: _formKey,
         child: ListView(
           padding: const EdgeInsets.all(24),
           children: [
             TextFormField(
               controller: nombreCtrl,
               decoration: _flatInputDecoration("Nombre"),
               validator: (v) => v!.isEmpty ? "Ingrese el nombre" : null,
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: rucCtrl,
               decoration: _flatInputDecoration("RUC"),
               validator: (v) => v!.length != 11 ? "Debe tener 11 digitos" : null,
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: direccionCtrl,
               decoration: _flatInputDecoration("Dirección"),
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: rubroCtrl,
               decoration: _flatInputDecoration("Rubro"),
             ),
             const SizedBox(height: 32),
             SizedBox(
               height: 50,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   elevation: 0,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 onPressed: isLoading
                     ? null
                     : () async {
                         if (_formKey.currentState!.validate()) {
                           final nueva = Empresa(
                             id: empresa?.id,
                             nombre: nombreCtrl.text,
                             ruc: rucCtrl.text,
                             direccion: direccionCtrl.text,
                             rubro: rubroCtrl.text,
                           );
                           try {
                             if (empresa == null) {
                               await provider.add(nueva);
                             } else {
                               await provider.update(empresa!.id!, nueva);
                             }
                             if (!mounted) return;
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Empresa guardada'), backgroundColor: Colors.green),
                             );
                             Navigator.pop(context);
                           } catch (e) {
                             if (mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(provider.errorMessage ?? 'Error'), backgroundColor: Colors.redAccent),
                               );
                             }
                           }
                         }
                       },
                 child: isLoading
                     ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                     : Text(empresa == null ? "Guardar" : "Actualizar", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
               ),
             ),
           ],
         ),
       ),
     );
   }
}