import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/song_analysis.dart';

class AudioAnalysisService {
  static const String apiToken = "2500e15f082fb496fed4f3c27c27a92d";

  Future<SongAnalysis> analyzeAudioFile(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.audd.io/'),
      );

      request.fields['api_token'] = apiToken;
      request.fields['return'] = 'spotify,youtube';

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      final data = jsonDecode(responseData);

      if (data['status'] == 'success' && data['result'] != null) {
        final result = data['result'];

        return SongAnalysis(
          songName: result['title'] ?? "Unknown",
          artistName: result['artist'] ?? "Unknown",
          albumName: result['album'] ?? "",
          year: "",
          genre: "",
          description: "Detected using AudD",
          youtubeUrl: result['youtube']?['url'] ?? "",
          spotifyUrl: result['spotify']?['external_urls']?['spotify'] ?? "",
          confidence: 1.0,
          tags: [],
        );
      } else {
        throw Exception("No match found");
      }
    } catch (e) {
      throw Exception("Analysis failed: $e");
    }
  }
}
