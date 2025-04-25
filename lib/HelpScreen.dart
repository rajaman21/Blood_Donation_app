import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _expandedIndex; // Track which FAQ is expanded

  final List<Map<String, String>> faqData = [
    {'question': 'What are the benefits to donating blood?', 'answer': 'Donating blood helps save lives while also providing health benefits to the donor, such as improved heart health, iron level regulation, and enhanced blood circulation. It also gives a sense of contribution to society.'},
    {'question': 'How do I sign up as a donor?', 'answer': 'You can sign up as a donor by registering on our app and filling out your profile details.'},
    {'question': 'Is there a cost to use this App?', 'answer': 'No, This app is completely free for donors and recipients.'},
    {'question': 'How do I request blood?', 'answer': 'You can request blood by using the request feature in the app and specifying your blood group and location.'},
    {'question': 'What information is required from donors?', 'answer': 'Donors need to provide their name, age, blood type, and contact information.'},
    {'question': 'How do I know if I\'m eligible to donate blood?', 'answer': 'You can check eligibility based on health criteria provided in our app.'},
    {'question': 'Can I donate blood if I have a medical condition?', 'answer': 'It depends on the condition. Please consult a medical professional before donating.'},
  ];

  final List<Map<String, dynamic>> contactData = [
    {'icon': Icons.headset_mic, 'title': 'Customer service', 'contact': '1800-123-456'},
    {'icon': Icons.face, 'title': 'WhatsApp', 'contact': '+91 9876543210'},
    {'icon': Icons.facebook, 'title': 'Facebook', 'contact': '@DonorMate'},
    {'icon': Icons.flutter_dash, 'title': 'Twitter', 'contact': '@DonorMate'},
    {'icon': Icons.camera_alt, 'title': 'Instagram', 'contact': '@DonorMate'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: Text(
          'Help',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFAF0F0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFD32F2F),
              labelColor: const Color(0xFFD32F2F),
              unselectedLabelColor: Colors.black,
              tabs: const [
                Tab(text: 'FAQ'),
                Tab(text: 'Contact us'),
              ],
              onTap: (index) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaqTab(),
                _buildContactUsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds FAQ Tab with Expandable Answers
  Widget _buildFaqTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: faqData.length,
              itemBuilder: (context, index) {
                return _buildFaqItem(index, faqData[index]['question']!, faqData[index]['answer']!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer) {
    bool isExpanded = _expandedIndex == index;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text(question, style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(answer, style: GoogleFonts.nunitoSans(fontSize: 14, color: Colors.grey.shade700)),
          )
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedIndex = expanded ? index : null;
          });
        },
      ),
    );
  }

  /// Builds Contact Us Tab
  Widget _buildContactUsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: contactData.length,
              itemBuilder: (context, index) {
                return _buildContactItem(
                  contactData[index]['icon'],
                  contactData[index]['title'],
                  contactData[index]['contact'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD32F2F)),
        title: Text(title, style: GoogleFonts.nunitoSans(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(contact, style: GoogleFonts.nunitoSans(color: Colors.grey.shade600)),
      ),
    );
  }

  /// Search Bar UI
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.nunitoSans(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
