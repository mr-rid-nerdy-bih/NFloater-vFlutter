import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/menuDeco.dart';
import '../pages/robotControlPanel.dart';
import '../../videoplayers.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? activePanel; 
  List<String> logFeed = [
    '[ OK ] CORING PROTOCOLS LOADED',
    '[ OK ] HC-05 SERIAL RX LINK ACTIVE',
    '[ SYS ] VOLTAGE STABLE: 12.4V',
  ];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return false;
      
      final sensors = ['SYS', 'GYRO', 'BARO', 'pH_MATX', 'PROP'];
      final tags = ['STABLE', 'POLLING', 'PING_OK', 'SYNCED'];
      
      setState(() {
        logFeed.add(
          '[ ${sensors[_random.nextInt(sensors.length)]} ] ${tags[_random.nextInt(tags.length)]}: 0x${_random.nextInt(256).toRadixString(16).toUpperCase()}'
        );
        if (logFeed.length > 8) logFeed.removeAt(0); 
      });
      return true;
    });
  }

  void _showPanel(String panelName) {
    setState(() {
      activePanel = (activePanel == panelName) ? null : panelName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF011627)),

          // BACKGROUND MENU AMBIENT VIDEO LAYER
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.30, 
                child: globalMenuVideoController != null
                    ? SizedBox.expand(
                        child: Video(
                          controller: globalMenuVideoController!,
                          fit: BoxFit.cover, // FIXED: native hardware scale fitting
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.03, 
              child: const GridPaper(divisions: 2, interval: 80, subdivisions: 1),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 42,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'NEUTRAFloater',
                            style: GoogleFonts.aldrich(
                              color: const Color(0xFFE0F7FA),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          );
                        },
                      ),
                      Text(
                        'SYS_BOOT_VER // 2026.1.9',
                        style: GoogleFonts.shareTechMono(
                          color: Colors.cyanAccent.withValues(alpha: 0.4),
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      )
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24, thickness: 1),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2533).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '// HARDWARE_SELF_TEST',
                                  style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const Divider(color: Colors.white10, height: 12),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: logFeed.length,
                                    itemBuilder: (context, idx) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          logFeed[idx],
                                          style: GoogleFonts.shareTechMono(color: Colors.white60, fontSize: 11),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MenuButton(
                                text: 'Connect', 
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RobotPage()),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              MenuButton(text: 'Info', onTap: () => _showPanel('Info')),
                              const SizedBox(height: 12),
                              MenuButton(text: 'Settings', onTap: () => _showPanel('Settings')),
                              
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutQuad, 
                                margin: const EdgeInsets.only(top: 16),
                                width: 280, 
                                height: activePanel != null ? 110 : 0, 
                                child: SingleChildScrollView( 
                                  physics: const NeverScrollableScrollPhysics(), 
                                  child: Container(
                                    height: 110,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A2533).withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '// ${activePanel?.toUpperCase()} CONSOLE',
                                          style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const Divider(color: Colors.white10, height: 10),
                                        Text(
                                          'Telemetry readouts for the $activePanel parameters will populate here live during active deployment configurations.',
                                          style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 11, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2533).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('// MATX_MODEL_PREVIEW', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.white10, height: 12),
                                Expanded(
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: 0.15,
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: BlueprintCrosshairPainter(),
                                          ),
                                        ),
                                        Center(
                                          child: Image.asset(
                                            'assets/product_3d.png',
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text('[ MODEL asset pending ]', style: GoogleFonts.shareTechMono(color: Colors.white12, fontSize: 11));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: 0.74,
                                  backgroundColor: Colors.white10,
                                  color: Colors.cyanAccent.withValues(alpha: 0.6),
                                  minHeight: 2,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('REF_ROTATION: 114°', style: GoogleFonts.shareTechMono(color: Colors.white38, fontSize: 9)),
                                    Text('SCALE: 1.000', style: GoogleFonts.shareTechMono(color: Colors.white38, fontSize: 9)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const MenuButton({required this.text, required this.onTap, super.key});

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isHovered = true),
        onTapUp: (_) => setState(() => isHovered = false),
        onTapCancel: () => setState(() => isHovered = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isHovered ? Colors.cyanAccent.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(30), 
            border: Border.all(
              color: isHovered ? Colors.cyanAccent : Colors.white12,
              width: isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.25),
                  blurRadius: 12,
                )
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: GoogleFonts.aldrich(
                color: isHovered ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.80),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}