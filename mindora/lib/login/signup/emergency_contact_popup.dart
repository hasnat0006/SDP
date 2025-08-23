import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'backend.dart';

class EmergencyContactPopup extends StatefulWidget {
  final String userId;
  final VoidCallback onSaved;

  const EmergencyContactPopup({
    Key? key,
    required this.userId,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<EmergencyContactPopup> createState() => _EmergencyContactPopupState();
}

class _EmergencyContactPopupState extends State<EmergencyContactPopup> {
  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _contact1Controller.dispose();
    _contact2Controller.dispose();
    super.dispose();
  }

  Widget _buildContactField({
    required TextEditingController controller,
    required String label,
    required bool isRequired,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ],
        decoration: InputDecoration(
          labelText: '$label ${isRequired ? '*' : '(Optional)'}',
          hintText: 'Enter phone number',
         
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B7355), width: 2),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          if (value != null && value.isNotEmpty && value.length < 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveEmergencyContacts() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if both contacts are provided
    final contacts = [
      _contact1Controller.text.trim(),
      _contact2Controller.text.trim(),
    ];

    final validContacts = contacts.where((contact) => contact.isNotEmpty).toList();
    
    if (validContacts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both emergency contacts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Saving emergency contacts for user: ${widget.userId}');
      print('🔍 Contacts: $validContacts');

      final result = await BackendService.updateEmergencyContacts(
        userId: widget.userId,
        emergencyContacts: validContacts,
      );

      if (result['success']) {
        print('✅ Emergency contacts saved successfully');
        
        Navigator.of(context).pop(); // Close popup
        widget.onSaved(); // Callback to parent widget
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contacts saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      print('❌ Error saving emergency contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Color(0xFF8B7355),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B7355),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide 2 emergency contacts.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Contact Fields (only 2 now)
              _buildContactField(
                controller: _contact1Controller,
                label: 'Emergency Contact 1',
                isRequired: true,
              ),
              _buildContactField(
                controller: _contact2Controller,
                label: 'Emergency Contact 2',
                isRequired: true,
              ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pop();
                      widget.onSaved();
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveEmergencyContacts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B7355),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}