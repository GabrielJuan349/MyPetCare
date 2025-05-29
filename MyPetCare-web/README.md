<p align="center">
  <a href="https://github.com/GabrielJuan349/MyPetCare">
    <img alt="Logo" src="assets/nombreLogoSinFondo.png" width=350 height=250>
  </a>

  <p align="center">
    🌐 MyPetCare Web Application - Plataforma web Flutter para clínicas veterinarias
    <br>
    <a href="https://github.com/GabrielJuan349/MyPetCare/issues/new?template=bug.md">Report bug</a>
    ·
    <a href="https://github.com/GabrielJuan349/MyPetCare/issues/new?template=feature.md&labels=feature">Request feature</a>
  </p>
</p>

# MyPetCare - Aplicación Web para Clínicas 🏥

Aplicación web desarrollada en Flutter que proporciona una plataforma integral de gestión para clínicas veterinarias, permitiendo la administración completa de pacientes, citas, tratamientos y servicios veterinarios.

## 📋 Tabla de contenidos

- [🚀 Instalación rápida](#-instalación-rápida)
- [✨ Características principales](#-características-principales)
- [🖥️ Capturas de pantalla](#️-capturas-de-pantalla)
- [🛠 Tecnologías utilizadas](#-tecnologías-utilizadas)
- [📁 Estructura del proyecto](#-estructura-del-proyecto)
- [⚙️ Configuración](#️-configuración)
- [🔧 Desarrollo](#-desarrollo)
- [🚀 Deployment](#-deployment)
- [🧪 Testing](#-testing)
- [🐛 Bugs y solicitud de características](#-bugs-y-solicitud-de-características)


## 🚀 Instalación rápida

### Prerrequisitos
- Flutter SDK (>= 3.5.4)
- Dart SDK
- Navegador web moderno (Chrome, Firefox, Safari, Edge)
- Firebase CLI
- Git

### Instalación

1. **Clona el repositorio:**
```powershell
git clone https://github.com/GabrielJuan349/MyPetCare.git
cd MyPetCare\MyPetCare-web
```

2. **Instala las dependencias:**
```powershell
flutter pub get
```

3. **Configura Firebase para web:**
   - Habilita Firebase Hosting
   - Configura Firebase Authentication para web
   - Actualiza `firebase_options.dart` con la configuración web

4. **Ejecuta la aplicación:**
```powershell
flutter run -d chrome
```

## ✨ Características principales

### 🏥 Gestión de Clínicas
- ✅ **Registro y configuración de clínicas** veterinarias
- ✅ **Panel de administración** completo para clínicas
- ✅ **Gestión de veterinarios** y personal clínico
- ✅ **Configuración de servicios** y especialidades

### 👨‍⚕️ Gestión de Veterinarios
- ✅ **Registro de veterinarios** con credenciales profesionales
- ✅ **Asignación de horarios** y disponibilidad
- ✅ **Gestión de consultas** y especialidades
- ✅ **Dashboard personalizado** para cada veterinario

### 🐾 Gestión de Pacientes
- ✅ **Registro completo de mascotas** como pacientes
- ✅ **Historial médico detallado** por paciente
- ✅ **Búsqueda y filtrado** de pacientes
- ✅ **Detalles de propietarios** y información de contacto

### 📅 Sistema de Citas
- ✅ **Programación de citas** veterinarias
- ✅ **Calendario interactivo** con vista diaria/semanal
- ✅ **Asignación y reasignación** de citas
- ✅ **Gestión de horarios** de disponibilidad
- ✅ **Información detallada** de cada cita

### 💊 Gestión Médica
- ✅ **Prescripciones médicas** digitales
- ✅ **Registro de tratamientos** y terapias
- ✅ **Historial de medicamentos** por paciente
- ✅ **Detalles de prescripciones** con dosis y duración
- ✅ **Lista completa de tratamientos** activos

### 📊 Reportes y Documentación
- ✅ **Generación de reportes** médicos
- ✅ **Historial de consultas** detallado
- ✅ **Documentación clínica** completa
- ✅ **Exportación de informes** médicos

### 🏠 Sistema de Adopciones
- ✅ **Gestión de mascotas** en adopción
- ✅ **Registro de animales** disponibles
- ✅ **Proceso de adopción** digitalizado
- ✅ **Seguimiento de adopciones** realizadas

### 🔐 Autenticación y Seguridad
- ✅ **Sistema de login** seguro para clínicas
- ✅ **Autenticación Firebase** robusta
- ✅ **Gestión de usuarios** por roles
- ✅ **Protección de datos** médicos sensibles

## 🖥️ Capturas de pantalla

*(Las capturas de pantalla se añadirán próximamente)*

## 🛠 Tecnologías utilizadas

### Frontend Web
- **Flutter 3.5.4+** - Framework de desarrollo web
- **Dart** - Lenguaje de programación
- **Material Design** - Sistema de diseño responsivo
- **Google Fonts** - Tipografías personalizadas

### Backend y Servicios
- **Firebase Core** - Plataforma de desarrollo web
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos NoSQL en tiempo real
- **Firebase Storage** - Almacenamiento de archivos
- **Firebase Hosting** - Hosting web escalable

### Funcionalidades Específicas
- **Table Calendar** - Widget de calendario interactivo
- **URL Launcher** - Apertura de enlaces externos
- **File Picker** - Selección y carga de archivos
- **Intl** - Internacionalización y formatos de fecha

### Herramientas de Desarrollo
- **Flutter Web** - Compilación para navegadores
- **Firebase CLI** - Herramientas de línea de comandos
- **Flutter Lints** - Análisis estático de código

## 📁 Estructura del proyecto

```
MyPetCare-web/
├── lib/
│   ├── main.dart                     # Punto de entrada de la aplicación
│   ├── 
│   ├── # Autenticación y Registro
│   ├── login.dart                    # Pantalla de login
│   ├── clinic_register.dart          # Registro de clínicas
│   ├── clinic_user_register.dart     # Registro de usuarios de clínica
│   ├── 
│   ├── # Dashboard Principal
│   ├── home.dart                     # Pantalla principal
│   ├── clinic_home.dart              # Dashboard de clínica
│   ├── 
│   ├── # Gestión de Pacientes
│   ├── patients.dart                 # Lista de pacientes
│   ├── pet_details.dart              # Detalles de mascota paciente
│   ├── clients.dart                  # Gestión de clientes/propietarios
│   ├── edit_user.dart                # Edición de usuarios
│   ├── 
│   ├── # Sistema de Citas
│   ├── appointment.dart              # Gestión de citas
│   ├── appointment_info.dart         # Información de citas
│   ├── assign_appointment.dart       # Asignación de citas
│   ├── reassign_appointment.dart     # Reasignación de citas
│   ├── schedule.dart                 # Programación general
│   ├── daily_schedule.dart           # Horario diario
│   ├── 
│   ├── # Gestión Médica
│   ├── prescription.dart             # Gestión de prescripciones
│   ├── prescriptionDetails.dart      # Detalles de prescripciones
│   ├── prescriptionList.dart         # Lista de prescripciones
│   ├── treatment.dart                # Gestión de tratamientos
│   ├── treatmentDetails.dart         # Detalles de tratamientos
│   ├── addTreatment.dart             # Añadir nuevo tratamiento
│   ├── 
│   ├── # Reportes y Documentación
│   ├── report.dart                   # Generación de reportes
│   ├── reportDetails.dart            # Detalles de reportes
│   ├── report_list.dart              # Lista de reportes
│   ├── 
│   ├── # Sistema de Adopciones
│   └── adoption.dart                 # Gestión de adopciones
├── 
├── web/                              # Configuración específica para web
├── assets/                           # Recursos de la aplicación
│   ├── LogoSinFondoOrange.png       # Logo naranja sin fondo
│   ├── LogoSinFondo.png             # Logo principal sin fondo
│   ├── nombreLogoSinFondo.png       # Logo con nombre sin fondo
│   └── web_imagen.png               # Imagen específica para web
├── 
├── firebase.json                     # Configuración de Firebase
├── pubspec.yaml                      # Dependencias y configuración
├── analysis_options.yaml            # Reglas de análisis de código
└── README.md                         # Documentación (este archivo)
```

## ⚙️ Configuración

### Variables de entorno requeridas

Crea un archivo `firebase_options.dart` en la carpeta `lib/` con la configuración de Firebase para web:

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
    // Configuración para otras plataformas si es necesario...
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    storageBucket: 'your-project.appspot.com',
  );
}
```

### Configuración de Firebase

1. **Crea un proyecto en Firebase Console**
2. **Habilita los siguientes servicios:**
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Hosting

3. **Configura Authentication:**
   - Habilita el proveedor Email/Password
   - Configura dominios autorizados para web

4. **Configura Cloud Firestore:**
   - Crea la base de datos en modo de producción
   - Configura reglas de seguridad apropiadas para clínicas

5. **Configura Firebase Hosting:**
   ```powershell
   firebase init hosting
   ```

### Configuración de seguridad

#### Reglas de Firestore recomendadas
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso solo a usuarios autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Reglas específicas para clínicas
    match /clinics/{clinicId} {
      allow read, write: if request.auth != null && 
        resource.data.authorizedUsers[request.auth.uid] == true;
    }
  }
}
```

## 🔧 Desarrollo

### Comandos útiles para web

```powershell
# Obtener dependencias
flutter pub get

# Ejecutar en modo debug para web
flutter run -d chrome

# Ejecutar en modo debug con hot reload
flutter run -d chrome --web-renderer html

# Ejecutar en modo release para web
flutter run -d chrome --release

# Generar build para producción
flutter build web

# Generar build optimizado
flutter build web --release

# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format .
```

### Desarrollo específico para web

1. **Responsive Design:** La aplicación está optimizada para diferentes tamaños de pantalla
2. **SEO Friendly:** Configurada para motores de búsqueda
3. **PWA Ready:** Preparada para ser una Progressive Web App
4. **Performance:** Optimizada para carga rápida en navegadores

### Estructura de desarrollo para clínicas

1. **Autenticación:** Sistema robusto para múltiples usuarios por clínica
2. **Roles y permisos:** Diferentes niveles de acceso (admin, veterinario, asistente)
3. **Multi-tenant:** Soporte para múltiples clínicas en la misma aplicación
4. **Datos en tiempo real:** Sincronización automática entre usuarios

## 🚀 Deployment

### Firebase Hosting

1. **Instalar Firebase CLI:**
```powershell
npm install -g firebase-tools
```

2. **Inicializar Firebase en el proyecto:**
```powershell
firebase login
firebase init hosting
```

3. **Generar build de producción:**
```powershell
flutter build web --release
```

4. **Configurar firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

5. **Desplegar a Firebase Hosting:**
```powershell
firebase deploy
```

### Otros servicios de hosting

#### Netlify
```powershell
# Después de flutter build web
# Subir la carpeta build/web a Netlify
```

#### Vercel
```powershell
# Instalar Vercel CLI
npm i -g vercel

# Desplegar
vercel --prod
```

### Variables de entorno para producción

Configura las siguientes variables antes del deployment:
- `FIREBASE_API_KEY`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`

## 🧪 Testing

### Ejecutar tests

```powershell
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests específicos
flutter test test/widget_test.dart

# Tests de integración para web
flutter drive --target=test_driver/app.dart
```

### Tipos de tests implementados

- **Unit Tests:** Testing de lógica de negocio para clínicas
- **Widget Tests:** Testing de componentes UI responsivos
- **Integration Tests:** Testing de flujos completos de trabajo clínico

### Testing específico para clínicas

- **Flujos de autenticación** de múltiples usuarios
- **Gestión de citas** y calendarios
- **Creación y edición** de pacientes
- **Generación de reportes** médicos

## 🐛 Bugs y solicitud de características

¿Tienes un bug o una solicitud de característica? Por favor, primero lee las [pautas de issues](https://github.com/GabrielJuan349/MyPetCare/blob/master/CONTRIBUTING.md) y busca entre los issues existentes y cerrados. Si tu problema o idea no está siendo abordada aún, [por favor abre un nuevo issue](https://github.com/GabrielJuan349/MyPetCare/issues/new).

### Reportar un bug específico de la aplicación web

1. **Especifica el navegador y versión** utilizada
2. **Incluye la URL** donde ocurre el problema
3. **Describe los pasos exactos** para reproducir el issue
4. **Incluye capturas de pantalla** de la consola del navegador
5. **Menciona el tamaño de pantalla** si es relevante

### Solicitar una característica para clínicas

1. **Describe claramente** la funcionalidad deseada para clínicas
2. **Explica el flujo de trabajo** veterinario que mejoraría
3. **Considera la usabilidad** en diferentes dispositivos
4. **Proporciona casos de uso** específicos de clínicas

## 🤝 Contribución

Por favor, lee nuestras [pautas de contribución](https://github.com/GabrielJuan349/MyPetCare/blob/master/CONTRIBUTING.md). Se incluyen direcciones para abrir issues, estándares de codificación y notas sobre desarrollo.

### Proceso de contribución para la aplicación web

1. **Fork el repositorio**
2. **Crea una rama para tu característica** (`git checkout -b feature/ClinicFeature`)
3. **Testa en múltiples navegadores** (Chrome, Firefox, Safari, Edge)
4. **Verifica responsive design** en diferentes tamaños de pantalla
5. **Commit tus cambios** (`git commit -m 'Add ClinicFeature'`)
6. **Push a la rama** (`git push origin feature/ClinicFeature`)
7. **Abre un Pull Request**

### Guías específicas para desarrollo web

- **Responsive Design:** Asegúrate de que funcione en móvil, tablet y desktop
- **Performance:** Optimiza imágenes y recursos para web
- **Accessibility:** Sigue las pautas WCAG para accesibilidad
- **Browser Compatibility:** Testa en navegadores principales