import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/user_provider.dart';
import '../auth/auth_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final initials = (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?';

    if (userProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE5FF00))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Avatar + Name ──
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5FF00), Color(0xFF9EBD00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5FF00).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5FF00), width: 1.5),
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Color(0xFFE5FF00)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                user?.name.isNotEmpty == true ? user!.name : 'Set your name',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(email, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              const SizedBox(height: 6),

              // Profile incomplete warning
              if (user?.isProfileComplete != true)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Text('Profile incomplete — tap to complete', style: TextStyle(color: Colors.amber, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // ── Stats Row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBox(context, '${user?.streak ?? 0}', 'Streak 🔥', Colors.orange),
                  _statBox(context, user?.weight != null && user!.weight > 0 ? '${user.weight.toInt()}kg' : '–', 'Weight', Colors.blueAccent),
                  _statBox(context, user?.height != null && user!.height > 0 ? '${user.height.toInt()}cm' : '–', 'Height', Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 24),

              // ── Edit Profile Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5FF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile Details ──
              _infoCard(context, [
                _infoRow(context, Icons.flag_rounded, 'Goal', user?.primaryGoal.isNotEmpty == true ? user!.primaryGoal : '–', Colors.amber),
                _infoRow(context, Icons.trending_up_rounded, 'Experience', user?.experienceLevel.isNotEmpty == true ? user!.experienceLevel : '–', Colors.blueAccent),
                _infoRow(context, Icons.fitness_center_rounded, 'Trains At', user?.workoutLocation.isNotEmpty == true ? user!.workoutLocation : '–', Colors.greenAccent),
                _infoRow(context, Icons.schedule_rounded, 'Timing', user?.workoutTiming.isNotEmpty == true ? user!.workoutTiming : '–', Colors.purpleAccent),
                _infoRow(context, Icons.restaurant_rounded, 'Diet', user?.dietPreference.isNotEmpty == true ? user!.dietPreference : '–', Colors.green),
                _infoRow(context, Icons.currency_rupee_rounded, 'Budget',
                    user?.monthlyBudget != null && user!.monthlyBudget > 0 ? '₹${user.monthlyBudget.toInt()}/mo' : '–',
                    const Color(0xFFE5FF00)),
                _infoRow(context, Icons.cake_rounded, 'Age', user?.age != null && user!.age > 0 ? '${user.age} yrs' : '–', Colors.orange),
                _infoRow(context, Icons.person_rounded, 'Gender', user?.gender.isNotEmpty == true ? user!.gender : '–', Colors.pinkAccent),
              ]),
              const SizedBox(height: 24),

              // ── Logout ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  label: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast) const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
