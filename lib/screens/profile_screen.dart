import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'my_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final FavoritesService favoritesService;

  const ProfileScreen({super.key, required this.favoritesService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedQuality = 'High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // Profile Picture
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Settings Sections
          _buildSection('Preferences', [
            _buildSwitchTile(
              'Notifications',
              'Get notified about new releases',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Auto-play',
              'Play next episode automatically',
              _autoPlayEnabled,
              (value) => setState(() => _autoPlayEnabled = value),
            ),
          ]),
          _buildSection('Playback', [
            _buildDropdownTile(
              'Language',
              _selectedLanguage,
              ['English', 'Spanish', 'French', 'German'],
              (value) => setState(() => _selectedLanguage = value!),
            ),
            _buildDropdownTile(
              'Video Quality',
              _selectedQuality,
              ['Low', 'Medium', 'High', 'Auto'],
              (value) => setState(() => _selectedQuality = value!),
            ),
          ]),
          _buildSection('Account', [
            _buildListTile('My List', Icons.favorite, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MyListScreen(
                        favoritesService: widget.favoritesService,
                      ),
                ),
              );
            }),
            _buildListTile('Watch History', Icons.history, () {
              // TODO: Navigate to Watch History
            }),
            _buildListTile('Help & Support', Icons.help_outline, () {
              // TODO: Navigate to Help & Support
            }),
            _buildListTile('Sign Out', Icons.logout, () {
              // TODO: Implement sign out
            }, isDestructive: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(color: Colors.grey),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.grey[900],
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.white),
      ),
      onTap: onTap,
    );
  }
}
