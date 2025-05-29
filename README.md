<p align="center">
  <a href="https://github.com/GabrielJuan349/MyPetCare">
    <img alt="MyPetCare Logo" src="./logo/nombreLogoSinFondo.png" width="350" height="250">
  </a>
</p>

<p align="center">MyPetCare es una plataforma innovadora para el cuidado integral de mascotas, que integra un backend RESTful escalable con Deno y TypeScript, una aplicación móvil multiplataforma desarrollada en Flutter para propietarios, y un panel web optimizado para clínicas veterinarias. Con funcionalidades completas de gestión de perfiles de mascotas, programación de citas, seguimiento de tratamientos y vacunaciones, procesos de adopción y comunicación en tiempo real, MyPetCare ofrece una experiencia segura y eficiente tanto para usuarios finales como para profesionales veterinarios.</p>

# MyPetCare 🐾

**Plataforma integral de cuidado de mascotas** que combina:

- Un **Backend API** con Deno y TypeScript
- Una **Aplicación Móvil** multiplataforma con Flutter
- Una **Aplicación Web** para clínicas veterinarias con Flutter Web

## 📋 Tabla de contenido

- [Visión General](#visión-general)
- [Ecosistema de la Plataforma](#ecosistema-de-la-plataforma)
  - [Backend API](#backend-api)
  - [Aplicación Móvil](#aplicación-móvil)
  - [Aplicación Web](#aplicación-web)
- [Instalación y Configuración](#instalación-y-configuración)
- [Contribución](#contribución)
- [Licencia](#licencia)

## 🔍 Visión General

MyPetCare ofrece un sistema completo para gestionar mascotas, citas veterinarias, tratamientos, adopciones y comunicación entre propietarios y clínicas.

Cada componente está separado en carpetas:

```
MyPetCare/
├── MyPetCare-api/      # Backend RESTful con Deno 2.0 y Swagger
├── MyPetCare-App/      # App móvil Flutter para usuarios finales
└── MyPetCare-web/      # App web Flutter para clínicas veterinarias
```

## 🌐 Ecosistema de la Plataforma

### 🔧 Backend API
Ruta: [`MyPetCare-api/README.md`](./MyPetCare-api/README.md)

- Lenguaje: **TypeScript**, Deno 2.0
- Framework: **Oak**
- Autenticación: **JWT**, Firebase Auth
- Base de datos: **Firebase Firestore**
- Documentación: **Swagger UI** disponible en `/docs`

### 📱 Aplicación Móvil
Ruta: [`MyPetCare-App/README.md`](./MyPetCare-App/README.md)

- Framework: **Flutter 3.x**, Dart
- Autenticación: Email/Password, Google Sign-In
- Sincronización: **Cloud Firestore**, **Firebase Messaging**
- Funcionalidades: Gestión de mascotas, citas, vacunas, recordatorios y adopciones

### 💻 Aplicación Web
Ruta: [`MyPetCare-web/README.md`](./MyPetCare-web/README.md)

- Framework: **Flutter Web**, Dart
- Autenticación: Firebase Auth (Email)
- Gestión: Clínicas, veterinarios, pacientes, citas, tratamientos y reportes
- Hosting: **Firebase Hosting** o alternativa (Netlify, Vercel)

## ⚙️ Instalación y Configuración

### Requisitos Previos

- **Git**  
- **Deno 2.0** (para el backend)  
- **Node.js & npm** (opcional para herramientas de Firebase CLI)  
- **Flutter SDK** (para App móvil y web)  
- **Firebase CLI**  

### Pasos Generales

1. Clona el repositorio:
   ```powershell
   git clone https://github.com/GabrielJuan349/MyPetCare.git
   cd MyPetCare
   ```
2. Lee los README específicos en cada carpeta:
   - `MyPetCare-api/README.md`
   - `MyPetCare-App/README.md`
   - `MyPetCare-web/README.md`
3. Instala y configura cada componente según sus instrucciones.


## 👥 Creadores

**Yelennis Brissey Laura**
- GitHub: [yelennislaura](https://github.com/yelennislaura)
- LinkedIn: [Yelennis Brissey Laura](https://www.linkedin.com/in/yelennis-brissey-laura-rodriguez-548b94277/)

**Gabriel Juan**
- GitHub: [GabrielJuan349](https://github.com/GabrielJuan349)
- LinkedIn: [Gabriel Juan](https://www.linkedin.com/in/gabi-juan)

**Marc García**
- GitHub: [MarcGarciaUAB](https://github.com/MarcGarciaUAB)

**Laia Ubeda**
- GitHub: [laiaubvi](https://github.com/laiaubvi)
- LinkedIn: [Laia Úbeda Vivet](https://www.linkedin.com/in/laia-úbeda-vivet-1445b6354)

**Eric Sánchez**
- GitHub: [ericsiz](https://github.com/ericsiz)
- LinkedIn: [Eric Sánchez](https://www.linkedin.com/in/eric-sánchez-ibañez-de-zuazo-70b747229)

**Xinyu Yu**
- GitHub: [itsYu04](https://github.com/itsYu04)
- LinkedIn: [Xinyu Yu](https://www.linkedin.com/in/x-yu)

**Daniel Bello**
- GitHub: [DaBM17](https://github.com/DaBM17)

**Daniel Bermúdez**
- GitHub: [DanielBG26](https://github.com/DanielBG26)
- LinkedIn: [Daniel Bermúdez Galván](https://www.linkedin.com/in/daniel-bermudez-galvan-135702244/)

## 🤝 Contribución

¡Toda ayuda es bienvenida! Lee las pautas de contribución en [CONTRIBUTING.md](./CONTRIBUTING.md) y sigue estos pasos:

1. Haz **fork** del repositorio.
2. Crea una rama para tu característica (`git checkout -b feature/nombre`).
3. Realiza tus cambios y pruebas.
4. Haz **commit** y **push**.
5. Abre un **Pull Request** describiendo tus cambios.

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**. Consulta [LICENSE.md](./LICENSE.md) para más detalles.
<p align="center">
  Desarrollado con ❤️ por el equipo de MyPetCare
</p>
