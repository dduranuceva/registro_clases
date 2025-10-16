import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/cdt.dart';

//! El CDTService es el encargado de hacer las peticiones a la API de CDT
class CDTService {
  // ! Se obtiene la url de la API desde el archivo .env
  String apiUrl = dotenv.env['CDT_API_URL']!;

  // ! Método para obtener la lista de CDTs
  // * Se hace una petición HTTP a la URL de la API y se obtiene la respuesta
  // * Si el estado de la respuesta es 200 se decodifica la respuesta y se obtiene la lista de CDTs
  // * La API retorna directamente un array de objetos JSON con los datos de CDTs

  Future<List<CDT>> getCDTs() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decodificar la respuesta que es un array JSON directamente
        final List<dynamic> data = json.decode(response.body);

        // Mapear cada elemento del array a una instancia de CDT
        List<CDT> cdtList = data.map((item) {
          return CDT.fromJson(item);
        }).toList();

        return cdtList;
      } else {
        throw Exception(
          'Error al obtener la lista de CDTs. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en getCDTs: $e');
      }
      throw Exception('Error al conectar con la API de CDTs: $e');
    }
  }

  // Método opcional para filtrar CDTs por entidad
  Future<List<CDT>> getCDTsByEntidad(String nombreEntidad) async {
    try {
      final allCDTs = await getCDTs();

      // Filtrar los CDTs que contengan el nombre de la entidad buscada
      return allCDTs
          .where(
            (cdt) => cdt.nombreentidad.toLowerCase().contains(
              nombreEntidad.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error en getCDTsByEntidad: $e');
      }
      throw Exception('Error al filtrar CDTs por entidad: $e');
    }
  }
}
