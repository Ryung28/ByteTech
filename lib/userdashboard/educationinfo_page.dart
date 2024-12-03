import 'package:flutter/material.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/userdashboard/ocean_education.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';

class OceanEducationHub extends StatefulWidget {
  const OceanEducationHub({super.key});

  @override
  _OceanEducationHubState createState() => _OceanEducationHubState();
}

class _OceanEducationHubState extends State<OceanEducationHub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.blue,
                leading: myIconbutton(
                  Icons.arrow_back,
                  colors: Colors.white,
                  () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: myText(
                    'Ocean Education Hub',
                    labelstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue,
                          Colors.blue.shade700,
                        ],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'assets/EducationalInfoBackground.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.school_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Marine Knowledge',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEducationCard(
                        'Marine Life',
                        Icons.pets_rounded,
                        'Learn about local marine species',
                        'Discover the diverse marine life in our oceans',
                      ),
                      const SizedBox(height: 16),
                      _buildEducationCard(
                        'Conservation',
                        Icons.eco_rounded,
                        'Discover ways to protect our ocean',
                        'Learn about marine conservation efforts',
                      ),
                      const SizedBox(height: 16),
                      _buildEducationCard(
                        'Regulations',
                        Icons.gavel_rounded,
                        'Know your marine laws',
                        'Understand marine regulations and compliance',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: 1,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard(
    String title,
    IconData icon,
    String subtitle,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarineEducationPage(
                category: title,
                isAdmin: false,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue.shade300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
