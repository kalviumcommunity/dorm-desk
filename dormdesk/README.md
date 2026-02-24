# dormdesk - Firestore Write Operations

A Flutter project demonstrating secure Firestore write operations with comprehensive validation, error handling, and data management.

## Firestore Write Operations Overview

### Complete Implementation
1. **Secure Write Operations** - Validation, sanitization, and error handling
2. **Data Input Forms** - Dynamic forms with real-time validation
3. **Update Functionality** - Safe document updates with merge options
4. **Delete Operations** - Secure deletion with audit logging
5. **Multiple Collections** - Notes, Users, Products with different schemas

## Implementation Details

### 1. Secure Write Operations

#### Add Document with Validation
```dart
Future<DocumentReference> addDocumentSecure(String collection, Map<String, dynamic> data) async {
  // Validate required fields
  final validatedData = _validateDocumentData(collection, data);
  
  // Add metadata
  final documentWithMetadata = {
    ...validatedData,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
    'createdBy': FirebaseAuth.instance.currentUser?.uid,
    'version': 1,
  };
  
  return await _db.collection(collection).add(documentWithMetadata);
}
```

#### Update Document with Security
```dart
Future<void> updateDocumentSecure(String collection, String docId, Map<String, dynamic> data, {bool merge = false}) async {
  // Validate update data
  final validatedData = _validateDocumentData(collection, data);
  
  // Add update metadata
  final updateData = {
    ...validatedData,
    'updatedAt': Timestamp.now(),
    'updatedBy': FirebaseAuth.instance.currentUser?.uid,
    'version': FieldValue.increment(1),
  };
  
  if (merge) {
    await _db.collection(collection).doc(docId).set(updateData, SetOptions(merge: true));
  } else {
    await _db.collection(collection).doc(docId).update(updateData);
  }
}
```

### 2. Data Validation

#### Input Validation Methods
```dart
String? _validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Title is required';
  }
  if (value.trim().length > 100) {
    return 'Title must be less than 100 characters';
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
```

#### Document Data Validation
```dart
Map<String, dynamic> _validateDocumentData(String collection, Map<String, dynamic> data) {
  final validatedData = <String, dynamic>{};
  
  // Remove sensitive fields
  final sensitiveFields = ['password', 'secret', 'token', 'apiKey'];
  
  for (final entry in data.entries) {
    final key = entry.key;
    final value = entry.value;
    
    // Skip sensitive fields
    if (sensitiveFields.contains(key.toLowerCase())) {
      continue;
    }
    
    // Validate required fields
    if (_isRequiredField(collection, key) && (value == null || value.toString().trim().isEmpty)) {
      throw 'Field $key is required and cannot be empty';
    }
    
    // Validate email format
    if (key.toLowerCase() == 'email' && value != null) {
      final email = value.toString().trim();
      if (!_isValidEmail(email)) {
        throw 'Invalid email format';
      }
    }
    
    validatedData[key] = value;
  }
  
  return validatedData;
}
```

### 3. Form Implementation

#### Dynamic Form Fields
```dart
// Notes collection form
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
]

// Products collection form
if (_selectedCollection == 'products') ...[
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
]
```

### 4. Error Handling

#### Comprehensive Error Management
```dart
try {
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
```

## Features Implemented

### 1. **Secure Write Operations**
- **Input Validation**: Real-time field validation with user-friendly messages
- **Data Sanitization**: Remove sensitive fields and prevent script injection
- **Metadata Tracking**: Automatic timestamps and user tracking
- **Version Control**: Document versioning for audit trails

### 2. **Dynamic Forms**
- **Collection Switching**: Different forms for Notes, Users, Products
- **Field Validation**: Required fields, email format, price validation
- **Real-time Feedback**: Instant validation feedback
- **Form Reset**: Clear forms after successful submission

### 3. **Update Operations**
- **Safe Updates**: Use update() to avoid overwriting entire documents
- **Merge Options**: SetOptions(merge: true) for partial updates
- **Validation**: Validate update data before applying
- **Metadata**: Track update timestamps and users

### 4. **Delete Operations**
- **Security Checks**: Verify user authentication
- **Audit Logging**: Log deletions for compliance
- **Confirmation**: User confirmation before deletion
- **Error Handling**: Graceful error recovery

## Testing & Verification

### End-to-End Testing
- [ ] Form validation works correctly
- [ ] Documents are added successfully
- [ ] Updates preserve existing data
- [ ] Delete operations work with confirmation
- [ ] Error messages display properly
- [ ] Firebase Console shows correct data

### Firebase Console Verification
1. **Navigate to Firestore**: Database → Data
2. **Check Collections**: Verify documents in notes, users, products
3. **Validate Data**: Check metadata fields and timestamps
4. **Test Updates**: Modify data → Verify changes

## Code Examples

### Add Document
```dart
await FirebaseFirestore.instance.collection('notes').add({
  'title': title,
  'content': content,
  'createdAt': Timestamp.now(),
  'createdBy': user.uid,
});
```

### Update Document
```dart
await FirebaseFirestore.instance
    .collection('notes')
    .doc(docId)
    .update({
      'content': 'Updated content',
      'updatedAt': Timestamp.now(),
    });
```

### Delete Document
```dart
await FirebaseFirestore.instance
    .collection('notes')
    .doc(docId)
    .delete();
```

## Reflection Questions

### Why is input validation important?
Input validation prevents:
- **Data Corruption**: Invalid or malformed data
- **Security Issues**: Script injection and attacks
- **User Errors**: Typos and format mistakes
- **System Stability**: Prevents crashes from bad data

### Difference between add, set, and update?
- **add()**: Creates document with auto-generated ID
- **set()**: Creates or overwrites document with specific ID
- **update()**: Modifies specific fields without overwriting entire document

### How secure writes prevent accidental data loss?
- **Validation**: Checks data before writing
- **Partial Updates**: update() only changes specified fields
- **Merge Options**: set() with merge preserves existing data
- **Audit Trails**: Track all changes for recovery

## Getting Started

1. **Enable Firestore** in Firebase Console
2. **Install Dependencies**: `flutter pub get`
3. **Run App**: `flutter run`
4. **Test Operations**: Add, update, delete documents

## Key Learnings

### Secure Writing Practices
- **Input Validation**: Always validate before writing
- **Data Sanitization**: Remove sensitive information
- **Error Handling**: Comprehensive error recovery
- **Metadata Tracking**: Audit trails and versioning

### Form Best Practices
- **Real-time Validation**: Instant user feedback
- **Clear Messages**: User-friendly error messages
- **Form Reset**: Clean state after operations
- **Loading States**: Visual feedback during operations
