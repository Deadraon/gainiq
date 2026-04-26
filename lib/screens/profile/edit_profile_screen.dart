import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _budgetController;
  late TextEditingController _allergiesController;

  // Selections
  String _gender = 'Male';
  String _bodyType = 'Average';
  String _primaryGoal = 'Bulking';
  String _experienceLevel = 'Beginner';
  String _workoutLocation = 'Gym';
  String _workoutTiming = 'Morning';
  String _dietPreference = 'Non-vegetarian';

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age != null && user!.age > 0 ? '${user.age}' : '');
    _heightController = TextEditingController(text: user?.height != null && user!.height > 0 ? '${user.height.toInt()}' : '');
    _weightController = TextEditingController(text: user?.weight != null && user!.weight > 0 ? '${user.weight.toInt()}' : '');
    _budgetController = TextEditingController(text: user?.monthlyBudget != null && user!.monthlyBudget > 0 ? '${user.monthlyBudget.toInt()}' : '');
    _allergiesController = TextEditingController(text: user?.allergies ?? '');

    if (user != null) {
      if (user.gender.isNotEmpty) _gender = user.gender;
      if (user.bodyType.isNotEmpty) _bodyType = user.bodyType;
      if (user.primaryGoal.isNotEmpty) _primaryGoal = user.primaryGoal;
      if (user.experienceLevel.isNotEmpty) _experienceLevel = user.experienceLevel;
      if (user.workoutLocation.isNotEmpty) _workoutLocation = user.workoutLocation;
      if (user.workoutTiming.isNotEmpty) _workoutTiming = user.workoutTiming;
      if (user.dietPreference.isNotEmpty) _dietPreference = user.dietPreference;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _budgetController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final current = context.read<UserProvider>().currentUser;
      final updated = UserModel(
        id: current?.id ?? '',
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _gender,
        height: double.tryParse(_heightController.text.trim()) ?? 0,
        weight: double.tryParse(_weightController.text.trim()) ?? 0,
        bodyType: _bodyType,
        primaryGoal: _primaryGoal,
        experienceLevel: _experienceLevel,
        workoutLocation: _workoutLocation,
        workoutTiming: _workoutTiming,
        dietPreference: _dietPreference,
        monthlyBudget: double.tryParse(_budgetController.text.trim()) ?? 0,
        allergies: _allergiesController.text.trim(),
        streak: current?.streak ?? 0,
      );

      await context.read<UserProvider>().updateProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Color(0xFF2E3800),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[900]),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE5FF00)),
                  )
                : const Text('SAVE', style: TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Info
              _sectionTitle('Personal Info'),
              const SizedBox(height: 12),
              _textField(_nameController, 'Full Name', Icons.person_outline, validator: (v) => v!.isEmpty ? 'Name is required' : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _textField(_ageController, 'Age', Icons.cake_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(
                      label: 'Gender',
                      value: _gender,
                      options: ['Male', 'Female', 'Other'],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Physical Stats
              _sectionTitle('Physical Stats'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _textField(_heightController, 'Height (cm)', Icons.height, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _textField(_weightController, 'Weight (kg)', Icons.monitor_weight_outlined, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              _label('Body Type'),
              const SizedBox(height: 8),
              _chipGroup(['Skinny', 'Average', 'Muscular', 'Overweight'], _bodyType, (v) => setState(() => _bodyType = v)),
              const SizedBox(height: 24),

              // Fitness Goals
              _sectionTitle('Fitness Goals'),
              const SizedBox(height: 12),
              _label('Primary Goal'),
              const SizedBox(height: 8),
              _chipGroup(['Bulking', 'Cutting', 'Weight loss', 'Maintenance'], _primaryGoal, (v) => setState(() => _primaryGoal = v)),
              const SizedBox(height: 12),
              _label('Experience Level'),
              const SizedBox(height: 8),
              _chipGroup(['Beginner', 'Intermediate', 'Advanced'], _experienceLevel, (v) => setState(() => _experienceLevel = v)),
              const SizedBox(height: 24),

              // Workout Preferences
              _sectionTitle('Workout Preferences'),
              const SizedBox(height: 12),
              _label('Location'),
              const SizedBox(height: 8),
              _chipGroup(['Gym', 'Home'], _workoutLocation, (v) => setState(() => _workoutLocation = v)),
              const SizedBox(height: 12),
              _label('Preferred Timing'),
              const SizedBox(height: 8),
              _chipGroup(['Morning', 'Afternoon', 'Evening', 'Night'], _workoutTiming, (v) => setState(() => _workoutTiming = v)),
              const SizedBox(height: 24),

              // Diet
              _sectionTitle('Diet & Nutrition'),
              const SizedBox(height: 12),
              _label('Diet Preference'),
              const SizedBox(height: 8),
              _chipGroup(['Vegetarian', 'Eggetarian', 'Non-vegetarian'], _dietPreference, (v) => setState(() => _dietPreference = v)),
              const SizedBox(height: 12),
              _textField(_budgetController, 'Monthly Food Budget (₹)', Icons.currency_rupee, keyboardType: TextInputType.number, prefix: '₹ '),
              const SizedBox(height: 12),
              _textField(_allergiesController, 'Allergies / Restrictions (Optional)', Icons.warning_amber_outlined),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5FF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Color(0xFFE5FF00), fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _label(String text) {
    return Text(text, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13));
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5FF00), width: 1),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5FF00), width: 1),
        ),
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _chipGroup(List<String> options, String selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE5FF00).withOpacity(0.15) : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFFE5FF00) : Colors.white12,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE5FF00) : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
