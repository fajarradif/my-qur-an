import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../theme/colors.dart';

class KiblatScreen extends StatefulWidget {
  const KiblatScreen({super.key});

  @override
  State<KiblatScreen> createState() => _KiblatScreenState();
}

class _KiblatScreenState extends State<KiblatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arah Kiblat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.primaryGreen),
      ),
      body: FutureBuilder(
        future: FlutterQiblah.androidDeviceSensorSupport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.data == false) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "Device tidak mendukung sensor kompas/magnetometer. Silakan gunakan device lain.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _buildCompass();
        },
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error sensor: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Menunggu data sensor..."));
        }

        final qiblahDirection = snapshot.data!;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${qiblahDirection.offset.toStringAsFixed(0)}°",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Text(
                "Derajat dari Utara",
                style: TextStyle(color: AppColors.mutedGreen, fontSize: 14),
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
                    angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                    child: _buildQiblaNeedle(),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Arahkan HP sejajar dengan lantai",
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
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
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2), width: 8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 10, child: Text('N', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
          const Positioned(bottom: 10, child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen))),
          const Positioned(left: 10, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen))),
          const Positioned(right: 10, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen))),
          
          for (int i = 0; i < 72; i++)
            Transform.rotate(
              angle: (i * 5) * (pi / 180),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: i % 2 == 0 ? 2 : 1,
                  height: i % 18 == 0 ? 15 : 8,
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
                      colors: [AppColors.primaryYellow, AppColors.primaryYellow.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.mosque, color: AppColors.primaryGreen, size: 30),
        ],
      ),
    );
  }
}
