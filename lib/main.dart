import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

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

  final themeProvider = ThemeProvider();
  runApp(MyQuranApp(themeProvider: themeProvider));
}

class MyQuranApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const MyQuranApp({super.key, required this.themeProvider});

  /// Akses ThemeProvider dari mana saja di widget tree
  static ThemeProvider of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<ThemeInherited>();
    return inherited!.themeProvider;
  }

  @override
  State<MyQuranApp> createState() => _MyQuranAppState();
}

class _MyQuranAppState extends State<MyQuranApp> {
  @override
  void initState() {
    super.initState();
    widget.themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ThemeInherited(
      themeProvider: widget.themeProvider,
      child: MaterialApp(
        title: 'MyQuran',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        home: const HomeScreen(),
      ),
    );
  }
}

/// InheritedWidget untuk menyebarkan ThemeProvider ke seluruh widget tree
class ThemeInherited extends InheritedWidget {
  final ThemeProvider themeProvider;

  const ThemeInherited({
    super.key,
    required this.themeProvider,
    required super.child,
  });

  @override
  bool updateShouldNotify(ThemeInherited oldWidget) {
    // Selalu rebuild kalau ada pemberitahuan dari provider
    return true;
  }
}
