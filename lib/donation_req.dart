import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_toastify/flutter_toastify.dart';

class CreateDonationRequestScreen extends StatefulWidget {
  const CreateDonationRequestScreen({Key? key}) : super(key: key);

  @override
  _CreateDonationRequestScreenState createState() => _CreateDonationRequestScreenState();
}

class _CreateDonationRequestScreenState extends State<CreateDonationRequestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String? _selectedBloodType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _submitRequest() async {
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedBloodType == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final String apiUrl = "https://blood-donation-backend-082i.onrender.com/api/home/donation-requests?userId=67e99111eb32dbea224507ab";
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "name": _nameController.text.trim(),
      "location": _locationController.text.trim(),
      "phone": _phoneController.text.trim(),
      "bloodType": _selectedBloodType,
      "donationDate": "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
      "donationTime": "${_selectedTime!.hour}:${_selectedTime!.minute}",
      "note": _noteController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        FlutterToastify.success(
              description: const Text("Request submitted successfully!"))
          .show(context);
        Navigator.pop(context);
      } else {
         FlutterToastify.error(
              description: const Text("Failed to submit request"))
          .show(context);
      }

    } catch (e) {
        FlutterToastify.error(
        description: const Text("Error: Failed to submit request"),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: Text(
          'Donation Request',
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
                      Image.asset('assets/images.jpg', height: 120, width: 120),
                      const SizedBox(height: 20),
                      _buildTextField(_nameController, Icons.person, 'Name'),
                      const SizedBox(height: 20),
                      _buildTextField(_locationController, Icons.location_on, 'Location'),
                      const SizedBox(height: 20),
                      _buildBloodTypeDropdown(),
                      const SizedBox(height: 20),
                      _buildTextField(_phoneController, Icons.phone, 'Mobile', keyboardType: TextInputType.number),
                      const SizedBox(height: 20),
                      _buildDatePicker(),
                      const SizedBox(height: 20),
                      _buildTimePicker(),
                      const SizedBox(height: 20),
                      _buildTextField(_noteController, Icons.note_alt_outlined, 'Add Note'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: Text(
                    'Request',
                    style: GoogleFonts.nunitoSans(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildTextField(TextEditingController controller, IconData icon, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFD32F2F)),
        hintText: label,
        hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      items: _bloodTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type, style: GoogleFonts.nunitoSans(fontSize: 16)),
        );
      }).toList(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.water_drop, color: Color(0xFFD32F2F)),
        hintText: 'Select Blood Type',
        hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
      ),
      onChanged: (value) {
        setState(() => _selectedBloodType = value);
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: _buildTextField(TextEditingController(
          text: _selectedDate == null ? '' : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
        ), Icons.calendar_month, 'Select Blood Donation Date'),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: AbsorbPointer(
        child: _buildTextField(TextEditingController(
          text: _selectedTime == null ? '' : "${_selectedTime!.hour}:${_selectedTime!.minute}",
        ), Icons.timelapse, 'Select Blood Donation Time'),
      ),
    );
  }
}
