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
      // Clear any previous errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<EmpresaProvider>(context, listen: false).clearError();
      });
    }

   @override
   Widget build(BuildContext context) {
     final provider = Provider.of<EmpresaProvider>(context, listen: true);
     final isLoading = provider.isLoading;
     
     return Scaffold(
       appBar: AppBar(
         title: Text(empresa == null ? "Nueva Empresa" : "Editar empresa"),
       ),
       body: Padding(
         padding: EdgeInsetsGeometry.all(16),
         child: Form(
           key: _formKey,
           child: ListView(
             children: [
               TextFormField(
                 controller: nombreCtrl,
                 decoration: InputDecoration(labelText: "Nombre"),
                 validator: (v) => v!.isEmpty ? "Ingrese su nombre" : null,
               ),
               SizedBox(height: 16),
               TextFormField(
                 controller: rucCtrl,
                 decoration: InputDecoration(labelText: "RUC"),
                 validator: (v) => v!.length != 11 ? "Debe tener 11 digitos" : null,
               ),
               SizedBox(height: 16),
               TextFormField(
                 controller: direccionCtrl,
                 decoration: InputDecoration(labelText: "Direccion"),
               ),
               SizedBox(height: 16),
               TextFormField(
                 controller: rubroCtrl,
                 decoration: InputDecoration(labelText: "Rubro"),
               ),
               SizedBox(height: 25),
               ElevatedButton(
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
                             // ignore: use_build_context_synchronously
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('Empresa guardada'),
                                 backgroundColor: Colors.green,
                               ),
                             );
                             // ignore: use_build_context_synchronously
                             Navigator.pop(context);
                           } catch (e) {
                             if (mounted) {
                               // ignore: use_build_context_synchronously
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(provider.errorMessage ?? 'Error al guardar'),
                                   backgroundColor: Colors.red,
                                 ),
                               );
                             }
                           }
                         }
                       },
                 child: isLoading
                     ? SizedBox(
                         height: 20,
                         width: 20,
                         child: CircularProgressIndicator(
                           strokeWidth: 2,
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                         ),
                       )
                     : Text(
                         empresa == null ? "Guardar" : "Actualizar",
                         style: TextStyle(fontSize: 18),
                       ),
                 ),
             ],
           ),
         ),
       ),
     );
   }
}