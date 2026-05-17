# Estructura Principal de la Aplicación Markey

## Resumen

El archivo `main.dart` ha sido actualizado para implementar la estructura correcta de la aplicación Markey Password Manager, reemplazando el código de ejemplo de Flutter (contador) con el flujo de autenticación y navegación apropiado.

## Cambios Realizados

### ❌ Antes (Código de Ejemplo)
```dart
// Pantalla con contador de botones (ejemplo de Flutter)
class MyHomePage extends StatefulWidget {
  int _counter = 0;
  void _incrementCounter() { ... }
}
```

### ✅ Ahora (Aplicación Real)
```dart
// Flujo de autenticación y navegación apropiado
AppInitializer → OnboardingScreen (primera vez)
              → AuthenticationGate → LoginScreen (no autenticado)
                                  → VaultScreen (autenticado)
```

## Estructura de la Aplicación

### 1. Providers Configurados

La aplicación utiliza Provider para gestión de estado con los siguientes servicios:

```dart
MultiProvider(
  providers: [
    // Almacenamiento seguro
    Provider<SecureStorageService>
    
    // Servicio de autenticación
    Provider<AuthService>
    
    // Estado de autenticación
    ChangeNotifierProvider<AuthProvider>
    
    // Generador de contraseñas
    Provider<PasswordGeneratorService>
  ],
)
```

### 2. Flujo de Inicialización

#### AppInitializer
Widget que determina qué pantalla mostrar al iniciar:

```dart
class AppInitializer extends StatefulWidget
```

**Responsabilidades:**
- Verifica si es la primera vez que se usa la app
- Muestra indicador de carga durante la verificación
- Redirige a Onboarding o AuthenticationGate

**Lógica:**
```dart
if (primera vez) → OnboardingScreen
else → AuthenticationGate
```

### 3. Pantallas Principales

#### OnboardingScreen
Pantalla de configuración inicial para nuevos usuarios.

**Características:**
- Animación Lottie de bienvenida
- Formulario para crear contraseña maestra o PIN
- Efectos glassmorphism
- Validación de entrada

**Cuándo se muestra:**
- Primera vez que se abre la app
- No existe contraseña maestra configurada

#### AuthenticationGate
Widget que controla el acceso basado en autenticación.

**Lógica:**
```dart
Consumer<AuthProvider>(
  if (autenticado) → VaultScreen
  else → LoginScreen
)
```

#### LoginScreen
Pantalla de inicio de sesión para usuarios existentes.

**Características:**
- Autenticación con contraseña o PIN
- Opción de autenticación biométrica
- Bloqueo temporal después de 3 intentos fallidos
- Animación shake en errores

#### VaultScreen
Pantalla principal de la bóveda de contraseñas.

**Características:**
- Lista de entradas con animaciones
- Búsqueda y filtrado
- Acciones deslizables
- Navegación a otras funciones

## Flujo de Usuario

### Primera Vez (Nuevo Usuario)

```
1. App inicia
   ↓
2. AppInitializer verifica configuración
   ↓
3. No hay contraseña maestra → OnboardingScreen
   ↓
4. Usuario crea contraseña maestra/PIN
   ↓
5. AuthProvider.isAuthenticated = true
   ↓
6. AuthenticationGate → VaultScreen
```

### Usuario Existente

```
1. App inicia
   ↓
2. AppInitializer verifica configuración
   ↓
3. Existe contraseña maestra → AuthenticationGate
   ↓
4. No autenticado → LoginScreen
   ↓
5. Usuario ingresa credenciales
   ↓
6. AuthProvider.isAuthenticated = true
   ↓
7. AuthenticationGate → VaultScreen
```

### Sesión Activa

```
1. App inicia
   ↓
2. AppInitializer verifica configuración
   ↓
3. AuthenticationGate verifica estado
   ↓
4. Ya autenticado → VaultScreen directamente
```

## Navegación desde VaultScreen

Desde la pantalla principal (VaultScreen), el usuario puede navegar a:

- **Password Generator**: Generar contraseñas seguras
- **Entry Detail**: Ver/editar entradas
- **Security Analysis**: Análisis de seguridad (cuando se implemente)
- **Settings**: Configuración (cuando se implemente)
- **Notes**: Notas seguras (cuando se implemente)

## Servicios Inyectados

### SecureStorageService
Almacenamiento seguro usando `flutter_secure_storage`.

**Uso:**
- Guardar hash de contraseña maestra
- Almacenar datos cifrados
- Gestionar claves de cifrado

### AuthService
Servicio de autenticación con múltiples métodos.

**Métodos:**
- `setupMasterPassword()`: Configurar contraseña maestra
- `setupMasterPin()`: Configurar PIN maestro
- `authenticateWithPassword()`: Autenticar con contraseña
- `authenticateWithPin()`: Autenticar con PIN
- `authenticateWithBiometrics()`: Autenticar con biometría
- `isAuthenticated()`: Verificar estado de autenticación

### PasswordGeneratorService
Generador de contraseñas seguras.

**Métodos:**
- `generate()`: Generar contraseña con configuración
- `evaluateStrength()`: Evaluar fortaleza de contraseña

## Temas

La aplicación soporta modo claro y oscuro:

```dart
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.system,  // Sigue configuración del sistema
```

## Seguridad

### Autenticación
- Hash de contraseñas con PBKDF2 (100,000 iteraciones)
- Bloqueo temporal después de 3 intentos fallidos
- Soporte para autenticación biométrica

### Almacenamiento
- Todos los datos sensibles cifrados con AES-256
- Claves almacenadas en almacenamiento seguro del sistema
- Datos en memoria solo durante sesión activa

## Testing

Para probar la aplicación:

```bash
# Ejecutar la app
flutter run

# Primera vez: verás OnboardingScreen
# Configura contraseña maestra

# Reinicia la app
# Verás LoginScreen
# Ingresa credenciales

# Accederás a VaultScreen
```

## Próximos Pasos

Pantallas pendientes de implementación:
- [ ] Security Analysis Screen (Tarea 26)
- [ ] Settings Screen (Tarea 27)
- [ ] Secure Notes Screen (Tarea 28)
- [ ] Navigation and Routing (Tarea 30)

## Notas Importantes

1. **No más contador**: El código de ejemplo de Flutter ha sido completamente reemplazado
2. **Flujo completo**: La app ahora tiene un flujo de autenticación real
3. **Providers configurados**: Todos los servicios necesarios están disponibles
4. **Listo para desarrollo**: Puedes continuar implementando las tareas restantes

## Estructura de Archivos

```
lib/
├── main.dart                          ← Actualizado ✅
├── core/
│   ├── services/
│   │   ├── secure_storage_service.dart
│   │   └── secure_storage_service_impl.dart
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── auth/
    │   ├── data/
    │   │   └── auth_service_impl.dart
    │   ├── domain/
    │   │   └── auth_service.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── auth_provider.dart
    │       └── screens/
    │           ├── onboarding_screen.dart
    │           └── login_screen.dart
    ├── generator/
    │   └── presentation/
    │       └── screens/
    │           └── password_generator_screen.dart
    └── vault/
        └── presentation/
            └── screens/
                └── vault_screen.dart
```

## Conclusión

El `main.dart` ahora implementa correctamente la estructura de la aplicación Markey Password Manager con:
- ✅ Flujo de autenticación completo
- ✅ Navegación basada en estado
- ✅ Providers configurados
- ✅ Temas claro/oscuro
- ✅ Arquitectura limpia y escalable
