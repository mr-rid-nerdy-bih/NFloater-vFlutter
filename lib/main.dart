import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/menu.dart';
import '../videoplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const NeutraFloaterApp());
}

class NeutraFloaterApp extends StatelessWidget {
  const NeutraFloaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEUTRAFloater',
      debugShowCheckedModeBanner: false,
      home: const EnginePreloadSplash(),
    );
  }
}

// =========================================================================
// O. ENGINE PRELOADER SPLASH
// =========================================================================
class EnginePreloadSplash extends StatefulWidget {
  const EnginePreloadSplash({super.key});

  @override
  State<EnginePreloadSplash> createState() => _EnginePreloadSplashState();
}

class _EnginePreloadSplashState extends State<EnginePreloadSplash> {
  String bootLog = 'ALLOCATING COCKPIT RESOURCE MANIFEST...';

  @override
  void initState() {
    super.initState();
    _executeAssetWarmup();
  }

  Future<void> _executeAssetWarmup() async {
    try {
      // 1. Setup the Menu Player backend
      final menuPlayer = Player();
      final menuController = VideoController(menuPlayer);
      
      // Open the asset and set up parameters
      await menuPlayer.open(Media('asset:///assets/ocean.mp4'), play: true);
      await menuPlayer.setPlaylistMode(PlaylistMode.loop);
      await menuPlayer.setVolume(0.0);

      // Assign your global variables safely
      globalMenuVideoPlayer = menuPlayer;
      globalMenuVideoController = menuController;

      if (mounted) {
        setState(() => bootLog = 'MENU AMBIENT INITIALIZED. ALLOCATING HUD METRICS...');
      }

      // 2. Setup the HUD Player backend simultaneously 
      final hudPlayer = Player();
      final hudController = VideoController(hudPlayer);

      await hudPlayer.open(Media('asset:///assets/kelp_forest.mp4'), play: true);
      await hudPlayer.setPlaylistMode(PlaylistMode.loop);
      await hudPlayer.setVolume(0.0);

      globalHUDVideoPlayer = hudPlayer;
      globalHUDVideoController = hudController;

      if (mounted) {
        setState(() => bootLog = 'SYSTEM READY. ROUTING TO INTERFACE MODULE...');
      }
      
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => bootLog = 'CRITICAL ASSET RUNTIME UNCAUGHT ERROR: \n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011627),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
            const SizedBox(height: 24),
            Text(
              bootLog,
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: Colors.cyanAccent.withValues(alpha: 0.7),
                fontSize: 12,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}