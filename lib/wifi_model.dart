import 'dart:convert';

class WiFiNetwork {
  final String ssid;
  final String passwordEncrypted;
  final double latitude;
  final double longitude;

  WiFiNetwork({
    required this.ssid,
    required this.passwordEncrypted,
    required this.latitude,
    required this.longitude,
  });

  
  factory WiFiNetwork.fromJson(Map<String, dynamic> json) {
    return WiFiNetwork(
      ssid: json['ssid'] as String,
      passwordEncrypted: json['password_encrypted'] as String,
      latitude: json['location']['latitude'] as double,
      longitude: json['location']['longitude'] as double,
    );
  }

  
  String get decryptedPassword {
    try {
      return utf8.decode(base64.decode(passwordEncrypted));
    } catch (e) {
      
      print('Error decoding password for SSID $ssid: $e');
      return 'Decoding Error';
    }
  }
}