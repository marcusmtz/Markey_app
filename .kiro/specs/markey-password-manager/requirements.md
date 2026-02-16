# Documento de Requisitos: Markey Password Manager

## Introducción

Markey es una aplicación móvil de gestión de contraseñas desarrollada en Flutter que permite a los usuarios almacenar, generar y gestionar sus contraseñas de forma segura mediante cifrado local AES-256. La aplicación ofrece autenticación biométrica, generación de códigos 2FA, análisis de seguridad de contraseñas y una interfaz moderna con animaciones fluidas.

## Glosario

- **Sistema**: La aplicación Markey Password Manager
- **Usuario**: Persona que utiliza la aplicación para gestionar contraseñas
- **Entrada**: Registro individual que contiene credenciales (usuario, contraseña, URL, notas)
- **Almacenamiento_Seguro**: Sistema de almacenamiento local cifrado con AES-256
- **Contraseña_Maestra**: Contraseña principal que protege el acceso a todas las demás contraseñas
- **PIN_Maestro**: Código numérico alternativo a la contraseña maestra
- **Autenticación_Biométrica**: Verificación mediante huella dactilar o Face ID
- **Generador_Contraseñas**: Componente que crea contraseñas aleatorias seguras
- **Generador_TOTP**: Componente que genera códigos de autenticación de dos factores
- **Portapapeles**: Área temporal del sistema donde se copian datos
- **Categoría**: Etiqueta organizativa (trabajo, personal, bancario, etc.)
- **Nota_Segura**: Texto cifrado almacenado de forma segura
- **Historial_Contraseñas**: Registro de contraseñas anteriores de una entrada
- **Analizador_Seguridad**: Componente que evalúa la fortaleza de contraseñas

## Requisitos

### Requisito 1: Almacenamiento Seguro Local

**Historia de Usuario:** Como usuario, quiero que mis contraseñas se almacenen de forma cifrada localmente, para que nadie pueda acceder a ellas sin mi autorización.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ cifrar todas las entradas utilizando AES-256 antes de almacenarlas
2. CUANDO el usuario guarda una entrada, EL Sistema DEBERÁ persistir los datos cifrados en el Almacenamiento_Seguro inmediatamente
3. CUANDO el usuario solicita una entrada, EL Sistema DEBERÁ descifrar los datos antes de mostrarlos
4. EL Sistema DEBERÁ derivar la clave de cifrado de la Contraseña_Maestra o PIN_Maestro del usuario
5. SI el Almacenamiento_Seguro no está disponible, ENTONCES EL Sistema DEBERÁ mostrar un error y no permitir operaciones

### Requisito 2: Autenticación del Usuario

**Historia de Usuario:** Como usuario, quiero proteger mi bóveda de contraseñas con una contraseña maestra y biometría, para que solo yo pueda acceder a mis datos.

#### Criterios de Aceptación

1. CUANDO el usuario configura la aplicación por primera vez, EL Sistema DEBERÁ solicitar la creación de una Contraseña_Maestra o PIN_Maestro
2. CUANDO el usuario intenta acceder a la aplicación, EL Sistema DEBERÁ solicitar autenticación mediante Contraseña_Maestra, PIN_Maestro o Autenticación_Biométrica
3. DONDE la Autenticación_Biométrica esté disponible en el dispositivo, EL Sistema DEBERÁ ofrecer esta opción al usuario
4. SI el usuario falla la autenticación tres veces consecutivas, ENTONCES EL Sistema DEBERÁ bloquear el acceso temporalmente durante 30 segundos
5. CUANDO el usuario autentica correctamente, EL Sistema DEBERÁ mantener la sesión activa hasta el bloqueo automático

### Requisito 3: Bloqueo Automático por Inactividad

**Historia de Usuario:** Como usuario, quiero que la aplicación se bloquee automáticamente después de un período de inactividad, para proteger mis datos si olvido cerrar la aplicación.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ bloquear automáticamente la aplicación después de 2 minutos de inactividad por defecto
2. DONDE el usuario configure un tiempo de bloqueo personalizado, EL Sistema DEBERÁ respetar esa configuración
3. CUANDO la aplicación se bloquea, EL Sistema DEBERÁ requerir autenticación completa para desbloquear
4. MIENTRAS la aplicación está en segundo plano, EL Sistema DEBERÁ contar el tiempo como inactividad
5. CUANDO el usuario interactúa con la aplicación, EL Sistema DEBERÁ reiniciar el temporizador de inactividad

### Requisito 4: Generación de Contraseñas Seguras

**Historia de Usuario:** Como usuario, quiero generar contraseñas aleatorias y seguras con opciones personalizables, para no tener que crear contraseñas manualmente.

#### Criterios de Aceptación

1. EL Generador_Contraseñas DEBERÁ crear contraseñas aleatorias utilizando un generador criptográficamente seguro
2. CUANDO el usuario solicita una contraseña, EL Generador_Contraseñas DEBERÁ permitir configurar longitud (8-64 caracteres)
3. DONDE el usuario seleccione opciones de caracteres, EL Generador_Contraseñas DEBERÁ incluir mayúsculas, minúsculas, números y símbolos según la selección
4. EL Generador_Contraseñas DEBERÁ generar contraseñas que cumplan con los criterios seleccionados
5. CUANDO se genera una contraseña, EL Sistema DEBERÁ mostrar su nivel de fortaleza inmediatamente

### Requisito 5: Gestión de Entradas

**Historia de Usuario:** Como usuario, quiero crear, editar, eliminar y organizar mis entradas de contraseñas, para mantener mis credenciales organizadas.

#### Criterios de Aceptación

1. CUANDO el usuario crea una entrada, EL Sistema DEBERÁ solicitar al menos un título y una contraseña
2. EL Sistema DEBERÁ permitir almacenar título, nombre de usuario, contraseña, URL, notas y categoría para cada entrada
3. CUANDO el usuario edita una entrada, EL Sistema DEBERÁ guardar la contraseña anterior en el Historial_Contraseñas
4. CUANDO el usuario elimina una entrada, EL Sistema DEBERÁ solicitar confirmación antes de eliminar permanentemente
5. EL Sistema DEBERÁ permitir asignar una o más Categorías a cada entrada

### Requisito 6: Búsqueda y Filtrado

**Historia de Usuario:** Como usuario, quiero buscar y filtrar mis contraseñas rápidamente, para encontrar la información que necesito sin demora.

#### Criterios de Aceptación

1. CUANDO el usuario escribe en el campo de búsqueda, EL Sistema DEBERÁ filtrar las entradas en tiempo real
2. EL Sistema DEBERÁ buscar coincidencias en título, nombre de usuario, URL y notas
3. DONDE el usuario seleccione una Categoría, EL Sistema DEBERÁ mostrar solo las entradas de esa categoría
4. CUANDO el usuario aplica múltiples filtros, EL Sistema DEBERÁ combinarlos con lógica AND
5. EL Sistema DEBERÁ mostrar resultados ordenados por relevancia y fecha de modificación

### Requisito 7: Copiar al Portapapeles con Auto-limpieza

**Historia de Usuario:** Como usuario, quiero copiar contraseñas al portapapeles con limpieza automática, para usarlas en otras aplicaciones sin comprometer la seguridad.

#### Criterios de Aceptación

1. CUANDO el usuario copia una contraseña al Portapapeles, EL Sistema DEBERÁ mostrar una notificación de confirmación
2. EL Sistema DEBERÁ limpiar automáticamente el Portapapeles después de 30 segundos
3. CUANDO el usuario copia un nombre de usuario, EL Sistema DEBERÁ aplicar la misma limpieza automática
4. SI el usuario copia otro dato antes de los 30 segundos, ENTONCES EL Sistema DEBERÁ cancelar la limpieza programada anterior
5. DONDE el usuario configure un tiempo de limpieza personalizado, EL Sistema DEBERÁ respetar esa configuración

### Requisito 8: Análisis de Seguridad de Contraseñas

**Historia de Usuario:** Como usuario, quiero que la aplicación analice la seguridad de mis contraseñas, para identificar contraseñas débiles, duplicadas o comprometidas.

#### Criterios de Aceptación

1. EL Analizador_Seguridad DEBERÁ evaluar la fortaleza de cada contraseña (débil, media, fuerte, muy fuerte)
2. CUANDO el usuario accede al panel de seguridad, EL Sistema DEBERÁ mostrar un resumen de contraseñas débiles, duplicadas y reutilizadas
3. EL Analizador_Seguridad DEBERÁ identificar contraseñas duplicadas comparando todas las entradas
4. DONDE una contraseña sea débil, EL Sistema DEBERÁ sugerir generar una nueva contraseña
5. EL Sistema DEBERÁ calcular una puntuación de seguridad general basada en todas las contraseñas

### Requisito 9: Notas y Documentos Seguros

**Historia de Usuario:** Como usuario, quiero almacenar notas y documentos sensibles de forma cifrada, para mantener información importante junto con mis contraseñas.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ permitir crear Notas_Seguras con título y contenido de texto
2. CUANDO el usuario guarda una Nota_Segura, EL Sistema DEBERÁ cifrarla con el mismo nivel de seguridad que las contraseñas
3. EL Sistema DEBERÁ permitir adjuntar archivos pequeños (máximo 5MB) a las notas
4. CUANDO el usuario adjunta un archivo, EL Sistema DEBERÁ cifrarlo antes de almacenarlo
5. EL Sistema DEBERÁ permitir buscar dentro del contenido de las Notas_Seguras

### Requisito 10: Generador de Códigos 2FA/TOTP

**Historia de Usuario:** Como usuario, quiero generar códigos de autenticación de dos factores dentro de la aplicación, para no necesitar una aplicación separada.

#### Criterios de Aceptación

1. CUANDO el usuario añade un código TOTP a una entrada, EL Generador_TOTP DEBERÁ aceptar claves secretas en formato Base32
2. EL Generador_TOTP DEBERÁ generar códigos de 6 dígitos que se actualizan cada 30 segundos
3. CUANDO el código está próximo a expirar (últimos 5 segundos), EL Sistema DEBERÁ mostrar una indicación visual
4. EL Sistema DEBERÁ permitir escanear códigos QR para configurar TOTP automáticamente
5. CUANDO el usuario copia un código TOTP, EL Sistema DEBERÁ copiarlo al Portapapeles con limpieza automática

### Requisito 11: Historial de Contraseñas

**Historia de Usuario:** Como usuario, quiero ver el historial de contraseñas anteriores de cada entrada, para recuperar una contraseña antigua si es necesario.

#### Criterios de Aceptación

1. CUANDO el usuario cambia la contraseña de una entrada, EL Sistema DEBERÁ guardar la contraseña anterior en el Historial_Contraseñas
2. EL Sistema DEBERÁ almacenar hasta 10 contraseñas anteriores por entrada
3. CUANDO el historial alcanza el límite, EL Sistema DEBERÁ eliminar la contraseña más antigua al añadir una nueva
4. EL Sistema DEBERÁ mostrar la fecha y hora de cada cambio de contraseña en el historial
5. CUANDO el usuario visualiza el historial, EL Sistema DEBERÁ permitir copiar contraseñas anteriores al Portapapeles

### Requisito 12: Favoritos

**Historia de Usuario:** Como usuario, quiero marcar entradas como favoritas, para acceder rápidamente a mis contraseñas más utilizadas.

#### Criterios de Aceptación

1. CUANDO el usuario marca una entrada como favorita, EL Sistema DEBERÁ añadirla a la lista de favoritos
2. EL Sistema DEBERÁ mostrar las entradas favoritas en una sección dedicada de la interfaz
3. CUANDO el usuario desmarca un favorito, EL Sistema DEBERÁ removerlo de la lista de favoritos inmediatamente
4. EL Sistema DEBERÁ permitir acceder a favoritos desde la pantalla principal
5. EL Sistema DEBERÁ mantener el orden de favoritos según la frecuencia de uso

### Requisito 13: Temas Visual (Modo Oscuro/Claro)

**Historia de Usuario:** Como usuario, quiero cambiar entre modo oscuro y claro, para adaptar la interfaz a mis preferencias y condiciones de iluminación.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ ofrecer tres opciones de tema: claro, oscuro y automático
2. DONDE el usuario seleccione modo automático, EL Sistema DEBERÁ seguir la configuración del sistema operativo
3. CUANDO el usuario cambia el tema, EL Sistema DEBERÁ aplicar el cambio inmediatamente sin reiniciar
4. EL Sistema DEBERÁ persistir la preferencia de tema del usuario
5. EL Sistema DEBERÁ aplicar el tema a todas las pantallas y componentes de forma consistente

### Requisito 14: Respaldo y Restauración

**Historia de Usuario:** Como usuario, quiero respaldar y restaurar mis datos, para no perder mi información si cambio de dispositivo o reinstalo la aplicación.

#### Criterios de Aceptación

1. CUANDO el usuario solicita un respaldo, EL Sistema DEBERÁ crear un archivo cifrado con todas las entradas y configuraciones
2. EL Sistema DEBERÁ permitir exportar el respaldo a almacenamiento local del dispositivo
3. DONDE el usuario configure respaldo en la nube, EL Sistema DEBERÁ cifrar los datos antes de subirlos
4. CUANDO el usuario restaura un respaldo, EL Sistema DEBERÁ solicitar la Contraseña_Maestra para descifrar los datos
5. SI el respaldo está corrupto o la contraseña es incorrecta, ENTONCES EL Sistema DEBERÁ mostrar un error descriptivo sin perder datos existentes


### Requisito 15: Interfaz de Usuario Moderna y Animada

**Historia de Usuario:** Como usuario, quiero una interfaz moderna con animaciones fluidas, para tener una experiencia visual agradable y profesional.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ utilizar animaciones suaves para transiciones entre pantallas
2. CUANDO se carga una lista, EL Sistema DEBERÁ mostrar animaciones escalonadas para cada elemento
3. EL Sistema DEBERÁ aplicar efectos de glassmorphism en componentes clave de la interfaz
4. CUANDO se realizan acciones deslizables, EL Sistema DEBERÁ proporcionar retroalimentación visual inmediata
5. MIENTRAS se cargan datos, EL Sistema DEBERÁ mostrar efectos shimmer en lugar de indicadores de carga estáticos

### Requisito 16: Acciones Deslizables en Listas

**Historia de Usuario:** Como usuario, quiero realizar acciones rápidas deslizando elementos en las listas, para gestionar mis entradas de forma eficiente.

#### Criterios de Aceptación

1. CUANDO el usuario desliza una entrada hacia la izquierda, EL Sistema DEBERÁ revelar opciones de editar y eliminar
2. CUANDO el usuario desliza una entrada hacia la derecha, EL Sistema DEBERÁ revelar opciones de copiar contraseña y marcar como favorito
3. EL Sistema DEBERÁ animar suavemente la revelación de las acciones
4. SI el usuario desliza completamente un elemento, ENTONCES EL Sistema DEBERÁ ejecutar la acción principal automáticamente
5. CUANDO el usuario toca fuera del elemento deslizado, EL Sistema DEBERÁ restaurar el elemento a su posición original

### Requisito 17: Categorización y Organización

**Historia de Usuario:** Como usuario, quiero organizar mis contraseñas en categorías predefinidas y personalizadas, para mantener todo ordenado.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ proporcionar categorías predefinidas: Trabajo, Personal, Bancario, Redes Sociales, Compras, Correo
2. CUANDO el usuario crea una entrada, EL Sistema DEBERÁ permitir seleccionar una o más Categorías
3. EL Sistema DEBERÁ permitir al usuario crear categorías personalizadas con nombre y color
4. CUANDO el usuario elimina una categoría personalizada, EL Sistema DEBERÁ reasignar las entradas a "Sin categoría"
5. EL Sistema DEBERÁ mostrar el número de entradas en cada categoría

### Requisito 28: Configuración y Personalización

**Historia de Usuario:** Como usuario, quiero personalizar la configuración de la aplicación, para adaptarla a mis necesidades y preferencias.

#### Criterios de Aceptación

1. EL Sistema DEBERÁ permitir configurar el tiempo de bloqueo automático (30 segundos a 30 minutos, o nunca)
2. EL Sistema DEBERÁ permitir configurar el tiempo de limpieza del Portapapeles (15 a 120 segundos)
3. DONDE el usuario modifique configuraciones de seguridad, EL Sistema DEBERÁ solicitar autenticación antes de guardar cambios
4. EL Sistema DEBERÁ permitir habilitar o deshabilitar la Autenticación_Biométrica
5. EL Sistema DEBERÁ permitir cambiar la Contraseña_Maestra o PIN_Maestro con verificación de la contraseña actual
