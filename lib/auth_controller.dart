import 'package:flutter/material.dart';

class AuthController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() {
    String phone = phoneController.text;
    String password = passwordController.text;
    
    // Add API call logic here
    debugPrint('Logging in with Phone: $phone, Password: $password');
  }

  void registerUser() {
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String bloodGroup = bloodGroupController.text;
    String password = passwordController.text;

    // Add API call logic here
    debugPrint('Registering User: $name, $email, $phone, $bloodGroup');
  }
}
