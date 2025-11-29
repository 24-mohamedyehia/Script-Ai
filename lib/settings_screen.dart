import 'package:flutter/material.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String appLanguage = 'English';
  String meetingLanguage = 'Arabic';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF1A237E),
      
 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ScriptAI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 50),
            
     
            _buildLanguageOption(
              selectedLanguage: appLanguage,
              label: 'App language',
              icon: Icons.language,
              onTap: () {
                showLanguageDialog('App Language');
              },
            ),
            
            const SizedBox(height: 30),
            
            _buildLanguageOption(
              selectedLanguage: meetingLanguage,
              label: 'Meeting Language',
              icon: Icons.language,
              onTap: () {
                showLanguageDialog('Meeting Language');
              },
            ),
            
            const SizedBox(height: 50),
            
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                  
                    showDeleteDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 30),
                
                // Delete account text
                Row(
                  children: [
                    Text(
                      'Delete account',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.delete_outline,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Function to build language option
  Widget _buildLanguageOption({
    required String selectedLanguage,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Selected language
          Text(
            selectedLanguage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Small icon
          Icon(
            Icons.settings,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          
          const Spacer(), // Fill the space
          
          // Text on the right
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Function to show language selection dialog
  void showLanguageDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  setState(() {
                    if (type == 'App Language') {
                      appLanguage = 'English';
                    } else {
                      meetingLanguage = 'English';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Arabic'),
                onTap: () {
                  setState(() {
                    if (type == 'App Language') {
                      appLanguage = 'Arabic';
                    } else {
                      meetingLanguage = 'Arabic';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Function to show delete confirmation dialog
  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Can add account deletion code here
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
