import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AttendanceProvider {
  Future<List<Map<String, dynamic>>> fetchAttendanceData(DateTime startDate, DateTime endDate) async {
    final apiUrl = '${dotenv.env['API_BASE_URL']}/attendance/';
    final response = await http.get(Uri.parse('$apiUrl?start_date=$startDate&end_date=$endDate'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => {
        'date': DateTime.parse(item['date']),
        'total_attendance': item['total_attendance']
      }).toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }
}
