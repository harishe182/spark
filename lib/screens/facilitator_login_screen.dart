import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/navigation.dart';
import '../core/theme.dart';
import '../widgets/glass/glass.dart';
import '../widgets/research_info_sheet.dart';
import '../widgets/spark_character.dart';
import 'participant_setup_screen.dart';

/// Placeholder facilitator entry point. Real authentication is out of scope
/// for the MVP (the device is physically controlled by the facilitator); this
/// screen exists so the navigation structure and the "facilitator-first" flow
/// are in place. Password/auth can slot in here later without UI churn.
///
/// Stateful only to drive a gentle "floating" animation on the Spark mascot.
class FacilitatorLoginScreen extends StatefulWidget {
  const FacilitatorLoginScreen({super.key});

  @override
  State<FacilitatorLoginScreen> createState() => _FacilitatorLoginScreenState();
}

class _FacilitatorLoginScreenState extends State<FacilitatorLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      safeArea: false,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _bob,
                          builder: (context, child) {
                            final dy = -8 * _bob.value;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  SparkTheme.sparkYellow
                                      .withValues(alpha: 0.35),
                                  SparkTheme.sparkYellow
                                      .withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                            child: const SparkCharacter(size: 150),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppInfo.appName,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    SparkTheme.sparkAmber.withValues(alpha: 0.9),
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Creativity Challenge',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SparkTheme.secondaryLabel,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 18, color: SparkTheme.ink),
                              const SizedBox(width: 6),
                              Text(
                                'Facilitator Console',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: SparkTheme.ink),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: double.infinity,
                          child: GlassButton(
                            label: 'Enter',
                            icon: Icons.login_rounded,
                            color: SparkTheme.sparkAmber,
                            minimumSize: const Size.fromHeight(68),
                            stadium: true,
                            onPressed: () => pushSparkPage(
                              context,
                              const ParticipantSetupScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GlassNavIconAction(
                icon: CupertinoIcons.info_circle,
                color: SparkTheme.sparkAmber,
                tooltip: 'Research guide',
                onPressed: () => showResearchInfoSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
