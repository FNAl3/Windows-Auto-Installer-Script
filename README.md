# 🚀 Windows Auto-Installer Script

Un script de PowerShell sencillo y potente para automatizar la instalación de software en nuevas instalaciones de Windows (o para mantener tus equipos al día).

## 📋 Características

*   **Instalación Silenciosa Universal**: Detecta automáticamente archivos `.exe` y `.msi` en la carpeta y los instala de forma desatendida (sin pulsar "Siguiente").
*   **Descargas Automáticas**: Si no encuentra los instaladores clave, los descarga automáticamente por ti:
    *   Google Chrome
    *   Epic Games Launcher
    *   EA App
    *   League of Legends (EUW)
*   **Gestión Inteligente**:
    *   Solicita permisos de Administrador si no los tiene.
    *   Evita conflictos de versiones (ej. prefiere instaladores EXE de WinRAR sobre MSI genéricos).
    *   Base de datos interna de argumentos silenciosos para apps populares (Steam, Discord, VSCode, Node.js, Git, etc.).

## 🛠️ Requisitos

*   Windows 10 / 11
*   PowerShell 5.1 o superior (viene instalado por defecto).
*   Conexión a Internet (para las descargas automáticas).

## 🚀 Cómo usarlo

1.  **Descarga** este repositorio o el archivo `Instalar-Todo.ps1`.
2.  (Opcional) Coloca cualquier otro instalador `.exe` o `.msi` que quieras instalar en la misma carpeta.
3.  **Ejecuta el script**:
    *   Haz clic derecho sobre `Instalar-Todo.ps1` y selecciona **"Ejecutar con PowerShell"**.
4.  El script te pedirá permisos de Administrador, descargará lo que falte y comenzará a instalar todo uno por uno.

## 📦 Lista de Software Soportado (Native)

El script ya conoce los comandos silenciosos para muchas aplicaciones, incluyendo:
*   **Navegadores**: Google Chrome, Brave.
*   **Gaming**: Steam, Epic Games, League of Legends, EA App, GeForce Experience.
*   **Social/Música**: Spotify, WhatsApp.
*   **Desarrollo**: VSCode, Git, Node.js, XAMPP.
*   **Utilidades**: WinRAR, 7-Zip, Discord, CrystalDiskInfo.

*Si pones una app que no está en la lista, intentará instalarla normalmente (con interfaz).*

## ⚠️ Nota

Este script está diseñado para facilitar la configuración inicial de un PC. Úsalo bajo tu propia responsabilidad.

---
Creado con ❤️ para ahorrar tiempo.
