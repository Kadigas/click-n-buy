import 'package:fp_ppb/service/api_key_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationCloudService {
  final key = APIKeyService().getAPIKey();

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await http.get(Uri.parse('https://api.rajaongkir.com/starter/province'), headers: {'key': key});

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['rajaongkir']['results'];
      return data.map((province) => {'id': province['province_id'], 'name': province['province']}).toList();
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<Map<String, dynamic>>> getCities(String provinceId) async {
    final response = await http.get(Uri.parse('https://api.rajaongkir.com/starter/city?province=$provinceId'), headers: {'key': key});

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['rajaongkir']['results'];
      return data.map((city) => {'id': city['city_id'], 'name': city['city_name']}).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<String?> getCityName(String provinceId, cityId) async {
    try {
      final cities = await getCities(provinceId);
      return cities.firstWhere((item) => item['id'] == cityId)['name'];
    } catch (e) {
      return 'Unknown City';
    }
  }
}