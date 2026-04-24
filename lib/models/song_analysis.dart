class SongAnalysis {
  final String songName;
  final String artistName;
  final String? description;
  final String? genre;
  final String? year;
  final String? youtubeUrl;
  final String? spotifyUrl;
  final double? confidence;
  final String? albumName;
  final List<String>? tags;

  SongAnalysis({
    required this.songName,
    required this.artistName,
    this.description,
    this.genre,
    this.year,
    this.youtubeUrl,
    this.spotifyUrl,
    this.confidence,
    this.albumName,
    this.tags,
  });

  factory SongAnalysis.fromJson(Map<String, dynamic> json) {
    return SongAnalysis(
      songName: json['title'] ?? json['song_name'] ?? 'Unknown Song',
      artistName: json['artist'] ?? json['artist_name'] ?? 'Unknown Artist',

      spotifyUrl: json['song_link'], // AudD

      youtubeUrl: json['youtube_url'],

      albumName: json['album'],
      year: json['release_date'],
      genre: null,

      confidence: (json['score'] != null)
          ? double.tryParse(json['score'].toString())
          : null,

      description: "Detected using AudD",

      tags: null,
    );
  }
}
