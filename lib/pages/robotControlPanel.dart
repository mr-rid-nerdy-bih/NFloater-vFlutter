import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:media_kit_video/media_kit_video.dart'; // Handles the custom Video() widget
import 'package:google_fonts/google_fonts.dart';

import '../../videoplayers.dart';
import '../../robotParts/radar.dart';
import '../../robotParts/steering.dart';

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double liveHeadingAngle = 0.0;

  @override
  void initState() {
    super.initState();
    
    // 1. FIXED: media_kit uses .state.playing on the Player instance, not the controller
    if (globalHUDVideoPlayer != null && !globalHUDVideoPlayer!.state.playing) {
      globalHUDVideoPlayer!.play();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          liveHeadingAngle = math.sin(_animationController.value * math.pi * 2) * (math.pi / 3) - (math.pi / 2);
        });
      });
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF011627)),
          
          // BACKGROUND HUD AMBIENT VIDEO LAYER
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35, 
                child: globalHUDVideoController != null
                    ? SizedBox.expand(
                        child: Video(
                          controller: globalHUDVideoController!,
                          fit: BoxFit.cover, // 2. FIXED: media_kit handles internal FittedBox handling natively!
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.02, 
              child: const GridPaper(divisions: 2, interval: 60, subdivisions: 1),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.cyanAccent, size: 16),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'PILOT_HUD_INTERFACE // REAL_TIME_METRICS',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.white70, 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 2
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LINK_OK', 
                            style: GoogleFonts.shareTechMono(
                              color: Colors.greenAccent, 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      )
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 16),

                  Expanded(
                    child: Row(
                      children: [
                        
                        // LEFT MODULE COLUMN: CHEMISTRY LOOP ANALYSIS
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 3, 
                                child: cockpitAeroGlassCard('SONAR_PULSE_ECHO_PING', const RadarMeshWidget()),
                              ),
                              Expanded(
                                flex: 2, 
                                child: cockpitAeroGlassCard(
                                  'CHEMICAL_DOSING_ANALYSIS', 
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('ENV_PH:', style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                                            Text('7.42 pH', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('TARGET_PH:', style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                                            Text('7.00 pH', style: GoogleFonts.shareTechMono(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('CORRECTIVE_FLUID_VOL:', style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                                            Text('250 mL', style: GoogleFonts.shareTechMono(color: Colors.orangeAccent, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CENTER MODULE COLUMN: CRITICAL CORE VECTORS & VEHICLE LIFETIME
                        Expanded(
                          flex: 3,
                          child: cockpitAeroGlassCard(
                            'AUTONOMOUS_VECTOR_STEER', 
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomPaint(
                                    size: const Size(110, 110),
                                    painter: SteeringWheelPainter(headingAngle: liveHeadingAngle),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('LIFETIME:', style: GoogleFonts.shareTechMono(color: Colors.white54, fontSize: 11)),
                                          Text('148.5 HRS', style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('BATTERY_LEVEL:', style: GoogleFonts.shareTechMono(color: Colors.white54, fontSize: 11)),
                                          Text('87%', style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: 0.87,
                                          backgroundColor: Colors.white10,
                                          color: Colors.greenAccent.withValues(alpha: 0.6),
                                          minHeight: 3,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // RIGHT MODULE COLUMN: ACTUATOR STATES & REMAINING RUNTIMES
                        Expanded(
                          flex: 3,
                          child: cockpitAeroGlassCard(
                            'ACTUATOR_SYSTEM_DIAGNOSTICS', 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('CURRENT_STATE:', style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.cyanAccent.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.25)),
                                        ),
                                        child: Text('BLENDING', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('FLUID_REMAIN_TIME:', style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                                      Text('00:04:18', style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Divider(color: Colors.white10, height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('HARDWARE_FLAGS:', style: GoogleFonts.shareTechMono(color: Colors.white54, fontSize: 11)),
                                      Text('0x00_NOMINAL', style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cockpitAeroGlassCard(String technicalTitle, Widget? customChild) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A2533).withValues(alpha: 0.12), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.15), 
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// $technicalTitle',
            style: GoogleFonts.shareTechMono(
              color: Colors.cyanAccent.withValues(alpha: 0.7), 
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1
            ),
          ),
          const Divider(color: Colors.white10, height: 12, thickness: 0.5),
          Expanded(
            child: customChild ?? Center(
              child: Text(
                '[ NO_ACTIVE_STREAM ]', 
                style: GoogleFonts.shareTechMono(color: Colors.white12, fontSize: 11)
              ),
            ),
          )
        ],
      ),
    );
  }
}