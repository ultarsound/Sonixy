import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/song_analysis.dart';
import '../theme.dart';

class ResultCard extends StatelessWidget {
  final SongAnalysis song;
  final AppLocalizations l10n;

  const ResultCard({super.key, required this.song, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [AppColors.card, AppColors.surface],
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: AppColors.divider),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.music_note,
                  label: l10n.song_name,
                  value: song.songName,
                ),

                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.person,
                  label: l10n.artist_name,
                  value: song.artistName,
                ),

                const SizedBox(height: 24),

                /// ✅ LINKS FIXED
                _buildLinks(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            l10n.analysis_result,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildLinks() {
    return Column(
      children: [
        _LinkButton(
          icon: Icons.play_circle_fill,
          label: l10n.listen_youtube,
          url: song.youtubeUrl,
          songName: song.songName,
          artistName: song.artistName,
          isYoutube: true,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
          ),
        ),
        const SizedBox(height: 12),
        _LinkButton(
          icon: Icons.music_note,
          label: l10n.listen_spotify,
          url: song.spotifyUrl,
          songName: song.songName,
          artistName: song.artistName,
          isYoutube: false,
          gradient: const LinearGradient(
            colors: [Color(0xFF1DB954), Color(0xFF158A3E)],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Text("$label: $value"),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? url;
  final String songName;
  final String artistName;
  final bool isYoutube;
  final Gradient gradient;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.songName,
    required this.artistName,
    required this.isYoutube,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String finalUrl;

        if (url != null && url!.isNotEmpty) {
          finalUrl = url!;
        } else {
          final query = Uri.encodeComponent("$songName $artistName");

          if (isYoutube) {
            finalUrl = "https://www.youtube.com/results?search_query=$query";
          } else {
            finalUrl = "https://open.spotify.com/search/$query";
          }
        }

        final uri = Uri.parse(finalUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("❌ Could not launch $finalUrl");
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
