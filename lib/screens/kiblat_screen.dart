import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/colors.dart';
import '../main.dart';

class KiblatScreen extends StatefulWidget {
  const KiblatScreen({super.key});

  @override
  State<KiblatScreen> createState() => _KiblatScreenState();
}

class _KiblatScreenState extends State<KiblatScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasPermission = false;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasPermission = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasPermission = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: Text('Arah Kiblat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text1(context))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.bg(context),
        iconTheme: IconThemeData(color: AppColors.green(context)),
        actions: [
          IconButton(
            icon: Icon(
              AppColors.isDark(context) ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
              color: AppColors.green(context),
            ),
            onPressed: () {
              MyQuranApp.of(context).toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.green(context)))
          : !_hasPermission
              ? _buildPermissionDenied()
              : FutureBuilder(
                  future: FlutterQiblah.androidDeviceSensorSupport(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: AppColors.green(context)));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (snapshot.data == false) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            "Device tidak mendukung sensor kompas/magnetometer. Silakan gunakan device lain.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.text1(context)),
                          ),
                        ),
                      );
                    }
                    return _buildCompass();
                  },
                ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Izin lokasi diperlukan untuk menentukan arah kiblat.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.text1(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Berikan Izin"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.green(context)));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error sensor: ${snapshot.error}", style: TextStyle(color: AppColors.text1(context))));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text("Menunggu data sensor...", style: TextStyle(color: AppColors.text1(context))));
        }

        final qiblahDirection = snapshot.data!;
        
        // Menghitung selisih derajat (Sisa Derajat ke Kiblat)
        double relativeOffset = qiblahDirection.offset - qiblahDirection.direction;
        
        relativeOffset = relativeOffset % 360;
        if (relativeOffset > 180) relativeOffset -= 360;
        if (relativeOffset < -180) relativeOffset += 360;

        bool isAligned = relativeOffset.abs() < 3;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${relativeOffset.toStringAsFixed(0)}°",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: isAligned ? Colors.orangeAccent : AppColors.green(context),
                ),
              ),
              Text(
                isAligned ? "Sudah Pas Hadap Kiblat!" : "Putar HP kamu",
                style: TextStyle(
                  color: isAligned ? Colors.orangeAccent : AppColors.text2(context).withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: isAligned ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Compass Dial
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1),
                    child: _buildCompassDial(),
                  ),
                  // Qibla Needle
                  Transform.rotate(
                    angle: (relativeOffset * (pi / 180)),
                    child: _buildQiblaNeedle(),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.green(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Arahkan HP sejajar dengan lantai",
                  style: TextStyle(color: AppColors.green(context), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompassDial() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.green(context).withValues(alpha: 0.2), width: 8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 10, child: Text('N', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
          Positioned(bottom: 10, child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context)))),
          Positioned(left: 10, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context)))),
          Positioned(right: 10, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.green(context)))),
          
          for (int i = 0; i < 72; i++)
            Transform.rotate(
              angle: (i * 5) * (pi / 180),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: i % 2 == 0 ? 2 : 1,
                  height: i % 18 == 0 ? 15 : 8,
                  color: AppColors.green(context).withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.location_on, color: AppColors.primaryYellow, size: 40),
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.gold(context), AppColors.gold(context).withValues(alpha: 0)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.mosque, color: AppColors.green(context), size: 30),
        ],
      ),
    );
  }
}
