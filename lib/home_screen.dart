import 'package:flutter/material.dart';
import 'app_strings.dart';
import 'services.dart';
import 'profile_screen.dart';
import 'collection_details_screen.dart';
import 'shimmer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _collectionNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  List<Map<String, dynamic>> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshCollections(); 
  }

  Future<void> _refreshCollections() async {
    if (!mounted) return;
    
    try {
      final data = await SupabaseService.getCollectionsList();
      if (mounted) {
        setState(() {
          _collections = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _collectionNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCollectionDialog() {
    _collectionNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStrings.languageNotifier,
          builder: (context, value, child) {
            return AlertDialog(
              title: Text(AppStrings.get('newCollection')),
              content: TextField(
                controller: _collectionNameController,
                decoration: InputDecoration(hintText: AppStrings.get('enterName')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    final String name = _collectionNameController.text.trim();
                    if (name.isNotEmpty) {
                      await SupabaseService.addCollection(name);
                      if (mounted) Navigator.pop(context);
                      _refreshCollections();
                    }
                  },
                  child: Text(AppStrings.get('add')),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          resizeToAvoidBottomInset: false, 
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(),
            title: Text(AppStrings.get('welcome'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search'),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.get('homeTitle'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              
              Expanded(
                child: _isLoading 
                ? const CollectionsShimmerLoading()
                : RefreshIndicator( 
                    onRefresh: _refreshCollections,
                    child: Builder(
                      builder: (context) {
                        final filteredCollections = _collections.where((item) {
                          final title = item['title'].toString().toLowerCase();
                          return title.contains(_searchQuery);
                        }).toList();

                        if (filteredCollections.isEmpty) {
                          if (_searchQuery.isNotEmpty) {
                             return const Center(child: Text("No results found", style: TextStyle(color: Colors.white)));
                          }
                          return ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(child: Text(AppStrings.get('noCollections'), style: const TextStyle(color: Colors.white))),
                              )
                            ],
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: filteredCollections.length,
                          itemBuilder: (context, index) {
                            final item = filteredCollections[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CollectionDetailsScreen(
                                      collectionId: item['id'],
                                      collectionTitle: item['title'],
                                    ),
                                  ),
                                );
                              },
                              child: CollectionCard(
                                title: item['title'],
                                id: item['id'],
                                onUpdate: _refreshCollections, 
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddCollectionDialog,
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Color(0xFF1A237E), size: 30),
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
                  IconButton(icon: const Icon(Icons.home, color: Color(0xFF1A237E)), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.grey),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class CollectionCard extends StatelessWidget {
  final String title;
  final String id;
  final VoidCallback onUpdate; 

  const CollectionCard({super.key, required this.title, required this.id, required this.onUpdate});

  void _showRenameDialog(BuildContext context) {
    final TextEditingController renameController = TextEditingController(text: title);
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: AppStrings.languageNotifier,
          builder: (context, value, child) {
            return AlertDialog(
              title: Text(AppStrings.get('rename')),
              content: TextField(
                controller: renameController,
                decoration: InputDecoration(hintText: AppStrings.get('enterName')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    if (renameController.text.trim().isNotEmpty) {
                       await SupabaseService.updateCollection(id, renameController.text.trim());
                       if (context.mounted) Navigator.pop(context);
                       onUpdate(); 
                    }
                  },
                  child: Text(AppStrings.get('save')),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: AppStrings.languageNotifier,
        builder: (context, value, child) {
          return AlertDialog(
            title: Text(AppStrings.get('delete')),
            content: Text(AppStrings.get('confirmDelete')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'))),
              TextButton(
                onPressed: () async {
                  try {
                    await SupabaseService.deleteCollection(id);
                    if (context.mounted) Navigator.pop(context); 
                    onUpdate(); 
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('unexpectedError')), backgroundColor: Colors.red)
                      );
                    }
                  }
                },
                child: Text(AppStrings.get('delete'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'delete') {
               _showDeleteConfirmDialog(context);
            } else if (value == 'rename') {
               _showRenameDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'rename', child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(AppStrings.get('rename')),
              ],
            )),
            PopupMenuItem(value: 'delete', child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(AppStrings.get('delete')),
              ],
            )),
          ],
        ),
      ),
    );
  }
}