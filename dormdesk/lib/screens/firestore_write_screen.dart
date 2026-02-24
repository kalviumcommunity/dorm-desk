import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'firestore_data_screen.dart';

class FirestoreWriteScreen extends StatefulWidget {
  const FirestoreWriteScreen({super.key});

  @override
  State<FirestoreWriteScreen> createState() => _FirestoreWriteScreenState();
}

class _FirestoreWriteScreenState extends State<FirestoreWriteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _statusController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  
  String _selectedCollection = 'notes';
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _documents = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Form validation
  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  String? _validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Content is required';
    }
    if (value.trim().length > 1000) {
      return 'Content must be less than 1000 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value!.trim());
    if (price == null || price! <= 0) {
      return 'Price must be greater than 0';
    }
    
    if (price > 10000) {
      return 'Price must be less than 10000';
    }
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final email = value!.trim();
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Add document
  Future<void> _addDocument() async {
    setState(() => _isLoading = true);
    _error = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please login to add documents';
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> data = {};
      
      switch (_selectedCollection) {
        case 'notes':
          data = {
            'title': _titleController.text.trim(),
            'content': _contentController.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
            'createdBy': user.uid,
          };
          break;
        case 'products':
          final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
          data = {
            'name': _titleController.text.trim(),
            'price': price,
            'category': _categoryController.text.trim(),
            'inStock': _statusController.text.trim().toLowerCase() == 'true',
            'createdAt': DateTime.now().toIso8601String(),
            'createdBy': user.uid,
          };
          break;
        case 'users':
          data = {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
            'createdBy': user.uid,
          };
          break;
      }

      await _firestoreService.addDocumentSecure(_selectedCollection, data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      _clearForm();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding document: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Update document
  Future<void> _updateDocument(String docId) async {
    setState(() => _isLoading = true);
    _error = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please login to update documents';
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> data = {};
      
      switch (_selectedCollection) {
        case 'notes':
          data = {
            'content': _contentController.text.trim(),
            'updatedAt': DateTime.now().toIso8601String(),
          };
          break;
        case 'products':
          final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
          data = {
            'price': price,
            'category': _categoryController.text.trim(),
            'inStock': _statusController.text.trim().toLowerCase() == 'true',
            'updatedAt': DateTime.now().toIso8601String(),
          };
          break;
        case 'users':
          data = {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'updatedAt': DateTime.now().toIso8601String(),
          };
          break;
      }

      await _firestoreService.updateDocumentSecure(_selectedCollection, docId, data, merge: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      _clearForm();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating document: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Delete document
  Future<void> _deleteDocument(String docId) async {
    setState(() => _isLoading = true);
    _error = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Please login to delete documents';
          _isLoading = false;
        });
        return;
      }

      await _firestoreService.deleteDocumentSecure(_selectedCollection, docId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting document: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Clear form
  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _priceController.clear();
    _categoryController.clear();
    _statusController.clear();
    _emailController.clear();
    _nameController.clear();
  }

  // Load documents
  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    _error = null;

    try {
      final snapshot = await _firestoreService.getCollection(_selectedCollection);
      
      setState(() {
        _documents = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Write Operations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FirestoreDataScreen()),
              );
            },
            tooltip: 'View Firestore Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Collection Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Collection:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedCollection,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'notes', child: Text('Notes')),
                    DropdownMenuItem(value: 'products', child: Text('Products')),
                    DropdownMenuItem(value: 'users', child: Text('Users')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCollection = value!);
                    _loadDocuments();
                  },
                ),
              ],
            ),
          ),
          ),
          
          // Error Display
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _error = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          
          // Form Section
          Card(
            elevation: 8,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New ${_selectedCollection.substring(0, _selectedCollection.length - 1)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Dynamic form fields based on collection
                  if (_selectedCollection == 'notes') ...[
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: _validateContent,
                    ),
                  ] else if (_selectedCollection == 'products') ...[
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        keyboardType: TextInputType.number,
                      ),
                      validator: _validatePrice,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: 'In Stock *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.check_circle),
                      ),
                    ),
                  ] else if (_selectedCollection == 'users') ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      validator: _validateEmail,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addDocument,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add),
                                    const SizedBox(width: 8),
                                    const Text('Add Document'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _loadDocuments(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Documents List
          Expanded(
            child: _documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedCollection} found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addDocument,
                          icon: const Icon(Icons.add),
                          label: const Text('Add First ${_selectedCollection.substring(0, _selectedCollection.length - 1)}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      final data = doc;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Icon(
                              _selectedCollection == 'notes' ? Icons.note :
                              _selectedCollection == 'products' ? Icons.inventory_2 :
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            data['title']?.toString() ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['createdAt'] != null)
                                Text(
                                  'Created: ${_formatDate(data['createdAt'])}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              if (data['updatedAt'] != null && data['updatedAt'] != data['createdAt'])
                                Text(
                                  'Updated: ${_formatDate(data['updatedAt'])}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _titleController.text = data['title']?.toString() ?? '';
                                  _contentController.text = data['content']?.toString() ?? '';
                                  if (_selectedCollection == 'products') {
                                    _priceController.text = data['price']?.toString() ?? '';
                                    _categoryController.text = data['category']?.toString() ?? '';
                                    _statusController.text = data['inStock']?.toString() ?? 'false';
                                  } else if (_selectedCollection == 'users') {
                                    _nameController.text = data['name']?.toString() ?? '';
                                    _emailController.text = data['email']?.toString() ?? '';
                                  }
                                },
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDocument(doc.id),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    
    try {
      final date = timestamp is Timestamp 
          ? (timestamp as Timestamp).toDate()
          : DateTime.parse(timestamp.toString());
      
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
