import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/locale_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final size = MediaQuery.of(context).size;
    final isRTL = localeProvider.isArabic;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          _buildBackground(size),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Language toggle
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
                    child:
                        _LanguageToggle(provider: localeProvider, l10n: l10n),
                  ).animate().fadeIn(delay: 500.ms),
                ),

                const Spacer(),

                // Central visual
                _buildCentralVisual(size),

                const SizedBox(height: 48),

                // Text content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        l10n.onboarding_title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: isRTL ? 42 : 44,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 12),
                      Text(
                        l10n.onboarding_subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 20),
                      Text(
                        l10n.onboarding_desc,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),

                const Spacer(),

                // CTA Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                  child: _buildCTAButton(l10n, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        // Deep gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF1A1428),
                Color(0xFF0A0A0F),
              ],
            ),
          ),
        ),

        // Rotating outer ring
        Center(
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (_, __) => Transform.translate(
              offset: const Offset(0, -60),
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Glow blobs
        Positioned(
          top: -100,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent
                        .withOpacity(0.06 + _pulseController.value * 0.04),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -50,
          left: -80,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withOpacity(0.05 + _pulseController.value * 0.03),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCentralVisual(Size size) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse rings
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final scale = 1.0 + (i * 0.25) + _pulseController.value * 0.08;
                final opacity =
                    (0.3 - i * 0.08) * (1 - _pulseController.value * 0.3);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(opacity),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Sound wave visual
          AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) => CustomPaint(
              size: const Size(200, 200),
              painter: _SoundWavePainter(_waveController.value),
            ),
          ),

          // Center circle
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primaryDark.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withOpacity(0.3 + _pulseController.value * 0.2),
                    blurRadius: 30 + _pulseController.value * 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.background,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 1000.ms)
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1));
  }

  Widget _buildCTAButton(AppLocalizations l10n, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, __) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            l10n.get_started,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 800.ms)
        .slideY(begin: 0.4, end: 0);
  }
}

class _LanguageToggle extends StatelessWidget {
  final LocaleProvider provider;
  final AppLocalizations l10n;

  const _LanguageToggle({required this.provider, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: provider.toggleLocale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              l10n.change_language,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundWavePainter extends CustomPainter {
  final double animValue;
  _SoundWavePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + animValue * 2 * math.pi;
      final barHeight = 20.0 + math.sin(animValue * 2 * math.pi + i) * 15;
      final x = center.dx + math.cos(angle) * 75;
      final y = center.dy + math.sin(angle) * 75;

      canvas.drawLine(
        Offset(x, y - barHeight / 2),
        Offset(x, y + barHeight / 2),
        paint
          ..color = AppColors.primary
              .withOpacity(0.2 + math.sin(animValue * math.pi + i) * 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SoundWavePainter old) =>
      old.animValue != animValue;
}
