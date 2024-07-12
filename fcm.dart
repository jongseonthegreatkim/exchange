import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FirebaseNotification {
  // 서비스 계정 JSON 파일의 경로를 여기에 넣으세요
  static const String serviceAccountKeyPath = 'assets/exchangeServiceAccountKey.json';

  // Google Cloud Project ID
  static const String projectId = 'exchange-9ac12';

  static Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      json.decode(await File(serviceAccountKeyPath).readAsString()),
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    return client.credentials.accessToken.data;
  }

  static Future<void> sendNotificationToUser(String deviceToken, String title, String body) async {
    final String accessToken = await getAccessToken();
    final String endpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully!');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
