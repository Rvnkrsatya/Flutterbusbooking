import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QueryFormScreen extends StatefulWidget {
  const QueryFormScreen({super.key});

  @override
  State<QueryFormScreen> createState() => _QueryFormScreenState();
}

class _QueryFormScreenState extends State<QueryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _message = '';
  bool _loading = false;
  String? _userId;

  final Color darkBlue = const Color(0xFF033564);
  final Color skyBlue = const Color(0xFF14bde3);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('user_fullName') ?? '';
    final names = fullName.split(' ');

    setState(() {
      _firstNameController.text = names.isNotEmpty ? names[0] : '';
      _lastNameController.text = names.length > 1 ? names.sublist(1).join(' ') : '';
      _phoneController.text = prefs.getString('user_phone') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
      _userId = prefs.getString('_id') ?? '';
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final url = Uri.parse("https://apis.yesgobus.com/api/query/createQuery");

    final body = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "mobile": _phoneController.text.trim(),
      "email": _emailController.text.trim(),
      "description": _descriptionController.text.trim(),
      "userId": _userId ?? "",
    };
    print("First Name: ${_firstNameController.text}");
    print("Last Name: ${_lastNameController.text}");
    print("Mobile: ${_phoneController.text}");
    print("Email: ${_emailController.text}");
    print("User ID: $_userId");

    print("[API CALL] POST: $url");
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("[RESPONSE] ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      setState(() {
        _message = 'Query submitted successfully!';
        _descriptionController.clear();
      });
    } else {
      final data = jsonDecode(res.body);
      setState(() => _message = data['message'] ?? 'Submission failed');
    }

    setState(() => _loading = false);
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      //cursorColor: skyBlue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: darkBlue),
        prefixText: (label == 'Mobile Number') ? '+91 ' : null,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBlue, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text("Query Form", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Column(
                  children: [
                    _buildInput(
                      label: "First Name",
                      icon: Icons.person,
                      controller: _firstNameController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'First name is required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildInput(
                      label: "Last Name",
                      icon: Icons.person_outline,
                      controller: _lastNameController,
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Last name is required'
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildInput(
                  label: "Mobile Number",
                  icon: Icons.phone_android,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) =>
                  val == null || !RegExp(r'^[6-9]\d{9}$').hasMatch(val)
                      ? 'Enter valid 10-digit mobile number'
                      : null,

                ),
                const SizedBox(height: 20),
                _buildInput(
                  label: "Email",
                  icon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val == null || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(val)
                      ? 'Enter valid email'
                      : null,

                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Description is required'
                      : null,
                  cursorColor: skyBlue,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: darkBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: darkBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: skyBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text("Submit",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                if (_message.isNotEmpty)
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _message.contains("success")
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
