import 'dart:convert'; // Required for base64 decoding

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

  // Factory constructor to create a WiFiNetwork object from a JSON map
  factory WiFiNetwork.fromJson(Map<String, dynamic> json) {
    return WiFiNetwork(
      ssid: json['ssid'] as String,
      passwordEncrypted: json['password_encrypted'] as String,
      latitude: json['location']['latitude'] as double,
      longitude: json['location']['longitude'] as double,
    );
  }

  // Method to decode the base64 encrypted password
  String get decryptedPassword {
    try {
      return utf8.decode(base64.decode(passwordEncrypted));
    } catch (e) {
      // Handle decoding errors gracefully
      print('Error decoding password for SSID $ssid: $e');
      return 'Decoding Error';
    }
  }
}