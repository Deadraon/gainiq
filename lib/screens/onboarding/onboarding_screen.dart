import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;
  bool _isLoading = false;

  // --- STATE VARIABLES ---
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _bodyType = 'Average';

  String _primaryGoal = 'Bulking';
  String _experienceLevel = 'Beginner';

  String _workoutLocation = 'Gym';
  String _workoutTiming = 'Morning';

  String _dietPreference = 'Vegetarian';
  final _budgetController = TextEditingController();
  final _allergiesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _budgetController.dispose();
    _allergiesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Save all the data to Firestore with a timeout to prevent hanging
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'onboardingCompleted': true,
            'createdAt': FieldValue.serverTimestamp(),
            'name': _nameController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()) ?? 0,
            'gender': _gender,
            'height': double.tryParse(_heightController.text.trim()) ?? 0.0,
            'weight': double.tryParse(_weightController.text.trim()) ?? 0.0,
            'bodyType': _bodyType,
            'primaryGoal': _primaryGoal,
            'experienceLevel': _experienceLevel,
            'workoutLocation': _workoutLocation,
            'workoutTiming': _workoutTiming,
            'dietPreference': _dietPreference,
            'monthlyBudget': double.tryParse(_budgetController.text.trim()) ?? 0.0,
            'allergies': _allergiesController.text.trim(),
          }, SetOptions(merge: true)).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection to Firestore timed out. Is the database created in the console?'),
          );
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving data: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(
                  _totalPages,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextPage,
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                        )
                      : Text(_currentPage == _totalPages - 1 ? 'FINISH' : 'NEXT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Let\'s get to know you', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your physical stats', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Current Body Type', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Skinny', 'Average', 'Muscular', 'Overweight'].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _bodyType == type,
                onSelected: (bool selected) {
                  setState(() => _bodyType = type);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your fitness goals', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Text('Primary Goal', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Bulking', 'Cutting', 'Weight loss', 'Maintenance'].map((goal) {
              return ChoiceChip(
                label: Text(goal),
                selected: _primaryGoal == goal,
                onSelected: (bool selected) {
                  setState(() => _primaryGoal = goal);
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text('Experience Level', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              return ChoiceChip(
                label: Text(level),
                selected: _experienceLevel == level,
                onSelected: (bool selected) {
                  setState(() => _experienceLevel = level);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workout Preferences', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Text('Location', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['Gym', 'Home'].map((loc) {
              return ChoiceChip(
                label: Text(loc),
                selected: _workoutLocation == loc,
                onSelected: (bool selected) {
                  setState(() => _workoutLocation = loc);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Preferred Timing', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
              return ChoiceChip(
                label: Text(time),
                selected: _workoutTiming == time,
                onSelected: (bool selected) {
                  setState(() => _workoutTiming = time);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diet & Nutrition', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Text('Diet Preference', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['Vegetarian', 'Eggetarian', 'Non-vegetarian'].map((diet) {
              return ChoiceChip(
                label: Text(diet),
                selected: _dietPreference == diet,
                onSelected: (bool selected) {
                  setState(() => _dietPreference = diet);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Food Budget (₹)',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _allergiesController,
            decoration: InputDecoration(
              labelText: 'Allergies / Restrictions (Optional)',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
