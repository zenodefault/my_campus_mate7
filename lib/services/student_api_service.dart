import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentApiService {
  static const String baseUrl =
      "https://69qx4momf7.execute-api.ap-south-1.amazonaws.com/default/sis";

  static const Map<String, String> headers = {
    "accept": "/",
    "accept-language": "en-GB,en-US;q=0.9,en;q=0.8",
    "dnt": "1",
    "origin": "https://connectwebbucket2.s3.ap-south-1.amazonaws.com/",
    "referer": "https://connectwebbucket2.s3.ap-south-1.amazonaws.com/",
    "sec-ch-ua": '"Chromium";v="139", "Not;A=Brand";v="99"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": '"Windows"',
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36"
  };

  /// Fetches student data from MS RIT Parents Portal API
  static Future<Map<String, dynamic>> fetchStudentData(String usn, String dob) async {
    try {
      // Convert DOB from DD/MM/YYYY to YYYY-MM-DD format for API
      final dobParts = dob.split('/');
      final formattedDob = "${dobParts[2]}-${dobParts[1]}-${dobParts[0]}";

      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "usn": usn,
        "dob": formattedDob,
      });

      final res = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final jsonData = json.decode(res.body);
        if (jsonData is Map<String, dynamic>) {
          return jsonData;
        } else {
          throw Exception("Invalid API response format");
        }
      } else {
        throw Exception("API returned status code ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch student data: $e");
    }
  }
}
