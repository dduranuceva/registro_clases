import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:registro_clases/models/establecimiento.dart';
import 'package:registro_clases/services/establecimiento_services.dart';

class EstablecimientoEditView extends StatefulWidget {
  final int id;

  const EstablecimientoEditView({super.key, required this.id});

  @override
  State<EstablecimientoEditView> createState() =>
      _EstablecimientoEditViewState();
}

class _EstablecimientoEditViewState extends State<EstablecimientoEditView> {
  // ! Se inicializa el servicio para obtener los datos del establecimiento
  // ! Se inicializa el key para el formulario
  //GlobalKey<FormState>() se usa para validar el formulario
  // y para acceder a los datos del formulario

  final _formKey = GlobalKey<FormState>();
  // Se inicializa el servicio para obtener los datos del establecimiento
  // y para actualizar los datos del establecimiento
  final _service = EstablecimientoService();

  // **Se inicializan los controladores para los campos de texto

  late TextEditingController _nombreController;
  late TextEditingController _nitController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;

  File? _logoFile;
  String? _logoUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEstablecimiento();
  }

  //! loadEstablecimiento
  /// Carga los datos del establecimiento desde la API
  Future<void> _loadEstablecimiento() async {
    try {
      // Se obtiene el establecimiento desde la API
      // widget.id es el id del establecimiento que se pasa por la ruta
      // y se usa para obtener los datos del establecimiento
      final est = await _service.getEstablecimiento(widget.id);
      if (!mounted) return; //! verifica si el widget esta montado

      setState(() {
        _nombreController = TextEditingController(text: est.nombre);
        _nitController = TextEditingController(text: est.nit);
        _direccionController = TextEditingController(text: est.direccion);
        _telefonoController = TextEditingController(text: est.telefono);
        _logoUrl = est.logo;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando datos')));
      context.pop();
    }
  }

  //! pickImage se utiliza para seleccionar una imagen de la galeria
  /// Selecciona una imagen de la galería y la asigna a _logoFile.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  //! submit se utiliza para enviar los datos del formulario
  ///* Valida el formulario y envía los datos a la API para actualizar el establecimiento.
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      //** se crea un objeto Establecimiento con los datos del formulario
      final est = Establecimiento(
        id: widget.id,
        nombre: _nombreController.text,
        nit: _nitController.text,
        direccion: _direccionController.text,
        telefono: _telefonoController.text,
        logo: _logoUrl ?? '',
        estado: 'A',
      );

      final ok = await _service.updateEstablecimiento(est, logoFile: _logoFile);

      if (!mounted) return;

      if (ok) {
        // ! Devolver true al pop para que la lista lo reciba
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Establecimiento actualizado')));
        //! se usa para volver a la pantalla anterior y recargar los datos
        context.pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error actualizando')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Establecimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _nitController,
                decoration: const InputDecoration(labelText: 'NIT'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              Text('Logo actual:'),
              const SizedBox(height: 8),
              _logoFile != null
                  ? Image.file(_logoFile!, height: 120)
                  : _logoUrl != null
                  //! Se muestra la imagen del logo actual si existe
                  ? Image.network(
                      '${_service.baseUrlImg}$_logoUrl',
                      height: 120,
                    )
                  : const Text('No tiene logo'),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Cambiar logo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
