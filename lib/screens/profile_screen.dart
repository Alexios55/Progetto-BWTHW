import 'package:flutter/material.dart';
import 'package:bwthw_project/models/user.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/widgets/bmi_bar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final loadedUser = await PreferenceService.getUserData(); // ✔ FIX

    if (!mounted) return;

    setState(() {
      user = loadedUser;
      isLoading = false;
    });
  }

  double get bmi {
    if (user == null) return 0;
    double h = user!.height / 100;
    return user!.weight / (h * h);
  }

  void _logout() async {
    await PreferenceService.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    await PreferenceService.saveLogin(false);
  }

  void _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: user!),
      ),
    );

    if (result == true) {
      _loadUser();
    }
  }

  Widget statBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 👤 AVATAR
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue,
                child: Text(
                  user!.name[0],
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 👤 NAME
              Text(
                '${user!.name} ${user!.surname}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 📊 STATS
              Row(
                children: [
                  statBox('Weight', '${user!.weight} kg', Icons.monitor_weight),
                  const SizedBox(width: 10),
                  statBox('Height', '${user!.height} cm', Icons.height),
                  const SizedBox(width: 10),
                  statBox('BMI', bmi.toStringAsFixed(1), Icons.favorite),
                ],
              ),

              const SizedBox(height: 25),

              // 📈 BMI BAR
              BmiBar(
                bmi: bmi,
                statusColor: Colors.green,
              ),

              const SizedBox(height: 25),

              // ✏️ EDIT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _editProfile,
                  child: const Text('Edit Profile'),
                ),
              ),

              const Spacer(),

              // 🚪 LOGOUT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _logout,
                  child: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}