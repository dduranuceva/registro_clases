import 'package:flutter/material.dart';

import '../../models/cdt.dart';
import '../../services/cdt_service.dart';
import '../../widgets/base_view.dart';

class CDTListView extends StatefulWidget {
  const CDTListView({super.key});

  @override
  State<CDTListView> createState() => _CDTListViewState();
}

class _CDTListViewState extends State<CDTListView> {
  //* Se crea una instancia de la clase CDTService
  final CDTService _cdtService = CDTService();
  //* Se declara una variable de tipo Future que contendrá la lista de CDTs
  late Future<List<CDT>> _futureCDTs;

  @override
  void initState() {
    super.initState();
    //! Se llama al método getCDTs de la clase CDTService
    _futureCDTs = _cdtService.getCDTs();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'CDT - Lista de Certificados',
      //! Se crea un FutureBuilder que se encargará de construir la lista de CDTs
      //! FutureBuilder se utiliza para construir widgets basados en un Future
      body: FutureBuilder<List<CDT>>(
        future: _futureCDTs,
        builder: (context, snapshot) {
          //snapshot contiene la respuesta del Future
          if (snapshot.hasData) {
            //* Se obtiene la lista de CDTs
            final cdts = snapshot.data!;
            //ListView.builder se utiliza para construir una lista de elementos de manera eficiente
            return ListView.builder(
              itemCount: cdts.length,
              itemBuilder: (context, index) {
                final cdt = cdts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre de la entidad (encabezado principal)
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  cdt.nombreentidad,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          // Descripción del CDT
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.description,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  cdt.descripcion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Tasa y Monto en una fila
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tasa
                              Row(
                                children: [
                                  const Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tasa',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${cdt.tasa}%',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Monto
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Monto',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '\$${_formatMonto(cdt.monto)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Método auxiliar para formatear el monto con separadores de miles
  String _formatMonto(String monto) {
    try {
      final number = double.parse(monto);
      return number
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (e) {
      return monto;
    }
  }
}
