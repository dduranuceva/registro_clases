# Widgets de Establecimientos

Esta carpeta contiene los widgets específicos para el módulo de Establecimientos.

## 📁 Estructura

```
widgets/
├── establecimiento_form.dart              → Widget principal del formulario
├── establecimiento_form_fields.dart       → Campos del formulario (Nombre, NIT, etc.)
└── establecimiento_image_picker.dart      → Selector y preview de imagen
```

## 🎯 Filosofía de Diseño

### Separación de Responsabilidades (SRP)
Cada widget tiene una **única responsabilidad**:

- **establecimiento_form.dart**: Coordina el formulario completo y maneja el submit
- **establecimiento_form_fields.dart**: Renderiza y valida los campos de texto
- **establecimiento_image_picker.dart**: Maneja la selección y previsualización de imágenes

### Ventajas de esta Estructura

✅ **Mantenibilidad**: Archivos más pequeños y enfocados
✅ **Reutilización**: Los widgets pueden usarse independientemente
✅ **Testabilidad**: Más fácil de testear por separado
✅ **Legibilidad**: Código más fácil de entender

## 📖 Uso

### Ejemplo Completo

```dart
import 'widgets/establecimiento_form.dart';

EstablecimientoForm(
  initial: establecimiento,      // null para crear, objeto para editar
  logoUrl: 'logo.png',           // URL del logo existente (opcional)
  baseUrlImg: 'https://api.com/images/',
  onSubmit: (formData) {
    // Manejar el submit
    print(formData.nombre);
    print(formData.nit);
    print(formData.logoFile);
  },
  isSubmitting: false,            // true para mostrar loading
)
```

### Uso Individual de Widgets

#### Solo los Campos
```dart
import 'widgets/establecimiento_form_fields.dart';

EstablecimientoFormFields(
  nombreController: _nombreController,
  nitController: _nitController,
  direccionController: _direccionController,
  telefonoController: _telefonoController,
  isEnabled: true,
)
```

#### Solo el Selector de Imagen
```dart
import 'widgets/establecimiento_image_picker.dart';

EstablecimientoImagePicker(
  logoUrl: 'logo.png',
  baseUrlImg: 'https://api.com/images/',
  isEnabled: true,
  onImageSelected: (file) {
    print('Imagen seleccionada: ${file?.path}');
  },
)
```

## 🔄 Comunicación entre Widgets

Los widgets se comunican mediante **callbacks**:

```dart
// El hijo notifica al padre
EstablecimientoImagePicker(
  onImageSelected: (file) {
    // El padre recibe la notificación
    setState(() => _logoFile = file);
  }
)
```

## 📐 Arquitectura

```
EstablecimientoForm (Padre)
├── Maneja estado global del formulario
├── Coordina la validación
├── Ejecuta el callback onSubmit
│
├──> EstablecimientoFormFields (Hijo)
│    └── Renderiza y valida campos
│
└──> EstablecimientoImagePicker (Hijo)
     └── Maneja selección de imagen
```

## 🎓 Notas para Estudiantes

### ¿Por qué separar en múltiples archivos?

**Antes (1 archivo grande):**
- ❌ Difícil de leer (mucho scroll)
- ❌ Difícil de mantener
- ❌ Cambios pequeños afectan todo el archivo
- ❌ Difícil de reutilizar partes

**Ahora (3 archivos pequeños):**
- ✅ Fácil de leer (archivos enfocados)
- ✅ Fácil de mantener
- ✅ Cambios aislados
- ✅ Widgets reutilizables

### Principios Aplicados

1. **Single Responsibility Principle (SRP)**: Cada widget hace una cosa
2. **Composition over Inheritance**: Componemos widgets pequeños
3. **Separation of Concerns**: Separamos lógica de presentación
4. **DRY (Don't Repeat Yourself)**: Reutilizamos componentes

---

**Última actualización**: Octubre 2025
**Autor**: Equipo de Desarrollo UCEVA
