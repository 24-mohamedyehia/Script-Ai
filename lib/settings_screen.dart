import 'package:flutter/material.dart';
import 'app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  void _changeAppLanguage() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 150,
        color: Colors.white,
        child: Column(
          children: [
             ListTile(
               title: const Text("English"),
               onTap: () async {
                 await AppStrings.setLanguage('en');
                 if(mounted) Navigator.pop(context);
               },
             ),
             ListTile(
               title: const Text("العربية"),
               onTap: () async {
                 await AppStrings.setLanguage('ar');
                 if(mounted) Navigator.pop(context);
               },
             ),
          ],
        ),
      );
    });
  }

  void _changeRecordLanguage() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 150, 
        color: Colors.white,
        child: Column(
          children: [
             ListTile(title: const Text("English (US)"), onTap: () { AppStrings.setRecordLanguage('en-US'); setState((){}); Navigator.pop(context); }),
             ListTile(title: const Text("العربية (Egypt)"), onTap: () { AppStrings.setRecordLanguage('ar-EG'); setState((){}); Navigator.pop(context); }),
          ],
        ),
      );
    });
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
            title: Text(AppStrings.get('settings'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(AppStrings.get('appLang'), AppStrings.languageCode == 'ar' ? 'العربية' : 'English', false, _changeAppLanguage),
                      _buildSettingItem(AppStrings.get('recordLang'), AppStrings.recordLanguageCode, false, _changeRecordLanguage),
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

  Widget _buildSettingItem(String title, String value, bool isDestructive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}