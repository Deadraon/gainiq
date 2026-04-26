import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/workout_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/gemini_progress_service.dart';
import '../../models/workout_log_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  BodyAnalysisResult? _analysisResult;
  String? _errorMessage;
  String _statusMessage = 'Analysing...';

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Please complete your profile first.');
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _isAnalyzing = true;
        _analysisResult = null;
        _errorMessage = null;
        _statusMessage = 'Connecting to Gemini AI...';
      });

      final result = await GeminiProgressService.analyzeProgress(
        imageFile: _selectedImage!,
        user: user,
        onProgress: (status) {
          if (mounted) {
            setState(() {
              _statusMessage = status;
            });
          }
        },
      );

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Analysis failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final logs = workoutProvider.logs;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AI Body Analysis Section ──────────────────────────────
            _buildAIAnalysisSection(),

            const SizedBox(height: 32),

            // ── Workout Volume Chart ──────────────────────────────────
            const Text('Workout Volume',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Total sets completed per workout',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            const SizedBox(height: 16),
            _buildChart(logs),

            const SizedBox(height: 32),

            // ── Recent Workouts ───────────────────────────────────────
            const Text('Recent Workouts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            const SizedBox(height: 16),

            if (logs.isEmpty)
              _buildEmptyState()
            else
              ...logs.map((log) => _buildLogCard(context, log)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFE5FF00), size: 20),
            const SizedBox(width: 8),
            const Text('AI Body Analysis',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 6),
        Text('Upload a photo — Gemini AI analyses your physique & progress',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
        const SizedBox(height: 16),

        // Photo area
        GestureDetector(
          onTap: () => _showPhotoOptions(),
          child: Container(
            width: double.infinity,
            height: _selectedImage != null ? 260 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedImage != null
                    ? const Color(0xFFE5FF00).withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        // Change photo overlay
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                  SizedBox(width: 5),
                                  Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5FF00).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFFE5FF00), size: 26),
                      ),
                      const SizedBox(height: 12),
                      const Text('Tap to upload your progress photo',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Camera or Gallery', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    ],
                  ),
          ),
        ),

        // Analyze button
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : () => _pickAndAnalyze(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5FF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isAnalyzing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 18),
                        SizedBox(width: 8),
                        Text('Analyse with Gemini AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
            ),
          ),
        ],

        // Error
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
            ),
          ),
        ],

        // Analysis result
        if (_analysisResult != null) ...[
          const SizedBox(height: 20),
          _buildAnalysisResult(_analysisResult!),
        ],
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Upload Progress Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _photoOption(Icons.camera_alt_outlined, 'Take Photo', () {
              Navigator.pop(context);
              _pickAndAnalyze(ImageSource.camera);
            }),
            const SizedBox(height: 12),
            _photoOption(Icons.photo_library_outlined, 'Choose from Gallery', () {
              Navigator.pop(context);
              _pickAndAnalyze(ImageSource.gallery);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE5FF00), size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult(BodyAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI badge
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFE5FF00), size: 16),
            const SizedBox(width: 6),
            const Text('Gemini AI Analysis', style: TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5FF00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(result.progressRating, style: const TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Overall feedback
        _infoCard(
          icon: Icons.chat_bubble_outline,
          title: 'Overall Feedback',
          content: result.overallFeedback,
          color: const Color(0xFFE5FF00),
        ),
        const SizedBox(height: 10),

        // Stats row
        Row(
          children: [
            Expanded(child: _statCard('Body Fat', result.estimatedBodyFat, Icons.monitor_weight_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('Muscle Def.', result.muscleDefinition.split(' - ').first, Icons.fitness_center)),
          ],
        ),
        const SizedBox(height: 10),
        _infoCard(
          icon: Icons.accessibility_new,
          title: 'Posture',
          content: result.posture,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 10),

        // Strengths
        if (result.strengths.isNotEmpty)
          _listCard('💪 Strengths', result.strengths, Colors.greenAccent),
        const SizedBox(height: 10),

        // Improvements
        if (result.improvements.isNotEmpty)
          _listCard('🎯 Areas to Improve', result.improvements, Colors.orangeAccent),
        const SizedBox(height: 10),

        // Next tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFE5FF00).withOpacity(0.12), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5FF00).withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Tip', style: TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(result.nextStepTip, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Text(
          'Note: This is an AI estimate for fitness guidance only, not a medical assessment.',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
        ),
      ],
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String content, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _listCard(String title, List<String> items, Color bulletColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChart(List<WorkoutLogModel> logs) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: logs.isEmpty
          ? Center(
              child: Text(
                'Complete a workout to see your progress chart.',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          : BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, _) => Text(value.toInt().toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        final recentLogs = logs.take(7).toList().reversed.toList();
                        if (index >= 0 && index < recentLogs.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(DateFormat('MMM d').format(recentLogs[index].date),
                                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(logs),
              ),
            ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<WorkoutLogModel> logs) {
    final recentLogs = logs.take(7).toList().reversed.toList();
    return List.generate(recentLogs.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: recentLogs[index].totalVolume.toDouble(),
            color: const Color(0xFFE5FF00),
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 50,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, size: 40, color: Colors.white24),
          const SizedBox(height: 12),
          Text('No workouts logged yet.', style: TextStyle(color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, WorkoutLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE5FF00).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFFE5FF00)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, MMM d • h:mm a').format(log.date),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${log.totalVolume} sets', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              const SizedBox(height: 2),
              Text('${(log.durationSeconds / 60).floor()} min',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
