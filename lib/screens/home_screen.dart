import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_audio_analysis_flutter_app/screens/TryPlusScreen.dart';

import '../theme.dart';
import '../services/locale_provider.dart';
import '../services/audio_analysis_service.dart';
import '../models/song_analysis.dart';
import '../widgets/result_card.dart';
import '../widgets/waveform_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _recorder = AudioRecorder();

  bool _isRecording = false;
  bool _isAnalyzing = false;

  String? _selectedFilePath;
  String? _recordingPath;

  SongAnalysis? _result;
  String? _error;

  late AnimationController _analyzeController;

  @override
  void initState() {
    super.initState();

    _analyzeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _analyzeController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  // 🔥 ANALYZE FILE (NO API KEY CHECK ANYMORE)
  Future<void> _analyzeFile(String path) async {
    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final service = AudioAnalysisService();
      final result = await service.analyzeAudioFile(path);

      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp4', 'm4a', 'wav', 'aac', 'ogg', 'flac'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _result = null;
        _error = null;
      });

      await _analyzeFile(_selectedFilePath!);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _recordingPath = path;
        _result = null;
        _error = null;
      });

      if (path != null) {
        await _analyzeFile(path);
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _selectedFilePath = null;
        _result = null;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.8),
                radius: 1.0,
                colors: [Color(0xFF1A1428), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildAppBar(l10n, localeProvider),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildUploadCard(l10n),
                        const SizedBox(height: 20),
                        _buildDivider(l10n),
                        const SizedBox(height: 20),
                        _buildRecordCard(l10n),
                        const SizedBox(height: 32),
                        if (_isAnalyzing) _buildAnalyzingWidget(l10n),
                        if (_error != null) _buildErrorWidget(l10n),
                        if (_result != null)
                          ResultCard(song: _result!, l10n: l10n),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _buildAppBar(AppLocalizations l10n, LocaleProvider localeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.home_title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: localeProvider.toggleLocale,
                child: _ActionButton(
                  icon: Icons.language,
                  label: l10n.change_language,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TryPlusScreen()),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppColors.background,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(AppLocalizations l10n) {
    final isSelected = _selectedFilePath != null;

    return GestureDetector(
      onTap: _isAnalyzing ? null : _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.audio_file : Icons.upload_file,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              isSelected
                  ? _selectedFilePath!.split('/').last
                  : l10n.upload_file,
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.or_divider),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildRecordCard(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : _toggleRecording,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isRecording ? AppColors.recordingRed : AppColors.divider,
            width: _isRecording ? 1.5 : 1,
          ),
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: AppColors.recordingRed.withOpacity(0.15),
                    blurRadius: 25,
                    spreadRadius: 3,
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            if (_isRecording)
              const WaveformWidget()
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.2),
                      AppColors.accentLight.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.accentLight,
                  size: 30,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? l10n.recording : l10n.record_audio,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isRecording
                    ? AppColors.recordingRed
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isRecording ? l10n.stop_recording : l10n.record_desc,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnalyzingWidget(AppLocalizations l10n) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n) {
    return Text(
      _error ?? "Error",
      style: const TextStyle(color: Colors.red),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
