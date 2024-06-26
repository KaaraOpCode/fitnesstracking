// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitnessGoalsScreen extends StatefulWidget {
  @override
  _FitnessGoalsScreenState createState() => _FitnessGoalsScreenState();
}

class Goal {
  final String id;
  final String description;
  final String category;
  final String userId;

  Goal({required this.id, required this.description, this.category = '', required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'category': category,
      'userId': userId,
    };
  }

  factory Goal.fromMap(String id, Map<String, dynamic> data) {
    return Goal(
      id: id,
      description: data['description'],
      category: data['category'] ?? '', 
      userId: data['userId'] ?? '',
    );
  }
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  final _goalController = TextEditingController();
  List<Goal> goals = [];
  final List<String> categories = ['Strength', 'Cardio', 'Flexibility'];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _fetchGoals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final goalsCollection = FirebaseFirestore.instance.collection('goals');
      final snapshot = await goalsCollection.where('userId', isEqualTo: user.uid).get();
      setState(() {
        goals = snapshot.docs.map((doc) => Goal.fromMap(doc.id, doc.data())).toList();
      });
    }
  }

  Future<void> _saveGoal() async {
    final description = _goalController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (description.isEmpty || user == null) {
      return; // Handle empty goal description or null user
    }
    final newGoal = Goal(id: '', description: description, category: selectedCategory ?? '', userId: user.uid);
    final goalsCollection = FirebaseFirestore.instance.collection('goals');
    final docRef = await goalsCollection.add(newGoal.toMap());

    setState(() {
      goals.add(Goal(id: docRef.id, description: description, category: selectedCategory ?? '', userId: user.uid));
      _goalController.text = '';
      selectedCategory = null;
    });
    Navigator.of(context).pop(); // Close the bottom sheet after saving goal
  }

  Future<void> _editGoal(int index) async {
    final goal = goals[index];
    _goalController.text = goal.description;
    selectedCategory = goal.category;
    await showModalBottomSheet(
      context: context,
      builder: (context) => _buildBottomSheet(context, () async {
        final updatedDescription = _goalController.text.trim();
        if (updatedDescription.isEmpty) {
          return; // Handle empty goal description
        }
        final updatedGoal = Goal(id: goal.id, description: updatedDescription, category: selectedCategory ?? '', userId: goal.userId);
        final goalsCollection = FirebaseFirestore.instance.collection('goals');
        await goalsCollection.doc(goal.id).update(updatedGoal.toMap());

        setState(() {
          goals[index] = updatedGoal;
          _goalController.text = '';
          selectedCategory = null;
        });
        Navigator.of(context).pop(); // Close the bottom sheet after saving goal
      }),
      isScrollControlled: true,
    );
  }

  Future<void> _deleteGoal(int index) async {
    final goal = goals[index];
    final goalsCollection = FirebaseFirestore.instance.collection('goals');
    await goalsCollection.doc(goal.id).delete();

    setState(() {
      goals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 60.0),
            Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  'Your fitness goals!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.description,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      if (goal.category.isNotEmpty)
                        Text(
                          goal.category,
                          style: TextStyle(color: Colors.white),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editGoal(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteGoal(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show text editing form in a modal bottom sheet
          showModalBottomSheet(
            context: context,
            builder: (context) => _buildBottomSheet(context, _saveGoal),
            isScrollControlled: true,
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, Function() onSave) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Apply padding to handle keyboard
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: _goalController,
              decoration: InputDecoration(
                hintText: 'Enter your fitness goal...',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: Text('Select Category (optional)'),
              items: categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onSave,
              child: Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
