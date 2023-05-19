import 'dart:convert';
import 'package:http/http.dart' as http;

class PaLM {
  static const String _baseUrl = String.fromEnvironment("PALM_ENDPOINT");
  static const String _apiKey = String.fromEnvironment("PALM_KEY");
  // Make the class a singleton
  static final PaLM _singleton = PaLM._internal();
  factory PaLM() => _singleton;
  PaLM._internal();
  // Create a private client object
  final http.Client _client = http.Client();

  // Define a public method that will make a POST request to the API with the given prompt and parameters
  Future<String> generateMessage(PaLMPrompt prompt) async {
    // Create the request URL by appending the base URL, API key and endpoint
    var requestUrl = Uri.parse(_baseUrl + _apiKey);

    // Create the request body by encoding the prompt map as JSON
    String requestBody = jsonEncode(prompt.toJson());

    // Make a POST request to the API with the request body and headers
    http.Response response = await _client.post(
      requestUrl,
      body: requestBody,
      headers: {'Content-Type': 'application/json'},
    );

    // Check if the response status code is 200 (OK)
    if (response.statusCode == 200) {
      // Parse the response body as JSON and return the output field
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['candidates'][0]['content'];
    } else {
      // Throw an exception if the response status code is not 200
      throw Exception('Failed to generate message: ${response.statusCode}');
    }
  }
}

// Define a Prompt class
class PaLMPrompt {
  // Declare instance variables
  String context = ""; // The context of the prompt
  Map<String, String> examples; // The input-output examples
  List<String> messages; // The previous messages
  double temperature; // The temperature parameter
  int topK; // The top_k parameter
  double topP; // The top_p parameter
  int candidateCount; // The candidate_count parameter

  // Define a constructor with named parameters
  PaLMPrompt(
      {this.context = "",
      this.examples = const {},
      this.messages = const [],
      this.temperature = 0.25,
      this.topK = 40,
      this.topP = 0.95,
      this.candidateCount = 1});

  // Define a method to convert the prompt to JSON (or a map)
  Map<String, dynamic> toJson() => {
        'prompt': {
          'context': context,
          'examples': examples.entries
              .map(
                (entry) => {
                  'input': {'content': entry.key},
                  'output': {'content': entry.value}
                },
              )
              .toList(),
          'messages': messages
              .map(
                (message) => {'content': message},
              )
              .toList(),
        },
        'temperature': temperature,
        'top_k': topK,
        'top_p': topP,
        'candidate_count': candidateCount,
      };
}