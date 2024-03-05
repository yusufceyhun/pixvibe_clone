import 'dart:io';

import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pixvibe/Controller/save_image_controller.dart';
import 'package:pixvibe/view/edit_image_page.dart';

import '../Controller/image_picker_controller.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int visit = 0;
  bool isLoading = true;
  List<String> projectNames = [];

  Future<void> fetchProjectNames() async {
    projectNames = await _saveImageController.getProjectNames();

    setState(() {
      isLoading = false;
    });
  }

  void handleProjectSelection(String projectName) async {
    final File? imageFile =
        await _saveImageController.getProjectFile(projectName);
    if (imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditImagePage(
            image: imageFile,
            projectName: projectName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project')),
      );
    }
  }

  final ImagePickerController imagePickerController = ImagePickerController();
  final SaveImageController _saveImageController = SaveImageController();

  @override
  void initState() {
    super.initState();
    fetchProjectNames();
  }

  @override
  Widget build(BuildContext context) {
    List<TabItem<dynamic>> items = const [
      TabItem(icon: Icons.home, title: 'Home'),
      TabItem(icon: Icons.search, title: 'Search'),
      TabItem(icon: Icons.notifications, title: 'Notifications'),
      TabItem(icon: Icons.account_circle, title: 'Profile'),
    ];
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 23, 23),
      appBar: null,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                  ),
                  items: [
                    'https://picsum.photos/300',
                    'https://picsum.photos/350',
                    'https://picsum.photos/400',
                  ].map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Beautiful Contrast',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Do you like high contrast?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.indigoAccent.shade700,
                                      ),
                                      child: const Text(
                                        'Try',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Let's Create!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "How do you want to start?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildButton(
                            context,
                            'From Gallery',
                            Icons.photo_library_outlined,
                            Colors.indigo.shade900,
                            () => imagePickerController.selectImage(context),
                          ),
                          _buildButton(
                            context,
                            'Capture Photo',
                            Icons.camera_alt_outlined,
                            Colors.indigoAccent.shade700,
                            () => imagePickerController.capturePhoto(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                projectNames.length > 0
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: projectNames.length,
                          itemBuilder: (context, index) {
                            final projectName = projectNames[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  handleProjectSelection(projectName);
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.shade800,
                                  ),
                                  child: Center(
                                    child: Text(
                                      projectName,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Popular Filters",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Get inspired by them quickly!",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade900,
                              padding: const EdgeInsets.all(8),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'See All',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey,
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                            "https://picsum.photos/240"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Low Contrast",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.all(16.0),
        child: BottomBarBackground(
          items: items,
          backgroundColor: Colors.grey.shade900,
          color: Colors.white,
          colorSelected: Colors.white,
          indexSelected: visit,
          backgroundSelected: Colors.indigoAccent.shade700,
          paddingVertical: 30,
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          onTap: (int index) => setState(() {
            visit = index;
          }),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 30,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
