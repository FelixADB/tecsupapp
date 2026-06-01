# Progreso del Proyecto CRUD - Registro de Cambios

## Fecha de Inicio
29 de Mayo, 2026

## Fase 1 - Estabilidad y Correcciones Críticas ✅
**Completada:** 29 de Mayo, 2026 (Actualizado: Corrección de Hero tag, edición y UI)

### 1.1 Corrección de Bugs
- **Bug en EmpresaProvider.dart:23** (`lib/providers/empresa_provider.dart`)
  - Problema: Condición `if (i != i)` siempre evaluaba a false
  - Solución: Cambiado a `if (i != -1)` para buscar correctamente el índice
  - Esto impedía que las actualizaciones se reflejaran en la lista

- **Error setState() during build** (29/05/2026)
  - Problema: `setState() or markNeedsBuild() called during build` al realizar acciones
  - Causa: Llamadas a `provider.clearError()` dentro del método `build()` y en `didChangeDependencies()` sin `addPostFrameCallback`
  - Solución:
    - **list_screen.dart**: Movido `provider.clearError()` dentro de `onVisible` del SnackBar
    - **detail_screen.dart**: Movido `provider.clearError()` a `addPostFrameCallback` en `didChangeDependencies()` y dentro de `onVisible` en el SnackBar
    - **form_screen.dart**: Movido `provider.clearError()` a `addPostFrameCallback` en `didChangeDependencies()`
  - Esto asegura que `clearError()` se ejecute después de completar el frame de construcción

### 1.2 Gestión de Memoria
- **Liberación de controllers** (`lib/screens/form_screen.dart`)
  - Añadido método `dispose()` para liberar `TextEditingController`
  - Prevención de memory leaks en pantalla de formulario

### 1.3 Estados de Carga (Loading States)
- **Agregado isLoading al EmpresaProvider**
  - Nueva variable privada `_isLoading` con getter público
  - Método `_setLoading(bool)` para notificar cambios
  - Todos los métodos CRUD envuelven operaciones async con loading

- **Implementación en pantallas**
  - `ListScreen`: `LinearProgressIndicator` en la parte superior
  - `FormScreen`: Botón deshabilitado durante carga con spinner
  - `DetailScreen`: Progress indicator durante operaciones
  - FAB oculta cuando hay loading en `ListScreen`

### 1.4 Manejo de Errores Mejorado
- **Variables de error en provider**
  - Nueva variable `_errorMessage` con getter y método `clearError()`
  
- **Snackbars para feedback**
  - Snackbar rojo para errores (conexión, validación, server)
  - Snackbar verde para éxito (guardar, eliminar)
  - Auto-limpiado después de mostrar error

- **Try-catch en UI**
  - Todas las operaciones CRUD capturadas en try-catch
  - Los errores se propagan al provider para mostrarse

### 1.5 Confirmación de Eliminación
- **Dialog de confirmación**
  - Implementado en `ListScreen` mediante método `_confirmDelete()`
  - También en `DetailScreen` con el mismo método
  - Dialog con opciones: "Cancelar" (estilo normal) y "Eliminar" (rojo)
  - Solo elimina si el usuario confirma

### 1.6 Mejoras en API Service
- **Manejo de try-catch implícito**
  - El provider ya captura todos los errores de ApiService
  - No se requieren cambios adicionales en el servicio actual

### 1.7 Tests Actualizados
- **`test/widget_test.dart`**
  - Test renombrado y actualizado: "App loads and shows Empresas screen"
  - Verifica que:
    - La app carga correctamente
    - Muestra título "Empresas"
    - Muestra mensaje de Empty State
    - Presencia del botón flotante (FAB)

### 1.8 Mejoras de UX/UI (29/05/2026)
- **Problema de edición en FormScreen**
  - Problema: `didChangeDependencies()` se ejecutaba en cada reconstrucción, reseteando los `TextEditingController` y perdiendo los cambios del usuario al editar.
  - Solución: Agregado flag `_initialized` en `_FormScreenState` para cargar datos solo la primera vez. Ahora la edición funciona correctamente sin resetear valores (`lib/screens/form_screen.dart:23, 46-54`).

- **Actualización no reflejada en DetailScreen**
  - Problema: Al editar una empresa desde DetailScreen y regresar, los cambios no se veían reflejados. Esto ocurría porque DetailScreen guardaba un snapshot estático de la empresa en `_empresa` durante `didChangeDependencies()` y nunca se actualizaba.
  - Solución: Cambiado de guardar objeto completo a guardar solo el ID (`_empresaId`). En cada `build()`, se busca la empresa actual desde `provider.empresas` usando el ID. Esto asegura que siempre se muestre la versión más reciente del provider.
  - Beneficio: Al regresar del FormScreen, el DetailScreen se reconstruye y obtiene los datos actualizados automáticamente.
  - Manejo adicional: Si la empresa fue eliminada, se muestra mensaje y se retrocede (`lib/screens/detail_screen.dart:14, 17-24, 67-104`).

- **Tarjeta de detalles demasiado amplia**
  - Problema: En `DetailScreen`, el `Card` ocupaba el 100% del ancho, makinglo excesivamente amplio en pantallas grandes.
  - Solución: Envuelto el `Card` en `Center` + `ConstrainedBox` con `maxWidth: 500`. La tarjeta ahora se adapta al contenido y es más agradable visualmente (`lib/screens/detail_screen.dart:91-96`).

- **Error de Hero tag en FloatingActionButton**
  - Problema: Al actualizar datos, aparecía excepción: "There are multiple heroes that share the same tag within a subtree" causado por el FAB en `ListScreen` que cambiaba entre `null` y widget durante loading.
  - Solución: Asignado `heroTag: null` al `FloatingActionButton` para deshabilitar animaciones Hero y evitar conflictos. Además, el FAB ahora permanece siempre en el árbol (solo se deshabilita con `onPressed: null` cuando hay carga) (`lib/screens/list_screen.dart:121-127`).

---

## Arquitectura Actual

### Estructura de Carpetas (Frontend)
```
lib/
├── main.dart
├── models/
│   └── empresa.dart
├── providers/
│   └── empresa_provider.dart
├── screens/
│   ├── screens.dart
│   ├── list_screen.dart
│   ├── form_screen.dart
│   └── detail_screen.dart
└── services/
    └── api_service.dart
```

### Estado del Provider
```dart
class EmpresaProvider with ChangeNotifier {
  List<Empresa> _empresas = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Empresa> get empresas => _empresas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // CRUD Methods
  Future<void> load()
  Future<void> add(Empresa e)
  Future<void> update(int id, Empresa e)
  Future<void> remove(int id)

  // Utilities
  void clearError()
}
```

### Stack Tecnológico
- **Frontend:** Flutter 3.9.2+ (SDK ^3.9.2)
- **State Management:** Provider 6.0.5
- **HTTP:** http 1.6.0
- **UI:** Material Design
- **Backend:** Node.js + Express + Sequelize + PostgreSQL (ruta separada)

---

## Próximos Pasos (Planificado)

### Fase 2 - Features de Navegación (Prioridad Alta)
- [ ] Búsqueda en tiempo real en ListScreen
- [ ] Pull-to-refresh
- [ ] Paginación en backend (query params)
- [ ] Ordenamiento (nombre, RUC)
- [ ] Campos adicionales en modelo (email, teléfono)
- [ ] Validación RUC más robusta (solo números)

### Fase 3 - Autenticación (Prioridad Media)
- [ ] Sistema de login en backend
- [ ] JWT middleware en Express
- [ ] Pantalla de login en Flutter
- [ ] Storage seguro de token
- [ ] Interceptor HTTP para auth headers

### Fase 4 - Mejoras de Producción (Prioridad Baja)
- [ ] Dockerizar backend y frontend
- [ ] Variables de entorno por ambiente
- [ ] Tests de integración
- [ ] Documentación API con Swagger
- [ ] CI/CD básico

---

## Notas Importantes

### Backend Endpoints
```
GET    /api/empresas        - Listar todas
POST   /api/empresas        - Crear nueva
GET    /api/empresas/:id    - Obtener por ID
PUT    /api/empresas/:id    - Actualizar
DELETE /api/empresas/:id    - Eliminar
```

### Modelo Empresa (Backend/Frontend Sincronizado)
```javascript
{
  id: Integer (PK, auto-increment)
  nombre: String (required, max 255)
  ruc: String (required, unique, 11 chars)
  direccion: String (optional)
  rubro: String (optional)
  esactivo: Boolean (default: true)
  createdAt: DateTime (auto)
  updatedAt: DateTime (auto)
}
```

### Consideraciones de Seguridad
- Backend actualmente en localhost:3000
- No hay autenticación implementada
- CORS habilitado para todos los orígenes (`cors()` sin configuración)
- Variables de entorno en `.env` (no commit en git)

### Problemas Conocidos
1. **Backend puede no estar corriendo** - Asegurarse de que el servidor Node.js esté activo en puerto 3000
2. **URL hardcodeada** - `api_service.dart` usa `localhost:3000`, cambiar a IP si se prueba en dispositivo físico
3. **Validación frontend/backfrentend desincronizada** - Solo frontend valida longitud de RUC, backend no
4. **Eliminación permanente** - No hay soft delete, se destruye el registro físicamente

---

## Checklist de Calidad Fase 1
- [x] Código compila sin errores
- [x] No hay memory leaks (controllers liberados)
- [x] Loading states en todas las operaciones
- [x] Feedback visual para usuario
- [x] Confirmación para acciones destructivas
- [x] Manejo de errores robusto
- [x] Sin errores de setState() durante build ✅
- [x] Tests actualizados y pasando
- [x] Linter activado (flutter_lints)
- [x] Edición de datos funciona sin resetear valores ✅
- [x] UI responsive y tarjetas con tamaño adecuado ✅
- [x] Sin conflictos de Hero animations ✅
- [x] DetailScreen refleja actualizaciones automáticamente ✅

---

## Contacto y Seguimiento
- **Proyecto Frontend:** `/crud_test`
- **Proyecto Backend:** `/crud_test_backend`
- **Documentación adicional:** Ver README.md en raíz

**Estado:** Fase 1 completada ✅ | Listo para Fase 2 🚀
