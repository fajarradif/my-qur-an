import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.myQuran.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  runApp(const MyQuranApp());
}

class MyQuranApp extends StatelessWidget {
  const MyQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyQuran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Desain baru ini dikhususkan untuk tampilan terang/bersih (Light Mode) 
      // yang memadukan Hijau Tua dan Emas
      themeMode: ThemeMode.light, 
      home: const HomeScreen(),
    );
  }
}
