// lib/profile2.dart
import 'package:flutter/material.dart';
import 'profile.dart'; // import the profile page to return to

class Profile2Screen extends StatelessWidget {
  const Profile2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Replace this screen with the profile page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: coins and section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                      SizedBox(width: 5),
                      Text(
                        '200',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Text(
                    "ACHIEVEMENTS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Optional: Profile picture and greeting
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange[200],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hello, Sam!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Medal list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  buildMedalCard("MEDAL 1", "Description"),
                  buildMedalCard("MEDAL 2", "Description"),
                  buildMedalCard("MEDAL 3", "Description"),
                ],
              ),
            ),
          ],
        ),
      ),
      // No bottom navigation bar here
    );
  }

  Widget buildMedalCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.pink, size: 40),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(description),
            ],
          ),
        ],
      ),
    );
  }
}
