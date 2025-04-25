import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:donor_mate/utils/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_toastify/components/enums.dart';
import 'package:flutter_toastify/flutter_toastify.dart';
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignupData {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final String address;
  final String? bloodGroup;
  final String? gender;
  final String? age;
  final String? medicalReportPath;
  final String? userType;
  final String? latitude;
  final String? longitude;

  SignupData({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.address,
    this.bloodGroup,
    this.gender,
    this.age,
    this.medicalReportPath,
    this.userType,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
      "city": city,
      "address": address,
      "bloodGroup": bloodGroup,
      "gender": gender,
      "age": age,
      "medicalReportPath": medicalReportPath,
      "userType": userType,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String? userType; // To store the retrieved user type
  String? _latitude = "12.916916480034176";
  String? _longitude = "77.6099853468055";

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _fetchLocationFromIP();
  }

  Future<void> _fetchLocationFromIP() async {
    try {
      final response = await http.get(Uri.parse("https://ipapi.co/json/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Latitude: ${data["latitude"]}, Longitude: ${data["longitude"]}");
        setState(() {
          _latitude = data["latitude"];
          _longitude = data["longitude"];
        });
      } else {
        print("Failed to fetch location: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _loadUserType() async {
    String? storedUserType = await LocalStorage.getUserType();
    setState(() {
      userType = storedUserType;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  File? _medicalReport;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genderGroups = ['Male', 'Female', 'Other'];
  // Blood group options
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  String? _selectedBloodGroup;
  String? _gender;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _medicalReport = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> sendSignupRequest(SignupData signupData) async {
    
    final signupData = SignupData(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      city: _cityController.text,
      address: _addressController.text,
      bloodGroup: _selectedBloodGroup,
      gender: _gender,
      age: _ageController.text,
      medicalReportPath: _medicalReport?.path,
      userType: userType,
      latitude: _latitude,
      longitude: _longitude,
    );

    const String apiUrl =
        "https://blood-donation-backend-082i.onrender.com/api/auth/signup"; // Replace with actual API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print("Signup successful!");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(responseData['user']));
        await prefs.setString('userType', responseData['user']['userType']);
        await prefs.setBool("isSignedIn", true);
        FlutterToastify.success(
          height: 70,
          width: 360,
          displayCloseButton: false,
          background: Colors.white,
          notificationPosition: NotificationPosition.topLeft,
          animation: AnimationType.fromTop,
          description: Text(
            "Signup successful!",
            style: GoogleFonts.nunitoSans(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          onDismiss: () {},
        ).show(context);
        // Navigate to next page if needed
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Signup failed: ${response.body}");
        FlutterToastify.error(
          height: 70,
          width: 360,
          displayCloseButton: false,
          background: Colors.white,
          notificationPosition: NotificationPosition.topLeft,
          animation: AnimationType.fromTop,
          description: Text(
            "Error: !!",
            style: GoogleFonts.nunitoSans(
                fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          onDismiss: () {},
        ).show(context);
      }
    } catch (e) {
      FlutterToastify.error(
        height: 70,
        width: 360,
        displayCloseButton: false,
        background: Colors.white,
        notificationPosition: NotificationPosition.topLeft,
        animation: AnimationType.fromTop,
        description: Text(
          "Error: !!!",
          style: GoogleFonts.nunitoSans(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        onDismiss: () {},
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // void signInWithGoogle() async {
    //   // Implement Google Sign In here
    // }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text('$userType Registration',
            style: GoogleFonts.nunitoSans(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 255, 205, 216).withOpacity(0.3),
                const Color(0xFFFFCDD2).withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Column(
                        children: [
                          Icon(
                            Icons.bloodtype,
                            color: Color(0xFFD32F2F),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon:
                              Icon(Icons.person_outline, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon:
                              Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      if (userType == 'Donor' || userType == 'Patient')
                        const SizedBox(height: 15),

                      if (userType == 'Donor' || userType == 'Patient')
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.male, color: Colors.grey),
                          ),
                          value: _gender,
                          hint: const Text('Select Gender'),
                          items: _genderGroups.map((String bloodGroup) {
                            return DropdownMenuItem<String>(
                              value: bloodGroup,
                              child: Text(bloodGroup),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _gender = newValue;
                            });
                          },
                          validator: (value) {
                            if (userType == 'Donor' || userType == 'Patient') {
                              if (value == null || value.isEmpty) {
                                return 'Please select your blood group';
                              }
                            }
                            return null;
                          },
                        ),

                      if (userType == 'Donor' || userType == 'Patient')
                        const SizedBox(height: 15),

                      // Age field
                      if (userType == 'Donor' || userType == 'Patient')
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            prefixIcon:
                                Icon(Icons.calendar_today, color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age <= 0 || age > 120) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),

                      if (userType == 'Donor' || userType == 'Patient')
                        const SizedBox(height: 15),
                      // Blood Group dropdown
                      if (userType == 'Donor' || userType == 'Patient')
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.bloodtype, color: Colors.grey),
                          ),
                          value: _selectedBloodGroup,
                          hint: const Text('Select Blood Group'),
                          items: _bloodGroups.map((String bloodGroup) {
                            return DropdownMenuItem<String>(
                              value: bloodGroup,
                              child: Text(bloodGroup),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBloodGroup = newValue;
                            });
                          },
                          validator: (value) {
                            if (userType == 'Donor' || userType == 'Patient') {
                              if (value == null || value.isEmpty) {
                                return 'Please select your blood group';
                              }
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 15),

                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // City field
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon:
                              Icon(Icons.location_city, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Address field (multiline)
                      // City field
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Full Address',
                          prefixIcon: Icon(Icons.home, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Medical report upload (only for Patient and Donor)
                      if (userType == 'Patient' || userType == 'Donor') ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Medical Report (Optional)',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                if (_medicalReport != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _medicalReport!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _medicalReport != null
                                          ? 'Change Medical Report'
                                          : 'Upload Medical Report',
                                      style: GoogleFonts.nunitoSans(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              SignupData signupData = SignupData(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                                phone: _phoneController.text.trim(),
                                city: _cityController.text.trim(),
                                address: _addressController.text.trim(),
                                bloodGroup: _selectedBloodGroup,
                                gender: _gender,
                                age: _ageController.text.trim(),
                                medicalReportPath: _medicalReport?.path,
                                userType: userType,
                                latitude: _latitude ?? "12.901836572567824",
                                longitude: _longitude ?? "77.55847677976726",

                              );

                              print(
                                  "Signup Data: $signupData"); // Print the object

                              await sendSignupRequest(signupData);
                            }
                            // Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.nunitoSans(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Or connect with
                      // Row(
                      //   children: [
                      //     const Expanded(child: Divider()),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         'Or connect with',
                      //         style: TextStyle(
                      //             color: Colors.grey[600], fontSize: 14),
                      //       ),
                      //     ),
                      //     const Expanded(child: Divider()),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),

                      // SizedBox(
                      //   width: 289,
                      //   height: 38,
                      //   child: ElevatedButton(
                      //     onPressed: signInWithGoogle,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //         side: const BorderSide(color: Color(0xFFD32F2F)),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.only(left: 0),
                      //           child: SvgPicture.asset(
                      //             "assets/Google_svg.svg",
                      //             width:
                      //                 20, // Adjust the width according to your SVG size
                      //             height:
                      //                 20, // Adjust the height according to your SVG size
                      //           ),
                      //         ),
                      //         const SizedBox(width: 25),
                      //         // Add some space between the icon and the label
                      //         Text(
                      //           "Sign in with Google",
                      //           style: GoogleFonts.nunitoSans(
                      //             color: Colors.black,
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w700,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 20),

                      // Log in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              'Login',
                              style: GoogleFonts.nunitoSans(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
