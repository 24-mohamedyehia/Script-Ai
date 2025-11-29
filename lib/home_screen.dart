import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'recording_screen.dart'; // Import recording screen

class Collection {
  String title;
  int messageCount;

  Collection({required this.title, required this.messageCount});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _collectionNameController = TextEditingController();
  final List<Collection> _collections = [
    Collection(title: 'Cyber Security', messageCount: 7),
    Collection(title: 'Mobile Programming', messageCount: 3),
    Collection(title: 'Artificial Intelligence', messageCount: 12),
    Collection(title: 'Windows Programming', messageCount: 5),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _collectionNameController.dispose();
    super.dispose();
  }
  void _showAddCollectionDialog() {
    _collectionNameController.clear(); 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Collection'),
          content: TextField(
            controller: _collectionNameController,
            decoration: const InputDecoration(hintText: "Enter collection name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String name = _collectionNameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _collections.add(Collection(title: name, messageCount: 0));
                  });
                  Navigator.pop(context); 
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCollectionDialog(int index) {
    _collectionNameController.text = _collections[index].title;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Collection'),
          content: TextField(
            controller: _collectionNameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final String newName = _collectionNameController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _collections[index].title = newName;
                  });
                  Navigator.pop(context); 
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }
  void _deleteCollection(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text(
              'Are you sure you want to delete "${_collections[index].title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _collections.removeAt(index);
                });
                Navigator.pop(context); 
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('ScriptAI',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController, 
              decoration: InputDecoration(
                hintText: 'Search for Collection',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Research',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final collection = _collections[index];
                return CollectionCard(
                  title: collection.title,
                  messageCount: collection.messageCount,
                  onRename: () {
                    _showRenameCollectionDialog(index);
                  },
                  onDelete: () {
                    _deleteCollection(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Audio recording button (main FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open recording screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordingScreen()),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.mic, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: const Icon(Icons.home, color: Color(0xFF1A237E)),
                  onPressed: () {}),
              // Add new collection button
              IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: _showAddCollectionDialog),
              IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionCard extends StatelessWidget {
  final String title;
  final int messageCount;
  final VoidCallback onRename; 
  final VoidCallback onDelete; 

  const CollectionCard({
    super.key,
    required this.title,
    required this.messageCount,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        subtitle:
            Text('$messageCount Meetings', style: const TextStyle(color: Colors.grey)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'rename') {
              onRename();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'rename',
              child: Text('Rename'), 
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'), 
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A237E)),
        ),
      ),
    );
  }
}
