# dormdesk - User Input Forms & Validation

A Flutter project demonstrating comprehensive user input handling, form validation, and interactive feedback systems for dormitory management applications.

## Learning Objectives Demonstrated

### 1. User Input Widgets in Flutter

#### TextField vs TextFormField
- **TextField**: Basic text input widget without built-in validation
- **TextFormField**: Enhanced text input with form integration and validation

#### Key Input Components Used:
```dart
// Basic TextField with decoration
TextField(
  decoration: InputDecoration(
    labelText: 'Enter your name',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.person),
  ),
)

// TextFormField with validation
TextFormField(
  controller: _nameController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  },
)
```

#### Button Types Implemented:
- **ElevatedButton**: Primary action buttons with elevation
- **TextButton**: Secondary actions without elevation
- **IconButton**: Icon-based actions in AppBar

### 2. Form Validation System

#### Validation Strategies
```dart
// Name validation - letters only, minimum length
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your full name';
  }
  if (value.trim().length < 3) {
    return 'Name must be at least 3 characters long';
  }
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    return 'Name should only contain letters and spaces';
  }
  return null;
}

// Email validation with regex pattern
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your email address';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

// Phone number validation - exactly 10 digits
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your phone number';
  }
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value.replaceAll(' ', '').replaceAll('-', ''))) {
    return 'Please enter a valid 10-digit phone number';
  }
  return null;
}
```

#### Form State Management
```dart
final _formKey = GlobalKey<FormState>();

// Validate entire form
if (_formKey.currentState!.validate()) {
  // Process form data
}

// Reset form
_formKey.currentState?.reset();
```

### 3. Interactive Feedback System

#### SnackBar Feedback
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Profile submitted successfully!'),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'View',
      textColor: Colors.white,
      onPressed: _showProfileSummary,
    ),
  ),
);
```

#### Loading States
```dart
// Show loading indicator during form submission
Center(
  child: _isLoading
      ? const CircularProgressIndicator()
      : ElevatedButton.icon(
          onPressed: _submitForm,
          icon: const Icon(Icons.send),
          label: const Text('Submit Profile'),
        ),
)
```

### 4. Advanced Form Features

#### Dropdown Selection
```dart
DropdownButtonFormField<String>(
  initialValue: _selectedYear,
  decoration: InputDecoration(
    labelText: 'Academic Year *',
    prefixIcon: const Icon(Icons.school),
  ),
  items: _years.map((String year) {
    return DropdownMenuItem<String>(
      value: year,
      child: Text(year),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      _selectedYear = newValue!;
    });
  },
  validator: (value) {
    if (value == null) {
      return 'Please select your academic year';
    }
    return null;
  },
)
```

#### Section Headers
```dart
Widget _buildSectionHeader(String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

### 5. Form Structure & Organization

#### Multi-Section Form Layout
1. **Personal Information**: Name, Email, Phone
2. **Academic Information**: Year, Department
3. **Dormitory Information**: Room Number, Emergency Contact

#### Responsive Design
- **Scrollable layout** for smaller screens
- **Proper spacing** between sections
- **Material Design 3** theming
- **Accessible input fields** with proper labels

### 6. Error Handling & User Experience

#### Input Validation Types:
- **Required field validation**
- **Format validation** (email, phone)
- **Length validation** (minimum character count)
- **Pattern validation** (room number format)

#### User Experience Features:
- **Real-time validation feedback**
- **Clear error messages**
- **Loading indicators**
- **Success confirmation**
- **Form reset functionality**
- **Profile summary dialog**

## App Features Demonstrating User Input Forms

### 1. **Student Profile Form**
- **Comprehensive data collection** for dormitory residents
- **Multi-section layout** with clear organization
- **Advanced validation** for all input types
- **Interactive feedback** with SnackBar messages

### 2. **Form Navigation Integration**
- **Profile button** in AppBar for easy access
- **Smooth navigation** between screens
- **Context-aware actions** based on form state

### 3. **Validation Examples**
- **Name**: Letters only, minimum 3 characters
- **Email**: Valid email format with regex
- **Phone**: 10-digit number validation
- **Room**: Format validation (A-101 pattern)
- **Dropdown**: Required selection validation

### 4. **User Feedback Systems**
- **Success messages** with action buttons
- **Loading states** during submission
- **Error messages** below invalid fields
- **Profile summary** dialog after submission

## Form States Demonstration

### 1. **Initial State**
- Empty form fields with placeholders
- Clear section headers
- Disabled submit button until validation

### 2. **Validation Error State**
- Red error messages below invalid fields
- Form submission prevented
- Clear guidance for corrections

### 3. **Loading State**
- Submit button shows loading indicator
- Form fields disabled during processing
- User feedback for ongoing operation

### 4. **Success State**
- Green success SnackBar
- Form automatically resets
- Option to view submitted profile

## Code Examples

### Complete Form Implementation
```dart
class UserInputForm extends StatefulWidget {
  const UserInputForm({super.key});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Process form data
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
      }
      
      setState(() => _isLoading = false);
    }
  }
}
```

## Video Explanation

*[Link to your 1-2 minute user input forms video here]*

## Getting Started

This project demonstrates comprehensive user input handling in Flutter applications.

For help getting started with Flutter forms:
- [Flutter Forms & Validation](https://docs.flutter.dev/cookbook/forms)
- [TextField and Input Widgets](https://docs.flutter.dev/cookbook/forms/text-input)
- [Managing Form State](https://docs.flutter.dev/cookbook/forms/validation)

## Key Learnings

### Input Validation Importance
- **Data integrity**: Ensures only valid data is processed
- **User guidance**: Helps users correct input errors
- **Security**: Prevents malicious data submission
- **User experience**: Reduces frustration with clear feedback

### TextField vs TextFormField
- **TextField**: Simple input without form integration
- **TextFormField**: Built-in validation and form state management
- **Form integration**: TextFormField works with GlobalKey<FormState>
- **Validation**: TextFormField provides built-in validator callbacks

### Form State Management Benefits
- **Centralized validation**: Single method to validate all fields
- **Reset functionality**: Easy form clearing and resetting
- **State tracking**: Automatic tracking of form validity
- **Simplified logic**: Cleaner code with built-in state handling

### Best Practices Demonstrated
- **Progressive disclosure**: Organize forms into logical sections
- **Clear error messages**: Specific guidance for corrections
- **Loading feedback**: Indicate processing status to users
- **Success confirmation**: Acknowledge successful submissions
- **Accessibility**: Proper labels and semantic structure
