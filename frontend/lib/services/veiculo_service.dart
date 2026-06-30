import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/veiculo.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VeiculoService {
  final String baseUrl = 'https://projetoiiii-production.up.railway.app';

  Future<Map<String, dynamic>> salvar(Veiculo veiculo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/veiculo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(veiculo.toJson()),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Erro ao conectar com o servidor.'};
    }
  }

  Future<Veiculo?> pesquisar(String placa) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/veiculo/$placa'));

      if (response.statusCode == 200) {
        return Veiculo.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> alterar(String placa, Veiculo veiculo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/veiculo/$placa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(veiculo.toJson()),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Erro ao conectar com o servidor.'};
    }
  }

  Future<Map<String, dynamic>> excluir(String placa) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/veiculo/$placa'));

      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Erro ao conectar com o servidor.'};
    }
  }

  Future<String> downloadTxt() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/veiculo/download'));

      if (response.statusCode == 200) {
        final directory = await getDownloadsDirectory();
        final filePath = '${directory!.path}/veiculo.txt';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return 'Arquivo salvo em: $filePath';
      }

      return 'Erro ao baixar o arquivo.';
    } catch (e) {
      return 'Erro ao conectar com o servidor.';
    }
  }
}
