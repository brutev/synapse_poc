import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 20),
              Text('User Profile', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Email: user@example.com'),
              SizedBox(height: 10),
              Text('Phone: +1 234 567 8900'),
            ],
          ),
        ),
      ),
    );
  }
}
