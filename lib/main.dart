import 'package:donor_mate/DonorReceiverSelectionScreen.dart';
import 'package:donor_mate/detailscreen.dart';
import 'package:donor_mate/donationscreen.dart';
import 'package:donor_mate/home_page.dart';
import 'package:donor_mate/loginscreen.dart';
import 'package:donor_mate/signupscreen.dart';
import 'package:donor_mate/splashscreen.dart';
import 'package:donor_mate/user_type_page.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin services are initialized

  // Check and request location permission
  if (await Permission.locationWhenInUse.isDenied) {
    await Permission.locationWhenInUse.request();
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.redAccent,
          brightness: Brightness.light,
        ).copyWith(secondary: Colors.redAccent, primary: Colors.black),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/donation': (context) => const DonationScreen(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginScreen(),
        '/donor_receiver_selection': (context) =>
            const DonorReceiverSelectionScreen(),
        '/display_details': (context) => const DisplayDetailsScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/user_type': (context) => const UserTypePage(),
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/pngegg.png",
      "title": "Donate Blood",
      "description": "Save lives by donating blood to those in need."
    },
    {
      "image": "assets/donor.png",
      "title": "Find Donors",
      "description": "Easily find blood donors nearby when needed."
    },
    {
      "image": "assets/icon.png",
      "title": "Save Lives",
      "description": "Your donation can make a difference in someone's life."
    }
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/user_type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  image: _pages[index]["image"]!,
                  title: _pages[index]["title"]!,
                  description: _pages[index]["description"]!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: Text(
                    "Skip",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DotsIndicator(
                  dotsCount: _pages.length,
                  position: _currentIndex.toDouble(),
                  decorator: DotsDecorator(
                    activeColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
