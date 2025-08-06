import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _customOccupationController = TextEditingController();
  
  int _age = 25;
  String _education = '';
  String _occupation = '';
  List<String> _learningGoals = [];
  
  final List<String> _educationOptions = [
    'Not specified',
    'High School',
    'Undergraduate',
    'Graduate/Masters',
    'PhD/Research',
  ];

  final List<String> _occupationOptions = [
    'Not specified',
    'Student',
    'Software Engineer',
    'Product Manager',
    'Entrepreneur',
    'Consultant',
    'Other',
  ];

  final List<String> _goalOptions = [
    'Career advancement',
    'Interview preparation',
    'Personal knowledge',
    'Academic requirements',
    'Skill development',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
    final profileData = research.userProfileData;
    
    _firstNameController.text = profileData['firstName'] ?? '';
    _lastNameController.text = profileData['lastName'] ?? '';
    _age = profileData['age'] ?? 25;
    _education = profileData['education'] ?? 'Not specified';
    _occupation = profileData['occupation'] ?? 'Not specified';
    _learningGoals = List<String>.from(profileData['learningGoals'] ?? []);
    
    if (_occupation == 'Other' || (!_occupationOptions.contains(_occupation) && _occupation != 'Not specified')) {
      _customOccupationController.text = _occupation;
      _occupation = 'Other';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _customOccupationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      final finalOccupation = _occupation == 'Other' 
          ? _customOccupationController.text.trim()
          : _occupation;
      
      research.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: _age,
        education: _education,
        occupation: finalOccupation,
        learningGoals: _learningGoals,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Age Section
              const Text(
                'Age',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_age years old',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: _age.toDouble(),
                      min: 16,
                      max: 100,
                      divisions: 84,
                      onChanged: (value) => setState(() => _age = value.round()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('16', style: TextStyle(color: Colors.grey[600])),
                        Text('100', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Education Section
              const Text(
                'Education Level',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _education,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _educationOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _education = value!),
              ),
              const SizedBox(height: 24),
              
              // Occupation Section
              const Text(
                'Current Role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _occupation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _occupationOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _occupation = value!),
              ),
              
              if (_occupation == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customOccupationController,
                  decoration: const InputDecoration(
                    labelText: 'Please specify your role',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_occupation == 'Other' && (value == null || value.trim().isEmpty)) {
                      return 'Please specify your role';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              
              // Learning Goals Section
              const Text(
                'Learning Goals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select all that apply',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              ...(_goalOptions.map((goal) => 
                CheckboxListTile(
                  title: Text(goal),
                  value: _learningGoals.contains(goal),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _learningGoals.add(goal);
                      } else {
                        _learningGoals.remove(goal);
                      }
                    });
                  },
                ),
              )),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
