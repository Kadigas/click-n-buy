import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationCloudService {
  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await http.get(Uri.parse('https://alamat.thecloudalert.com/api/provinsi/get/'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result'];
      return data.map((province) => {'id': province['id'], 'name': province['text']}).toList();
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<List<Map<String, dynamic>>> getCities(String provinceId) async {
    final response = await http.get(Uri.parse('https://alamat.thecloudalert.com/api/kabkota/get/?d_provinsi_id=$provinceId'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result'];
      return data.map((city) => {'id': city['id'], 'name': city['text']}).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<List<Map<String, dynamic>>> getDistricts(String cityId) async {
    final response = await http.get(Uri.parse('https://alamat.thecloudalert.com/api/kecamatan/get/?d_kabkota_id=$cityId'));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['result'];
      return data.map((district) => {'id': district['id'], 'name': district['text']}).toList();
    } else {
      throw Exception('Failed to load districts');
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