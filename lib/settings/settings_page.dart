import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4A148C),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4A148C).withOpacity(0.1),
                    const Color(0xFF7B1FA2).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFBA68C8).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.settings, size: 80, color: Color(0xFF4A148C)),
                  SizedBox(height: 15),
                  Text(
                    'Settings & Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Configure your app preferences, notifications, privacy settings, and more.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Settings options list
            Expanded(
              child: ListView(
                children: [
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage app notifications',
                  ),
                  _buildSettingsItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    subtitle: 'Privacy and security settings',
                  ),
                  _buildSettingsItem(
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: 'Customize app appearance',
                  ),
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Change app language',
                  ),
                  _buildSettingsItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A148C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A148C).withOpacity(0.2),
                const Color(0xFF7B1FA2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4A148C), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontFamily: 'Poppins',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF757575),
          size: 16,
        ),
        onTap: () {
          // Handle settings item tap
        },
      ),
    );
  }
}
