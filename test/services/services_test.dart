import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

Future<void> verificarIdiomaAutomatico() async {
 // Detects the system language
// If the system contains "pt" (indicating Portuguese), systemLanguage will be set to 'pt'; otherwise, it defaults to 'en', representing English.

  String systemLanguage = Platform.localeName.contains('pt') ? 'pt' : 'en';

// Sets the initial URL based on the system language
  Uri url = systemLanguage == 'pt'
      ? Uri.parse('https://bitcoincounterflow.com/pt/satsails-2/mini-paineis-iframe/')
      : Uri.parse('https://bitcoincounterflow.com/satsails/dashboards-iframe');

 // An HTTP Accept-Language header is sent with the request, indicating the desired language for the response (Portuguese or English).
  final response = await http.get(
    url,
    headers: {
      'Accept-Language': systemLanguage,
    },
  );

// Checks if the response was successful and matches the expected language
if (response.statusCode == 200) {
  print('Page loaded successfully for language $systemLanguage.');
  if (systemLanguage == 'pt' && url.path.contains('/pt/')) {
    print('URL confirmed for the Portuguese version.');
  } else if (systemLanguage == 'en' && url.path.contains('/dashboards-iframe')) {
    print('URL confirmed for the English version.');
  } else {
    print('The final URL does not match the expected language.');
  }
} else {
  print('Error loading the page. Status: ${response.statusCode}');
}

}

// The main function calls verificarIdiomaAutomatico() to run the test based on the system language
void main() async {
  print('Testando redirecionamento com base no idioma do sistema:');
  await verificarIdiomaAutomatico();
}
