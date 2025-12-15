import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_screen.dart'; 
import 'about_screen.dart'; 
import 'app_strings.dart';
import 'login_screen.dart';
import 'services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  bool _isLoading = true; 

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _getProfile(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _name = data['full_name'] ?? 'No Name';
        _email = data['email'] ?? Supabase.instance.client.auth.currentUser?.email ?? '';
        _phone = data['phone_number'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      }).eq('id', userId);

      setState(() {
        _name = _nameController.text.trim();
        _phone = _phoneController.text.trim();
        _email = _emailController.text.trim();
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('profileUpdated')), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('errorUpdatingProfile')), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    _nameController.text = _name;
    _emailController.text = _email;
    _phoneController.text = _phone;

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStrings.languageNotifier,
          builder: (context, value, child) {
            return AlertDialog(
              title: Text(AppStrings.get('editProfile')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: AppStrings.get('nameLabel'), prefixIcon: const Icon(Icons.person)),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      readOnly: true, 
                      decoration: InputDecoration(
                        labelText: AppStrings.get('emailLabel'), 
                        prefixIcon: const Icon(Icons.email),
                        helperText: AppStrings.get('contactSupport')
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: AppStrings.get('phoneLabel'), prefixIcon: const Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                  child: Text(AppStrings.get('save'), style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: AppStrings.languageNotifier,
        builder: (context, value, child) {
          return AlertDialog(
            title: Text(AppStrings.get('deleteAccount'), style: const TextStyle(color: Colors.red)),
            content: Text(AppStrings.get('deleteAccountConfirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await SupabaseService.deleteUserAccount();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('accountDeleted')), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('unexpectedError')), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: Text(AppStrings.get('delete'), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppStrings.get('welcome'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppStrings.get('myProfileTitle'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
                              ]
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: const Color(0xFF1A237E),
                                  child: Text(
                                    _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(_email,
                                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      if (_phone.isNotEmpty)
                                        Text(_phone,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A237E)),
                                  onPressed: _showEditProfileDialog,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          GestureDetector(
                            onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                            },
                            child: ProfileMenuItem(icon: Icons.settings, title: AppStrings.get('settings')),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                            },
                            child: ProfileMenuItem(icon: Icons.info_outline, title: AppStrings.get('aboutUs')),
                          ),
                          
                          const SizedBox(height: 15),

                          GestureDetector(
                            onTap: _showDeleteAccountDialog,
                            child: ProfileMenuItem(icon: Icons.delete_forever, title: AppStrings.get('deleteAccount')),
                          ),

                          const Spacer(), 
                          
                          TextButton.icon(
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              if(context.mounted) {
                                 Navigator.of(context).pushAndRemoveUntil(
                                   MaterialPageRoute(builder: (context) => const LoginScreen()),
                                   (route) => false);
                              }
                            }, 
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: Text(AppStrings.get('logout'), style: const TextStyle(color: Colors.red))
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileMenuItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A237E)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}