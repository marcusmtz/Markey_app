# Plan de Implementación: Markey Password Manager

## Resumen

Este plan desglosa la implementación de Markey Password Manager en tareas incrementales y manejables. Cada tarea construye sobre las anteriores, asegurando que el código se integre continuamente y que la funcionalidad core se valide temprano mediante tests.

## Tareas

- [x] 1. Configurar estructura del proyecto y dependencias
  - Crear proyecto Flutter con estructura Clean Architecture
  - Añadir todas las dependencias necesarias al pubspec.yaml
  - Configurar carpetas: core/, features/ con subcarpetas data/domain/presentation
  - Configurar tema base con soporte para modo claro/oscuro
  - _Requisitos: 13.1, 15.1_

- [x] 2. Implementar sistema de cifrado
  - [x] 2.1 Crear EncryptionService con cifrado AES-256-GCM
    - Implementar métodos encrypt() y decrypt() para strings
    - Implementar encryptBytes() y decryptBytes() para archivos
    - Implementar derivación de clave con PBKDF2 (100,000 iteraciones)
    - Generar salt e IV aleatorios para cada operación
    - Formato de salida: salt:iv:ciphertext:tag
    - _Requisitos: 1.1, 1.4_
  
  - [ ]* 2.2 Escribir test de propiedad para cifrado round-trip
    - **Propiedad 1: Round-trip de Cifrado y Descifrado**
    - **Valida: Requisitos 1.1, 1.3, 9.2, 9.4, 14.1**
  
  - [ ]* 2.3 Escribir tests unitarios para casos edge de cifrado
    - Cifrado de cadena vacía
    - Cifrado con caracteres especiales y Unicode
    - Descifrado con clave incorrecta debe fallar
    - Validar formato de salida
    - _Requisitos: 1.1_

- [x] 3. Implementar sistema de almacenamiento seguro
  - [x] 3.1 Crear SecureStorageService usando flutter_secure_storage
    - Implementar métodos para guardar/leer datos cifrados
    - Implementar gestión de claves (master_password_hash, encryption_salt)
    - Manejar errores de almacenamiento no disponible
    - _Requisitos: 1.2, 1.5_
  
  - [ ]* 3.2 Escribir test de propiedad para persistencia
    - **Propiedad 2: Persistencia de Datos**
    - **Valida: Requisitos 1.2, 5.2**
  
  - [ ]* 3.3 Escribir test unitario para almacenamiento no disponible
    - Simular fallo de almacenamiento
    - Verificar que se muestra error y no se permiten operaciones
    - _Requisitos: 1.5_


- [x] 4. Implementar sistema de autenticación
  - [x] 4.1 Crear AuthService con gestión de contraseña maestra y PIN
    - Implementar setupMasterPassword() y setupMasterPin()
    - Implementar authenticateWithPassword() y authenticateWithPin()
    - Usar Argon2 o bcrypt para hash de contraseñas
    - Implementar contador de intentos fallidos y bloqueo temporal
    - Mantener estado de sesión en memoria
    - _Requisitos: 2.1, 2.2, 2.4, 2.5_
  
  - [x] 4.2 Integrar autenticación biométrica con local_auth
    - Implementar isBiometricsAvailable()
    - Implementar authenticateWithBiometrics()
    - Implementar enable/disableBiometrics()
    - _Requisitos: 2.3_
  
  - [ ]* 4.3 Escribir test de propiedad para autenticación requerida
    - **Propiedad 3: Autenticación Requerida para Acceso**
    - **Valida: Requisitos 2.2, 2.5**
  
  - [ ]* 4.4 Escribir test unitario para bloqueo después de 3 intentos
    - Simular 3 intentos fallidos consecutivos
    - Verificar bloqueo de 30 segundos
    - _Requisitos: 2.4_

- [x] 5. Implementar modelos de datos y entidades
  - [x] 5.1 Crear entidades de dominio
    - Crear clase Entry con todos los campos
    - Crear clase Category con predefinidas
    - Crear clase PasswordHistory
    - Crear clase AppSettings con valores por defecto
    - _Requisitos: 5.2, 17.1, 28.1, 28.2_
  
  - [x] 5.2 Crear modelos de datos con serialización JSON
    - Crear EntryModel con toJson/fromJson
    - Crear CategoryModel con toJson/fromJson
    - Crear SettingsModel con toJson/fromJson
    - _Requisitos: 5.2_

- [x] 6. Implementar repositorio de entradas (Vault)
  - [x] 6.1 Crear VaultRepository con operaciones CRUD
    - Implementar createEntry() con validación de campos obligatorios
    - Implementar updateEntry() con gestión de historial
    - Implementar deleteEntry()
    - Implementar getAllEntries() y getEntryById()
    - Integrar con EncryptionService y SecureStorageService
    - _Requisitos: 5.1, 5.2, 5.3, 5.4_
  
  - [ ]* 6.2 Escribir test de propiedad para validación de campos obligatorios
    - **Propiedad 9: Validación de Entrada Requiere Campos Obligatorios**
    - **Valida: Requisitos 5.1**
  
  - [ ]* 6.3 Escribir test de propiedad para historial de contraseñas
    - **Propiedad 10: Edición Preserva Historial de Contraseñas**
    - **Valida: Requisitos 5.3, 11.1**
  
  - [ ]* 6.4 Escribir tests unitarios para operaciones CRUD
    - Crear entrada con campos mínimos
    - Actualizar entrada existente
    - Eliminar entrada
    - Buscar entrada inexistente retorna error
    - _Requisitos: 5.1, 5.2, 5.3, 5.4_

- [x] 7. Checkpoint - Verificar funcionalidad core
  - Asegurar que todos los tests pasen
  - Verificar que cifrado, almacenamiento y autenticación funcionan correctamente
  - Preguntar al usuario si hay dudas o problemas

- [x] 8. Implementar búsqueda y filtrado
  - [x] 8.1 Añadir métodos de búsqueda al VaultRepository
    - Implementar searchEntries() con búsqueda en múltiples campos
    - Implementar getEntriesByCategory()
    - Implementar lógica de filtros combinados (AND)
    - Implementar ordenamiento por relevancia y fecha
    - _Requisitos: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ]* 8.2 Escribir test de propiedad para búsqueda
    - **Propiedad 11: Búsqueda Retorna Coincidencias Correctas**
    - **Valida: Requisitos 6.2, 9.5**
  
  - [ ]* 8.3 Escribir test de propiedad para filtro por categoría
    - **Propiedad 12: Filtro por Categoría es Exhaustivo**
    - **Valida: Requisitos 6.3**
  
  - [ ]* 8.4 Escribir test de propiedad para filtros múltiples
    - **Propiedad 13: Filtros Múltiples Usan Lógica AND**
    - **Valida: Requisitos 6.4**
  
  - [ ]* 8.5 Escribir test de propiedad para ordenamiento
    - **Propiedad 14: Resultados Ordenados Correctamente**
    - **Valida: Requisitos 6.5**

- [x] 9. Implementar generador de contraseñas
  - [x] 9.1 Crear PasswordGeneratorService
    - Implementar generate() con Random.secure()
    - Implementar PasswordGeneratorConfig con validación
    - Garantizar inclusión de al menos un carácter de cada tipo seleccionado
    - Implementar evaluateStrength() con cálculo de entropía
    - _Requisitos: 4.1, 4.2, 4.3, 4.5_
  
  - [ ]* 9.2 Escribir test de propiedad para generador
    - **Propiedad 7: Generador Produce Contraseñas Válidas**
    - **Valida: Requisitos 4.2, 4.3, 4.4**
  
  - [ ]* 9.3 Escribir test de propiedad para evaluador de fortaleza
    - **Propiedad 8: Evaluador de Fortaleza Retorna Valor Válido**
    - **Valida: Requisitos 4.5, 8.1**
  
  - [ ]* 9.4 Escribir tests unitarios para casos edge
    - Generar con longitud mínima (8) y máxima (64)
    - Generar solo con un tipo de carácter
    - Configuración sin tipos seleccionados debe fallar
    - _Requisitos: 4.2, 4.3_

- [x] 10. Implementar generador TOTP
  - [x] 10.1 Crear TotpService
    - Implementar generateCode() con HMAC-SHA1
    - Implementar getRemainingSeconds()
    - Implementar validateSecret() para Base32
    - Implementar parseSecretFromQR() para formato otpauth://
    - _Requisitos: 10.1, 10.2, 10.4_
  
  - [ ]* 10.2 Escribir test de propiedad para validación Base32
    - **Propiedad 20: TOTP Acepta Base32 Válido**
    - **Valida: Requisitos 10.1**
  
  - [ ]* 10.3 Escribir test de propiedad para formato de código
    - **Propiedad 21: TOTP Genera Códigos de 6 Dígitos**
    - **Valida: Requisitos 10.2**
  
  - [ ]* 10.4 Escribir test de propiedad para parsing de QR
    - **Propiedad 22: Parsing de QR TOTP**
    - **Valida: Requisitos 10.4**
  
  - [ ]* 10.5 Escribir tests unitarios
    - Generar código con secreto conocido
    - Parsear QR válido e inválido
    - _Requisitos: 10.1, 10.4_

- [x] 11. Implementar analizador de seguridad
  - [x] 11.1 Crear SecurityAnalyzerService
    - Implementar analyzePassword() con cálculo de entropía
    - Implementar analyzeVault() para detectar duplicados y débiles
    - Implementar cálculo de puntuación general (0-100)
    - Implementar isPasswordCompromised() con API Have I Been Pwned (k-anonymity)
    - _Requisitos: 8.1, 8.2, 8.3, 8.5, 16.1, 16.2_
  
  - [ ]* 11.2 Escribir test de propiedad para identificación de duplicados
    - **Propiedad 17: Análisis Identifica Duplicados**
    - **Valida: Requisitos 8.3**
  
  - [ ]* 11.3 Escribir test de propiedad para puntuación
    - **Propiedad 18: Puntuación de Seguridad en Rango Válido**
    - **Valida: Requisitos 8.5**
  
  - [ ]* 11.4 Escribir test de propiedad para resumen
    - **Propiedad 19: Resumen de Seguridad es Preciso**
    - **Valida: Requisitos 8.2**
  
  - [ ]* 11.5 Escribir tests unitarios
    - Analizar contraseña débil ("123456")
    - Analizar contraseña fuerte
    - Detectar dos contraseñas duplicadas
    - Puntuación con todas fuertes (100) y todas débiles (0)
    - _Requisitos: 8.1, 8.3, 8.5_

- [x] 12. Checkpoint - Verificar lógica de negocio
  - Asegurar que todos los tests pasen
  - Verificar que generadores y analizadores funcionan correctamente
  - Preguntar al usuario si hay dudas

- [x] 13. Implementar gestión de portapapeles
  - [x] 13.1 Crear ClipboardService
    - Implementar copyWithAutoClear() con Timer
    - Implementar clearClipboard()
    - Implementar cancelScheduledClear()
    - Cancelar timers anteriores al copiar nuevo contenido
    - _Requisitos: 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 13.2 Escribir test de propiedad para limpieza automática
    - **Propiedad 15: Portapapeles se Limpia Automáticamente**
    - **Valida: Requisitos 7.2, 7.3, 7.5, 10.5, 28.2**
  
  - [ ]* 13.3 Escribir test de propiedad para cancelación
    - **Propiedad 16: Copiar Cancela Limpieza Anterior**
    - **Valida: Requisitos 7.4**
  
  - [ ]* 13.4 Escribir test unitario para limpieza después de 30 segundos
    - Copiar texto y verificar limpieza después del tiempo
    - _Requisitos: 7.2_

- [x] 14. Implementar sistema de bloqueo automático
  - [x] 14.1 Crear AutoLockService
    - Implementar monitoreo con WidgetsBindingObserver
    - Implementar timer que se reinicia con interacciones
    - Implementar setLockDuration() con configuración personalizable
    - Emitir eventos de bloqueo via Stream
    - _Requisitos: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [ ]* 14.2 Escribir test de propiedad para configuración de tiempo
    - **Propiedad 4: Bloqueo Automático Respeta Configuración**
    - **Valida: Requisitos 3.2, 28.1**
  
  - [ ]* 14.3 Escribir test de propiedad para reinicio de timer
    - **Propiedad 5: Interacción Reinicia Timer de Inactividad**
    - **Valida: Requisitos 3.5**
  
  - [ ]* 14.4 Escribir test de propiedad para re-autenticación
    - **Propiedad 6: Bloqueo Requiere Re-autenticación**
    - **Valida: Requisitos 3.3**
  
  - [ ]* 14.5 Escribir test unitario para bloqueo después de 2 minutos
    - Verificar bloqueo con tiempo por defecto
    - _Requisitos: 3.1_

- [x] 15. Implementar sistema de respaldo y restauración
  - [x] 15.1 Crear BackupService
    - Implementar createBackup() con cifrado de todas las entradas
    - Implementar exportBackup() a almacenamiento local
    - Implementar importBackup() desde archivo
    - Implementar restoreBackup() con validación de contraseña
    - Formato JSON con versión, timestamp, salt, data cifrada
    - Manejar respaldos corruptos sin perder datos existentes
    - _Requisitos: 14.1, 14.2, 14.3, 14.4, 14.5_
  
  - [ ]* 15.2 Escribir test de propiedad para respaldo round-trip
    - **Propiedad 28: Respaldo Round-trip Preserva Datos**
    - **Valida: Requisitos 14.1, 14.4**
  
  - [ ]* 15.3 Escribir tests unitarios
    - Crear respaldo con una entrada
    - Crear respaldo con múltiples entradas
    - Restaurar con contraseña correcta
    - Restaurar con contraseña incorrecta falla
    - Restaurar respaldo corrupto falla
    - _Requisitos: 14.1, 14.4, 14.5_

- [x] 16. Implementar gestión de favoritos
  - [x] 16.1 Añadir funcionalidad de favoritos al VaultRepository
    - Implementar toggleFavorite()
    - Implementar getFavorites()
    - Implementar ordenamiento por frecuencia de uso
    - Actualizar Entry con campo isFavorite
    - _Requisitos: 12.1, 12.3, 12.5_
  
  - [ ]* 16.2 Escribir test de propiedad para toggle de favoritos
    - **Propiedad 25: Toggle de Favoritos es Consistente**
    - **Valida: Requisitos 12.1, 12.3**
  
  - [ ]* 16.3 Escribir test de propiedad para ordenamiento
    - **Propiedad 26: Favoritos Ordenados por Frecuencia**
    - **Valida: Requisitos 12.5**

- [x] 17. Implementar gestión de categorías
  - [x] 17.1 Crear CategoryRepository
    - Implementar createCategory() para categorías personalizadas
    - Implementar deleteCategory() con reasignación a "Sin categoría"
    - Implementar getEntriesCountByCategory()
    - Cargar categorías predefinidas al inicio
    - _Requisitos: 17.1, 17.2, 17.3, 17.4, 17.5_
  
  - [ ]* 17.2 Escribir test de propiedad para persistencia de categorías
    - **Propiedad 29: Categorías Personalizadas Persistentes**
    - **Valida: Requisitos 17.3**
  
  - [ ]* 17.3 Escribir test de propiedad para eliminación
    - **Propiedad 30: Eliminación de Categoría Reasigna Entradas**
    - **Valida: Requisitos 17.4**
  
  - [ ]* 17.4 Escribir test de propiedad para conteo
    - **Propiedad 31: Conteo de Entradas por Categoría es Preciso**
    - **Valida: Requisitos 17.5**

- [x] 18. Implementar gestión de historial de contraseñas
  - [x] 18.1 Añadir lógica de historial al VaultRepository
    - Implementar límite de 10 contraseñas en historial
    - Implementar eliminación de la más antigua al alcanzar límite
    - Añadir timestamps a cada entrada del historial
    - _Requisitos: 11.1, 11.2, 11.3, 11.4_
  
  - [ ]* 18.2 Escribir test de propiedad para límite de tamaño
    - **Propiedad 23: Historial Mantiene Límite de Tamaño**
    - **Valida: Requisitos 11.3**
  
  - [ ]* 18.3 Escribir test de propiedad para timestamps
    - **Propiedad 24: Historial Incluye Timestamps**
    - **Valida: Requisitos 11.4**
  
  - [ ]* 18.4 Escribir test unitario para historial con 10 elementos
    - Verificar eliminación de la más antigua
    - _Requisitos: 11.2, 11.3_

- [x] 19. Implementar gestión de notas seguras
  - [x] 19.1 Crear SecureNoteRepository
    - Implementar createNote() con cifrado
    - Implementar updateNote() y deleteNote()
    - Implementar attachFile() con validación de tamaño (5MB)
    - Implementar searchNotes() en contenido
    - _Requisitos: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ]* 19.2 Escribir test de propiedad para cifrado de notas
    - Usar Propiedad 1 (round-trip) aplicada a notas
    - **Valida: Requisitos 9.2**
  
  - [ ]* 19.3 Escribir test de propiedad para cifrado de archivos
    - Usar Propiedad 1 (round-trip) aplicada a archivos
    - **Valida: Requisitos 9.4**

- [x] 20. Implementar gestión de configuración
  - [x] 20.1 Crear SettingsRepository
    - Implementar saveSettings() y loadSettings()
    - Implementar getDefaults() con valores seguros
    - Implementar changeMasterPassword() con verificación
    - Implementar changeMasterPin() con verificación
    - Persistir configuración cifrada
    - _Requisitos: 28.1, 28.2, 28.3, 28.4, 28.5_
  
  - [ ]* 20.2 Escribir test de propiedad para persistencia
    - **Propiedad 27: Persistencia de Preferencias**
    - **Valida: Requisitos 13.4, 28.4**
  
  - [ ]* 20.3 Escribir test de propiedad para cambio de contraseña
    - **Propiedad 32: Cambio de Contraseña Maestra Requiere Verificación**
    - **Valida: Requisitos 28.5**

- [x] 21. Checkpoint - Verificar capa de datos completa
  - Asegurar que todos los tests pasen
  - Verificar que todos los repositorios funcionan correctamente
  - Preguntar al usuario si hay dudas

- [x] 22. Implementar capa de presentación - Autenticación
  - [x] 22.1 Crear pantalla de onboarding
    - Diseñar UI con animación Lottie de bienvenida
    - Implementar formulario de setup de contraseña maestra/PIN
    - Aplicar efectos glassmorphism
    - Integrar con AuthService
    - _Requisitos: 2.1, 15.1, 15.3_
  
  - [x] 22.2 Crear pantalla de login
    - Diseñar UI con campo de contraseña/PIN
    - Añadir botón de autenticación biométrica (si disponible)
    - Implementar shake animation para errores
    - Mostrar mensaje de bloqueo temporal
    - Integrar con AuthService y AutoLockService
    - _Requisitos: 2.2, 2.3, 2.4, 15.1_

- [x] 23. Implementar capa de presentación - Vault principal
  - [x] 23.1 Crear pantalla principal de vault
    - Diseñar lista de entradas con flutter_staggered_animations
    - Implementar barra de búsqueda con animación de expansión
    - Añadir filtros de categoría con chips animados
    - Implementar FAB con animación de escala
    - Mostrar shimmer durante carga inicial
    - Integrar con VaultRepository
    - _Requisitos: 6.1, 15.2, 15.5_
  
  - [x] 23.2 Implementar EntryCard con acciones deslizables
    - Usar flutter_slidable para acciones
    - Deslizar izquierda: editar y eliminar
    - Deslizar derecha: copiar y favorito
    - Aplicar glassmorphism
    - Mostrar favicon de URL
    - Añadir badges de categoría
    - _Requisitos: 16.1, 16.2, 16.3, 16.4, 16.5, 15.3_

- [x] 24. Implementar capa de presentación - Detalle de entrada
  - [x] 24.1 Crear pantalla de detalle/edición de entrada
    - Implementar Hero animation desde la lista
    - Diseñar formulario con todos los campos
    - Añadir botones de copiar con feedback visual
    - Mostrar indicador de fortaleza de contraseña
    - Integrar generador de contraseñas inline
    - Mostrar display de TOTP si existe
    - Mostrar historial de contraseñas expandible
    - Aplicar glassmorphism en tarjetas
    - _Requisitos: 5.2, 7.1, 10.3, 11.5, 15.1_
  
  - [x] 24.2 Integrar ClipboardService para copiar
    - Copiar contraseña, usuario, TOTP
    - Mostrar notificación de confirmación
    - Aplicar limpieza automática
    - _Requisitos: 7.1, 7.2, 7.3, 10.5_

- [x] 25. Implementar capa de presentación - Generador de contraseñas
  - [x] 25.1 Crear pantalla de generador
    - Diseñar slider animado para longitud
    - Añadir switches para tipos de caracteres
    - Mostrar vista previa con indicador de fortaleza
    - Añadir botón de regenerar con animación de rotación
    - Aplicar glassmorphism
    - Integrar con PasswordGeneratorService
    - _Requisitos: 4.2, 4.3, 4.5, 15.1_

- [x] 26. Implementar capa de presentación - Análisis de seguridad
  - [x] 26.1 Crear pantalla de análisis de seguridad
    - Diseñar gráfico circular animado de puntuación
    - Mostrar lista de problemas con iconos de advertencia
    - Crear tarjetas con glassmorphism para cada categoría
    - Aplicar animaciones de entrada escalonadas
    - Integrar con SecurityAnalyzerService
    - _Requisitos: 8.2, 8.4, 15.1, 15.2_

- [x] 27. Implementar capa de presentación - Configuración
  - [x] 27.1 Crear pantalla de configuración
    - Diseñar lista agrupada con separadores
    - Añadir switches animados para opciones
    - Implementar diálogos modales para cambios
    - Añadir sección de respaldo y restauración
    - Añadir selector de tema (claro/oscuro/automático)
    - Integrar con SettingsRepository y BackupService
    - _Requisitos: 13.1, 13.3, 14.2, 28.1, 28.2, 28.3, 28.4, 28.5_

- [x] 28. Implementar capa de presentación - Notas seguras
  - [x] 28.1 Crear pantalla de notas seguras
    - Diseñar lista de notas con animaciones
    - Implementar editor de texto para contenido
    - Añadir funcionalidad de adjuntar archivos
    - Validar tamaño de archivos (5MB)
    - Integrar con SecureNoteRepository
    - _Requisitos: 9.1, 9.3, 9.5_

- [x] 29. Implementar gestión de estado con Provider/Riverpod
  - [x] 29.1 Crear providers para cada feature
    - AuthProvider para estado de autenticación
    - VaultProvider para entradas
    - SettingsProvider para configuración
    - ThemeProvider para tema
    - Implementar notificaciones reactivas
    - _Requisitos: 2.5, 3.3, 13.3_

- [x] 30. Implementar navegación y routing
  - [x] 30.1 Configurar navegación de la app
    - Implementar rutas con transiciones animadas
    - Configurar guards de autenticación
    - Implementar deep linking si es necesario
    - Añadir transiciones slide + fade
    - _Requisitos: 15.1_

- [x] 31. Implementar tema y estilos
  - [x] 31.1 Crear ThemeService completo
    - Definir paletas de colores para claro y oscuro
    - Configurar google_fonts para tipografía
    - Crear componentes reutilizables con glassmorphism
    - Implementar cambio de tema reactivo
    - Persistir preferencia de tema
    - _Requisitos: 13.1, 13.2, 13.3, 13.4, 13.5, 15.3_

- [x] 32. Checkpoint - Verificar UI completa
  - Asegurar que todas las pantallas funcionan
  - Verificar animaciones y transiciones
  - Probar flujos completos de usuario
  - Preguntar al usuario si hay dudas

- [ ]* 33. Escribir tests de integración
  - [ ]* 33.1 Test de flujo de onboarding completo
    - Setup de contraseña maestra
    - Creación de primera entrada
    - Verificación de cifrado
    - _Requisitos: 2.1, 5.1, 1.1_
  
  - [ ]* 33.2 Test de flujo de búsqueda y filtrado
    - Crear múltiples entradas con categorías
    - Buscar por término
    - Filtrar por categoría
    - Combinar búsqueda y filtro
    - _Requisitos: 6.1, 6.2, 6.3, 6.4_
  
  - [ ]* 33.3 Test de flujo de respaldo y restauración
    - Crear varias entradas
    - Crear respaldo
    - Limpiar datos
    - Restaurar respaldo
    - Verificar integridad
    - _Requisitos: 14.1, 14.4_
  
  - [ ]* 33.4 Test de flujo de análisis de seguridad
    - Crear entradas con contraseñas débiles y duplicadas
    - Ejecutar análisis
    - Verificar detección correcta
    - Generar nuevas contraseñas fuertes
    - _Requisitos: 8.2, 8.3, 4.1_

- [ ] 34. Optimización y pulido final
  - [ ] 34.1 Optimizar rendimiento
    - Revisar y optimizar animaciones
    - Implementar lazy loading donde sea necesario
    - Optimizar tamaño de build
    - Probar en dispositivos de gama baja
  
  - [ ] 34.2 Pulir UI y UX
    - Revisar consistencia visual
    - Ajustar tiempos de animación
    - Mejorar feedback visual
    - Probar accesibilidad básica

- [ ] 35. Checkpoint final - Verificar aplicación completa
  - Ejecutar todos los tests (unitarios, propiedades, integración)
  - Verificar cobertura de tests (mínimo 80%)
  - Probar en iOS y Android
  - Verificar que todos los requisitos están implementados
  - Preguntar al usuario si hay algo más que ajustar

## Notas

- Las tareas marcadas con `*` son opcionales y pueden omitirse para un MVP más rápido
- Cada tarea referencia los requisitos específicos que implementa
- Los checkpoints aseguran validación incremental
- Los tests de propiedades validan corrección universal
- Los tests unitarios validan ejemplos específicos y casos edge
