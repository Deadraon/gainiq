import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AdminUserEditScreen extends StatefulWidget {
  final String uid;
  final UserModel user;

  const AdminUserEditScreen({super.key, required this.uid, required this.user});

  @override
  State<AdminUserEditScreen> createState() => _AdminUserEditScreenState();
}

class _AdminUserEditScreenState extends State<AdminUserEditScreen> {
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
  late String _gender;
  late String _bodyType;
  late String _primaryGoal;
  late String _experienceLevel;
  late String _workoutLocation;
  late String _workoutTiming;
  late String _dietPreference;

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    _nameController = TextEditingController(text: user.name);
    _ageController = TextEditingController(text: user.age > 0 ? '${user.age}' : '');
    _heightController = TextEditingController(text: user.height > 0 ? '${user.height.toInt()}' : '');
    _weightController = TextEditingController(text: user.weight > 0 ? '${user.weight.toInt()}' : '');
    _budgetController = TextEditingController(text: user.monthlyBudget > 0 ? '${user.monthlyBudget.toInt()}' : '');
    _allergiesController = TextEditingController(text: user.allergies);

    _gender = user.gender.isNotEmpty ? user.gender : 'Male';
    _bodyType = user.bodyType.isNotEmpty ? user.bodyType : 'Average';
    _primaryGoal = user.primaryGoal.isNotEmpty ? user.primaryGoal : 'Bulking';
    _experienceLevel = user.experienceLevel.isNotEmpty ? user.experienceLevel : 'Beginner';
    _workoutLocation = user.workoutLocation.isNotEmpty ? user.workoutLocation : 'Gym';
    _workoutTiming = user.workoutTiming.isNotEmpty ? user.workoutTiming : 'Morning';
    _dietPreference = user.dietPreference.isNotEmpty ? user.dietPreference : 'Non-vegetarian';
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
      final updated = UserModel(
        id: widget.uid,
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
        streak: widget.user.streak,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set(updated.toJson(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User profile updated successfully!'),
            backgroundColor: Colors.green,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit User Data', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
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
              _textField(_allergiesController, 'Allergies / Restrictions', Icons.warning_amber_outlined),
              const SizedBox(height: 32),
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
    return Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13));
  }

  Widget _textField(TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator, String? prefix}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 14),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
        prefixIcon: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _dropdown({required String label, required String value, required List<String> options, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
          onChanged: onChanged,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        ),
      ),
    );
  }

  Widget _chipGroup(List<String> options, String selected, void Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE5FF00) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFFE5FF00) : Theme.of(context).dividerColor.withOpacity(0.08)),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.black : Theme.of(context).textTheme.bodyLarge?.color,
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
