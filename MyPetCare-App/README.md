<p align="center">
  <a href="https://github.com/GabrielJuan349/MyPetCare">
    <img alt="Logo" src="assets/logo/nombreLogoSinFondo.png" width=350 height=250>
  </a>

  <p align="center">
    📱 MyPetCare Mobile Application - Aplicación móvil Flutter para el cuidado integral de mascotas
    <br>
    <a href="https://github.com/GabrielJuan349/MyPetCare/issues/new?template=bug.md">Report bug</a>
    ·
    <a href="https://github.com/GabrielJuan349/MyPetCare/issues/new?template=feature.md&labels=feature">Request feature</a>
  </p>
</p>

# MyPetCare - Aplicación Móvil 📱

Aplicación móvil multiplataforma desarrollada en Flutter que permite a los propietarios de mascotas gestionar de forma integral el cuidado de sus animales, con conexión a clínicas veterinarias y servicios especializados.

## 📋 Tabla de contenidos

- [🚀 Instalación rápida](#-instalación-rápida)
- [✨ Características principales](#-características-principales)
- [📱 Capturas de pantalla](#-capturas-de-pantalla)
- [🛠 Tecnologías utilizadas](#-tecnologías-utilizadas)
- [📁 Estructura del proyecto](#-estructura-del-proyecto)
- [⚙️ Configuración](#️-configuración)
- [🔧 Desarrollo](#-desarrollo)
- [🧪 Testing](#-testing)
- [🚀 Deployment](#-deployment)
- [🐛 Bugs y solicitud de características](#-bugs-y-solicitud-de-características)

## 🚀 Instalación rápida

### Prerrequisitos
- Flutter SDK (>= 3.5.4)
- Dart SDK
- Android Studio / Xcode (para emuladores)
- Firebase CLI
- Git

### Instalación

1. **Clona el repositorio:**
```bash
git clone https://github.com/GabrielJuan349/MyPetCare.git
cd MyPetCare/MyPetCare-App
```

2. **Instala las dependencias:**
```bash
flutter pub get
```

3. **Configura Firebase:**
   - Descarga el archivo `google-services.json` para Android
   - Descarga el archivo `GoogleService-Info.plist` para iOS
   - Colócalos en las carpetas correspondientes

4. **Ejecuta la aplicación:**
```bash
flutter run
```

## ✨ Características principales

### 🐾 Gestión de Mascotas
- ✅ Registro y perfil completo de mascotas
- ✅ Seguimiento de historial médico
- ✅ Gestión de vacunas y tratamientos
- ✅ Fotos y documentos de mascotas

### 📅 Sistema de Citas
- ✅ Programación de citas veterinarias
- ✅ Calendario integrado con recordatorios
- ✅ Gestión de citas pendientes y completadas
- ✅ Notificaciones push automáticas

### 🏥 Servicios Veterinarios
- ✅ Búsqueda de clínicas cercanas con geolocalización
- ✅ Información detallada de clínicas
- ✅ Mapa interactivo de servicios
- ✅ Sistema de valoraciones y reseñas

### 💊 Gestión Médica
- ✅ Registro de prescripciones médicas
- ✅ Seguimiento de tratamientos activos
- ✅ Historial de vacunas y desparasitaciones
- ✅ Generación de reportes médicos

### 🔔 Notificaciones y Recordatorios
- ✅ Recordatorios de citas veterinarias
- ✅ Alertas de medicación y tratamientos
- ✅ Notificaciones de vacunas vencidas
- ✅ Mensajes de clínicas veterinarias

### 🏠 Adopción
- ✅ Explorar mascotas en adopción
- ✅ Detalles completos de animales disponibles
- ✅ Sistema de solicitudes de adopción
- ✅ Conexión directa con refugios

### 📰 Información y Recursos
- ✅ Noticias sobre cuidado de mascotas
- ✅ Artículos educativos veterinarios
- ✅ FAQs y preguntas frecuentes
- ✅ Consejos de cuidado por especies

### 🔐 Autenticación y Seguridad
- ✅ Registro con email y contraseña
- ✅ Inicio de sesión con Google
- ✅ Recuperación de contraseña
- ✅ Autenticación Firebase segura

## 📱 Capturas de pantalla

*(Las capturas de pantalla se añadirán próximamente)*

## 🛠 Tecnologías utilizadas

### Frontend Mobile
- **Flutter 3.5.4+** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **Material Design** - Sistema de diseño de Google

### Backend y Servicios
- **Firebase Core** - Plataforma de desarrollo de aplicaciones
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Firebase Messaging** - Notificaciones push

### Funcionalidades Específicas
- **Provider** - Gestión de estado
- **HTTP** - Comunicación con APIs REST
- **Google Sign In** - Autenticación con Google
- **Flutter Map** - Mapas interactivos
- **LatLong2** - Manejo de coordenadas geográficas
- **Geolocator** - Servicios de geolocalización
- **Image Picker** - Selección y captura de imágenes
- **File Picker** - Selección de archivos
- **Table Calendar** - Widget de calendario
- **Flutter Local Notifications** - Notificaciones locales
- **Google ML Kit Text Recognition** - Reconocimiento de texto OCR
- **Shared Preferences** - Almacenamiento local
- **Path Provider** - Rutas del sistema de archivos
- **Open File** - Apertura de archivos

## 📁 Estructura del proyecto

```
MyPetCare-App/
├── lib/
│   ├── main.dart                      # Punto de entrada de la aplicación
│   ├── init_screen.dart              # Pantalla de bienvenida
│   ├── home_screen.dart              # Pantalla principal
│   ├── profile_screen.dart           # Perfil de usuario
│   ├── 
│   ├── # Autenticación
│   ├── iniciar_sesion.dart           # Pantalla de inicio de sesión
│   ├── register_screen.dart          # Registro de usuario
│   ├── register_form_screen.dart     # Formulario de registro
│   ├── reset_password_screen.dart    # Recuperación de contraseña
│   ├── signInWithGoogle.dart         # Autenticación con Google
│   ├──
│   ├── # Gestión de Mascotas
│   ├── my_pets_screen.dart           # Lista de mascotas
│   ├── new_pet.dart                  # Registro de nueva mascota
│   ├── edit_pet.dart                 # Edición de mascota
│   ├── pet_details.dart              # Detalles de mascota
│   ├── pet_num_screen.dart           # Contador de mascotas
│   ├──
│   ├── # Sistema de Citas
│   ├── appointment_list_screen.dart  # Lista de citas
│   ├── add_appointment_screen.dart   # Nueva cita
│   ├── calendar_screen.dart          # Calendario de citas
│   ├── schedule_screen.dart          # Programación
│   ├──
│   ├── # Gestión Médica
│   ├── vaccine_screen.dart           # Gestión de vacunas
│   ├── add_vaccine_screen.dart       # Nueva vacuna
│   ├── prescription.dart             # Prescripciones médicas
│   ├── PetTreatmentScreen.dart       # Tratamientos
│   ├── report.dart                   # Reportes médicos
│   ├── reports_screen.dart           # Lista de reportes
│   ├──
│   ├── # Servicios y Ubicación
│   ├── map.dart                      # Mapa de clínicas
│   ├── nearest_clinics.dart          # Clínicas cercanas
│   ├── clinic_info_screen.dart       # Información de clínica
│   ├──
│   ├── # Adopción
│   ├── clinic_adoptions_screen.dart  # Mascotas en adopción
│   ├── adoption_details_screen.dart  # Detalles de adopción
│   ├──
│   ├── # Comunicación
│   ├── inbox.dart                    # Bandeja de entrada
│   ├── inbox_history.dart            # Historial de mensajes
│   ├── inbox_message.dart            # Mensajes
│   ├── inbox_message_detail.dart     # Detalle de mensaje
│   ├── reminders_screen.dart         # Recordatorios
│   ├── reminder_message.dart         # Mensaje de recordatorio
│   ├──
│   ├── # Información y Recursos
│   ├── news.dart                     # Noticias
│   ├── FAQs.dart                     # Preguntas frecuentes
│   ├──
│   ├── # Servicios
│   ├── services/
│   │   └── notification_service.dart # Servicio de notificaciones
│   ├──
│   ├── # Modelos y Datos
│   ├── pet.dart                      # Modelo de mascota
│   ├── appointment.dart              # Modelo de cita
│   ├── data.dart                     # Gestión de datos
│   ├── requests.dart                 # Peticiones HTTP
│   ├── the_drawer.dart               # Navegación lateral
│   └── test.dart                     # Utilidades de testing
├──
├── android/                          # Configuración Android
├── ios/                             # Configuración iOS
├── web/                             # Configuración Web
├── linux/                           # Configuración Linux
├── macos/                           # Configuración macOS
├── windows/                         # Configuración Windows
├──
├── assets/
│   └── logo/                        # Recursos de imágenes
├──
├── test/                            # Tests automatizados
├── pubspec.yaml                     # Dependencias y configuración
├── analysis_options.yaml           # Reglas de análisis de código
└── README.md                        # Documentación (este archivo)
```

## ⚙️ Configuración

### Variables de entorno requeridas

Crea un archivo `firebase_options.dart` en la carpeta `lib/` con la configuración de Firebase:

```dart
// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }
  
  // Configuración específica para cada plataforma...
}
```

### Configuración de Firebase

1. **Crea un proyecto en Firebase Console**
2. **Habilita los siguientes servicios:**
   - Authentication (Email/Password y Google)
   - Cloud Firestore
   - Firebase Messaging
   - Firebase Storage

3. **Configura Authentication:**
   - Habilita proveedores: Email/Password y Google
   - Configura dominios autorizados

4. **Configura Cloud Firestore:**
   - Crea la base de datos en modo de prueba
   - Configura reglas de seguridad

### Permisos requeridos

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita acceso a la ubicación para encontrar clínicas veterinarias cercanas.</string>
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para tomar fotos de mascotas.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta app necesita acceso a la galería para seleccionar fotos de mascotas.</string>
```

## 🔧 Desarrollo

### Comandos útiles

```bash
# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Generar APK
flutter build apk

# Generar Bundle para Play Store
flutter build appbundle

# Generar para iOS
flutter build ios

# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format .
```

### Estructura de desarrollo

1. **Modelos de datos:** Se encuentran en archivos individuales (`pet.dart`, `appointment.dart`)
2. **Pantallas:** Cada pantalla tiene su propio archivo en `lib/`
3. **Servicios:** Los servicios compartidos están en `lib/services/`
4. **Gestión de estado:** Se utiliza Provider para el manejo de estado
5. **Navegación:** Navegación declarativa con rutas nombradas

### Convenciones de código

- Utilizar **snake_case** para nombres de archivos
- Utilizar **camelCase** para variables y funciones
- Utilizar **PascalCase** para clases y widgets
- Comentar código complejo y funciones importantes
- Seguir las guías de estilo de Dart y Flutter

## 🧪 Testing

### Ejecutar tests

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests específicos
flutter test test/widget_test.dart
```

### Tipos de tests implementados

- **Unit Tests:** Testing de lógica de negocio
- **Widget Tests:** Testing de componentes UI
- **Integration Tests:** Testing de flujos completos

## 🚀 Deployment

### Android

1. **Configurar signing:**
   - Crear keystore para firma de aplicaciones
   - Configurar `android/key.properties`
   - Actualizar `android/app/build.gradle`

2. **Generar release:**
```bash
flutter build appbundle --release
```

3. **Subir a Google Play Store:**
   - Subir el archivo `.aab` generado
   - Completar información de la tienda
   - Configurar testing interno/cerrado

### iOS

1. **Configurar certificates:**
   - Crear certificates en Apple Developer
   - Configurar provisioning profiles
   - Actualizar configuración en Xcode

2. **Generar release:**
```bash
flutter build ios --release
```

3. **Subir a App Store:**
   - Usar Xcode o Application Loader
   - Completar información en App Store Connect
   - Enviar para revisión

### Web

```bash
flutter build web --release
```

## 🐛 Bugs y solicitud de características

¿Tienes un bug o una solicitud de característica? Por favor, primero lee las [pautas de issues](https://github.com/GabrielJuan349/MyPetCare/blob/master/CONTRIBUTING.md) y busca entre los issues existentes y cerrados. Si tu problema o idea no está siendo abordada aún, [por favor abre un nuevo issue](https://github.com/GabrielJuan349/MyPetCare/issues/new).

### Reportar un bug

1. **Usa un título claro y descriptivo**
2. **Describe los pasos exactos para reproducir el problema**
3. **Incluye capturas de pantalla si es necesario**
4. **Especifica la versión de Flutter y dispositivo**
5. **Incluye logs de error si están disponibles**

### Solicitar una característica

1. **Describe claramente la funcionalidad deseada**
2. **Explica por qué sería útil para otros usuarios**
3. **Proporciona ejemplos de uso si es posible**
4. **Considera alternativas que hayas evaluado**

## 🤝 Contribución

Por favor, lee nuestras [pautas de contribución](https://github.com/GabrielJuan349/MyPetCare/blob/master/CONTRIBUTING.md). Se incluyen direcciones para abrir issues, estándares de codificación y notas sobre desarrollo.

Además, todo el código debería cumplir con la [Guía de Código](https://github.com/mdo/code-guide), mantenida por el equipo principal.

Las preferencias del editor están disponibles en [editor config](https://github.com/GabrielJuan349/MyPetCare/blob/master/.editorconfig) para uso fácil en editores de texto comunes. Lee más y descarga plugins en <https://editorconfig.org/>.

### Proceso de contribución

1. **Fork el repositorio**
2. **Crea una rama para tu característica** (`git checkout -b feature/AmazingFeature`)
3. **Commit tus cambios** (`git commit -m 'Add some AmazingFeature'`)
4. **Push a la rama** (`git push origin feature/AmazingFeature`)
5. **Abre un Pull Request**


