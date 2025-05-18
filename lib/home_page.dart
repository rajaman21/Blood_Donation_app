import 'package:donor_mate/HelpScreen.dart';
import 'package:donor_mate/blood_req.dart';
import 'package:donor_mate/donation_req.dart';
import 'package:donor_mate/loginscreen.dart';
import 'package:donor_mate/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'find_donors_page.dart';
import 'profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_toastify/flutter_toastify.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "User Name";
  String _userEmail = "user@example.com";
  String _profilePicture =
      "https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      setState(() {
        _userName = user['name'] ?? "User Name";
        _userEmail = user['email'] ?? "user@example.com";
        _profilePicture = user['profilePicture'] ??
            "https://png.pngtree.com/png-clipart/20231019/original/pngtree-user-profile-avatar-png-image_13369991.png";
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentCarouselIndex = 0;
  final List<String> _carouselImages = [
    'https://media.istockphoto.com/id/1415405974/photo/blood-donor-at-donation-with-bouncy-ball-holding-in-hand.jpg?s=612x612&w=0&k=20&c=j0nkmkJxIP6U6TsI3yTq8iuc0Ufhq6xoW4FSMlKaG6A=',
    'https://static.vecteezy.com/system/resources/thumbnails/008/191/708/small_2x/human-blood-donate-and-heart-rate-on-white-background-free-vector.jpg',
    'https://static.vecteezy.com/system/resources/thumbnails/008/190/897/small/human-blood-donate-on-white-background-free-vector.jpg',
    'https://www.careinsurance.com/upload_master/media/posts/June2020/IQKrrYI3nqo0i9PNqO7W.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context, _userName, _userEmail, _profilePicture),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
              items: _carouselImages.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/blood1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image, size: 50),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            // Carousel Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _carouselImages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCarouselIndex == entry.key
                        ? const Color(0xFFD32F2F)
                        : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),

            // Quick Actions Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.search,
                    title: 'Find Donors',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FindDonorsPage()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.water_drop,
                    title: 'Donates',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CreateDonationRequestScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.bloodtype,
                    title: 'Order Bloods',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BloodRequestScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.person,
                    title: 'Help',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpScreen()),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.description,
                    title: 'Report',
                    onTap: () {},
                  ),
                  _buildQuickActionCard(
                    icon: Icons.campaign,
                    title: 'Campaign',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Donation Requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Donation Request',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFD32F2F),
                    ),
                    onPressed: () {
                      // View all donation requests
                    },
                  ),
                ],
              ),
            ),

            // Donation Request List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Show only 3 items in the home page
              itemBuilder: (context, index) {
                // Real names instead of "Username"
                final List<String> donorNames = [
                  'Ankit Singh',
                  'Aman',
                  'Priya Patel'
                ];
                final List<String> bloodTypes = ['A+', 'B-', 'O+'];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFD32F2F),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        donorNames[index],
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Requested ${index + 1} hour${index == 0 ? '' : 's'} ago',
                        style: GoogleFonts.nunitoSans(),
                      ),
                      trailing: Text(
                        bloodTypes[index],
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        // Show accept/reject dialog when tapped
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                'Donation Request',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Do you want to accept ${donorNames[index]}\'s blood donation request for ${bloodTypes[index]}?',
                                style: GoogleFonts.nunitoSans(),
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle accept logic here
                                    Navigator.of(context).pop();
                                    FlutterToastify.success(description: const Text("Request accepted!")).show(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFD32F2F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Accept',
                                    style: GoogleFonts.nunitoSans(
                                        color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle reject logic here
                                    Navigator.of(context).pop();
                                    FlutterToastify.error(description: const Text("Request rejected!")).show(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Reject',
                                    style: GoogleFonts.nunitoSans(
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Donors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindDonorsPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFD32F2F),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _buildDrawer(BuildContext context) {
//   return Drawer(
//     child: ListView(
//       padding: EdgeInsets.zero,
//       children: [
//         const DrawerHeader(
//           decoration: BoxDecoration(
//             color: const Color(0xFFD32F2F),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundImage: NetworkImage(
//                   'https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png',
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'User Name',
//                 style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const Text(
//                 'user@example.com',
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//         _buildDrawerItem(Icons.home, 'Home', () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => const FindDonorsPage()));

//         }),
//         _buildDrawerItem(Icons.search, 'Find Donors', () {}),
//         _buildDrawerItem(Icons.bloodtype, 'Blood Request', () {}),
//         _buildDrawerItem(Icons.request_page, 'Donation Request', () {}),
//         _buildDrawerItem(Icons.assistant, 'Assistant', () {}),
//         _buildDrawerItem(Icons.settings, 'Settings', () {}),
//         _buildDrawerItem(Icons.help, 'FAQ', () {}),
//         _buildDrawerItem(Icons.notifications, 'Notification', () {}),
//         _buildDrawerItem(Icons.person, 'Profile', () {}),
//         _buildDrawerItem(Icons.edit, 'Edit Profile', () {}),
//         _buildDrawerItem(Icons.logout, 'Logout', () {
//           // Logout
//         }),
//       ],
//     ),
//   );
// }

Widget _buildDrawer(BuildContext context, String userName, String userEmail,
    String profilePicture) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Color(0xFFD32F2F)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSppkoKsaYMuIoNLDH7O8ePOacLPG1mKXtEng&s"),
              ),
              const SizedBox(height: 10),
              Text(
                userName,
                style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                userEmail,
                style:
                    GoogleFonts.nunitoSans(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        _buildDrawerItem(context, Icons.home, 'Home', () {
          Navigator.pop(context);
        }),
        _buildDrawerItem(context, Icons.search, 'Find Donors', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FindDonorsPage()),
          );
        }),
        _buildDrawerItem(context, Icons.bloodtype, 'Blood Request', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BloodRequestScreen()),
          );
        }),
        _buildDrawerItem(context, Icons.request_page, 'Donation Request', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateDonationRequestScreen()),
          );
        }),
        _buildDrawerItem(context, Icons.help, 'FAQ', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpScreen()),
          );
        }),
        _buildDrawerItem(context, Icons.person, 'Profile', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }),
        _buildDrawerItem(context, Icons.notifications, 'Notification', () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        }),
        _buildDrawerItem(context, Icons.logout, 'Logout', () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close dialog
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool("isSignedIn", false);
                      await prefs.remove("userData"); // Clear user data

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('OK',
                        style: GoogleFonts.nunitoSans(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.nunitoSans(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        }),
      ],
    ),
  );
}

Widget _buildDrawerItem(
    BuildContext context, IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFFD32F2F)),
    title: Text(title, style: const TextStyle(fontSize: 16)),
    onTap: onTap,
  );
}
