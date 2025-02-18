import 'package:expense_personal/view/screens/account/login_screen.dart';
import 'package:expense_personal/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroduceScreen extends StatefulWidget {
  const IntroduceScreen({super.key});

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "image": "assets/images/thumbnail.png",
      "dot": "assets/images/carousel.png",
      "title": "Note Down Expenses",
      "description": "Daily note your expenses to help manage money",
    },
    {
      "image": "assets/images/thumbnail1.png",
      "dot": "assets/images/carousel1.png",
      "title": "Track Your Spending",
      "description": "Visualize your expenses with simple charts.",
    },
    {
      "image": "assets/images/thumbnail2.png",
      "dot": "assets/images/carousel2.png",
      "title": "Achieve Financial Goals",
      "description": "Save for the future and achieve your dreams.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        page["image"],
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 240,
                        child: Text(
                          page["description"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7580),
                          ),
                        ),
                      ),
                      Image.asset(
                        page["dot"],
                        width: 100,
                        height: 50,
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        backgroundColor: Color(0xFF0E33F3),
                        label: _currentIndex == pages.length - 1
                            ? "Continue"
                            : "Next",
                        onPressed: _nextPage,
                        borderRadius: 14.0,
                        color: Colors.white,
                        fontSize: 20,
                        horizontal: 150,
                        vertical: 10,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
