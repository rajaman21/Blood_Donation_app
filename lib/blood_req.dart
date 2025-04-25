import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toastify/flutter_toastify.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({Key? key}) : super(key: key);

  @override
  _BloodRequestScreenState createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  // Date and Time variables
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _submitBloodRequest() async {
    final String apiUrl =
        "https://blood-donation-backend-082i.onrender.com/api/home/blood-requests?userId=67e99111eb32dbea224507ab";

    Map<String, dynamic> requestBody = {
      "patient_name": _patientNameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "unit": _unitController.text.trim(),
      "date": _selectedDate != null
          ? "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"
          : "",
      "time": _selectedTime != null
          ? "${_selectedTime!.hour}:${_selectedTime!.minute}"
          : "",
      "blood_group": _selectedBloodGroup,
      "location": _locationController.text.trim(),
      "note": _noteController.text.trim(),
    };
    print(requestBody);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        FlutterToastify.success(
                description: const Text("Request submitted successfully!"))
            .show(context);
            Navigator.pop(context);
      } else {
        FlutterToastify.error(
          description: const Text("Failed to submit request !"),
        ).show(context);
      }
    } catch (e) {
      FlutterToastify.error(
        description: const Text("Error: Failed to submit request"),
      ).show(context);
    }
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      onChanged: (newValue) {
        setState(() {
          _selectedBloodGroup = newValue;
        });
      },
      items: _bloodGroups.map((String group) {
        return DropdownMenuItem(
          value: group,
          child: Text(group, style: GoogleFonts.nunitoSans(fontSize: 16)),
        );
      }).toList(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
        hintText: label,
        hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required Color iconColor,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text, // Default type is text
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType, // Accepts optional keyboard type

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: label,
        hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickTime,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.timelapse, color: Color(0xFFD32F2F)),
            hintText: _selectedTime == null
                ? 'Select Blood Donation Time'
                : "${_selectedTime!.hour}:${_selectedTime!.minute}",
            hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.calendar_month, color: Color(0xFFD32F2F)),
            hintText: _selectedDate == null
                ? 'Select Blood Donation Date'
                : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
            hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: Text(
          'Blood Request',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset('assets/images.jpg', height: 80, width: 80),
                      const SizedBox(height: 2),
                      _buildTextField(
                        icon: Icons.person,
                        label: 'Patient Name',
                        iconColor: const Color(0xFFD32F2F),
                        controller: _patientNameController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        icon: Icons.phone,
                        label: 'Phone Number',
                        iconColor: const Color(0xFFD32F2F),
                        controller: _phoneController,
                        keyboardType:
                            TextInputType.number, // Ensure numeric input
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownField(
                        label: 'Select Blood Group',
                        icon: Icons.bloodtype,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        icon: Icons.water_drop,
                        label: 'Unit /Blood Bag',
                        iconColor: const Color(0xFFD32F2F),
                        controller: _unitController,
                      ),
                      _buildDatePicker(context),
                      const SizedBox(height: 20),
                      _buildTimePicker(context),
                      const SizedBox(height: 20),
                      _buildTextField(
                        icon: Icons.location_on,
                        label: 'Location',
                        iconColor: const Color(0xFFD32F2F),
                        controller: _locationController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        icon: Icons.note_alt_outlined,
                        label: 'Add Note',
                        iconColor: const Color(0xFFD32F2F),
                        controller: _noteController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBloodRequest,
                  child: Text(
                    'Request',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
