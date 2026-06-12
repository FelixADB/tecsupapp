import 'package:crud_test/providers/empresa_provider.dart';
import 'package:crud_test/providers/empleado_provider.dart';
import 'package:crud_test/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
        ChangeNotifierProvider(create: (_) => EmpleadoProvider()), // NUEVO
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Registro de Empresas',
        theme: ThemeData(primarySwatch: Colors.indigo),
        initialRoute: '/',
        routes: {
          '/' : (context) => const LoginScreen(),
          '/home' : (context) => ListScreen(),
          '/form' : (context) => FormScreen(),
          '/detail' : (context) => DetailScreen()
        },
      ),
    );
  }
}
