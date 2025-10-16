import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:registro_clases/models/establecimiento.dart';
import 'package:registro_clases/services/establecimiento_services.dart';
import 'package:registro_clases/views/establecimientos/establecimiento_eliminar_view.dart';
import 'package:registro_clases/widgets/base_view.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  EstablecimientosListViewState createState() =>
      EstablecimientosListViewState();
}

class EstablecimientosListViewState extends State<EstablecimientosListView> {
  final EstablecimientoService _service = EstablecimientoService();
  late Future<List<Establecimiento>> _future;

  @override
  void initState() {
    super.initState();
    //! Se inicializa el futuro para obtener los establecimientos
    _future = _service.getEstablecimientos();
  }

  //! método para navegar a la vista de editar establecimiento
  //! Recibe el id del establecimiento a editar
  Future<void> _goToEdit(int id) async {
    final result = await context.push('/establecimientos/edit/$id');

    //! Si el resultado es true, significa que se actualizó algo
    //! y se recarga la lista de establecimientos
    if (result == true) {
      setState(() {
        _future = _service.getEstablecimientos();
      });
    }
  }

  //! método para navegar a la vista de crear nuevo establecimiento
  Future<void> _goToCreate() async {
    final result = await context.push('/establecimientos/create');

    //! Si se creó correctamente, se recarga la lista
    if (result == true) {
      setState(() {
        _future = _service.getEstablecimientos();
      });
    }
  }

  //! Confirmación para eliminar establecimiento
  Future<void> _confirmDelete(int id) async {
    try {
      final ok = await _service.deleteEstablecimiento(id);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Establecimiento eliminado correctamente'),
          ),
        );
        setState(() {
          _future = _service.getEstablecimientos();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No se pudo eliminar')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Establecimientos',
      //* Se usa el FutureBuilder para construir la lista de establecimientos
      body: FutureBuilder<List<Establecimiento>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay establecimientos disponibles'),
            );
          }

          final establecimientos = snapshot.data!;

          return ListView.builder(
            itemCount: establecimientos.length + 1, // +1 para el botón de crear
            itemBuilder: (context, index) {
              //! Primer ítem será el botón de crear
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _goToCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear nuevo establecimiento'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }

              //! índice real de la lista (descontando el botón de crear)
              final establecimiento = establecimientos[index - 1];

              return GestureDetector(
                onTap: () => _goToEdit(establecimiento.id),
                onLongPress: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => const EstablecimientoEliminarView(
                      title: '¿Eliminar establecimiento?',
                      message:
                          '¿Estás seguro que deseas eliminar este establecimiento?',
                    ),
                  );

                  if (confirm == true) {
                    await _confirmDelete(establecimiento.id);
                  }
                },
                child: Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //! Se muestra el logo si está disponible
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: establecimiento.logo.isNotEmpty
                              ? Image.network(
                                  '${_service.baseUrlImg}${establecimiento.logo}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, size: 80),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                establecimiento.nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('NIT: ${establecimiento.nit}'),
                              Text('Dirección: ${establecimiento.direccion}'),
                              Text('Teléfono: ${establecimiento.telefono}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
