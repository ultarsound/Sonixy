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
      songName: json['song_name'] ?? 'Unknown Song',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      description: json['description'],
      genre: json['genre'],
      year: json['year'],
      youtubeUrl: json['youtube_url'],
      spotifyUrl: json['spotify_url'],
      confidence: json['confidence']?.toDouble(),
      albumName: json['album_name'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  factory SongAnalysis.mock() {
    return SongAnalysis(
      songName: 'Blinding Lights',
      artistName: 'The Weeknd',
      description:
          'A synth-pop and new wave song from the album After Hours (2020). The song features a pulsating synthwave beat with 80s-inspired production.',
      genre: 'Synth-pop / New Wave',
      year: '2019',
      youtubeUrl: 'https://www.youtube.com/watch?v=4NRXx6U8ABQ',
      spotifyUrl:
          'https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b',
      confidence: 0.97,
      albumName: 'After Hours',
      tags: ['80s', 'Synthwave', 'Pop', 'Upbeat'],
    );
  }
}
