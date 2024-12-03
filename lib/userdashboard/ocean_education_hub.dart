import 'package:flutter/material.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';

class MarineEducationPage extends StatefulWidget {
  final bool isAdmin;
  final String category;

  const MarineEducationPage({
    super.key,
    this.isAdmin = false,
    required this.category,
  });

  @override
  _MarineEducationPageState createState() => _MarineEducationPageState();
}

class _MarineEducationPageState extends State<MarineEducationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      switch (widget.category) {
        case 'Marine Life':
          _titleController.text =
              'Marine Life: Understanding Our Ocean\'s Creatures';
          _contentController.text = '''
Marine life encompasses the countless species that inhabit our oceans, from microscopic plankton to massive whales.

Key Marine Life Categories:
• Fish Species
• Marine Mammals
• Coral Reefs
• Crustaceans
• Marine Plants

Important Facts:
1. Biodiversity hotspots
2. Species interactions
3. Migration patterns
4. Breeding habits
5. Feeding behaviors

Conservation Status:
• Endangered species
• Protected areas
• Population trends
• Recovery programs
• Monitoring efforts

Understanding marine life is crucial for maintaining healthy ocean ecosystems and ensuring sustainable marine resource management.''';
          break;

        case 'Conservation':
          _titleController.text =
              'Ocean Conservation: Protecting Marine Ecosystems';
          _contentController.text = '''
Ocean conservation is vital for maintaining the health of our marine ecosystems and protecting biodiversity.

Key Conservation Areas:
• Coral reef protection
• Marine sanctuaries
• Coastal preservation
• Species protection
• Habitat restoration

Conservation Strategies:
1. Marine protected areas
2. Sustainable fishing
3. Pollution reduction
4. Climate action
5. Community engagement

How You Can Help:
• Reduce plastic use
• Support conservation groups
• Practice responsible tourism
• Choose sustainable seafood
• Educate others

Together, we can make a difference in protecting our oceans for future generations.''';
          break;

        case 'Regulations':
          _titleController.text = 'Marine Laws and Regulations';
          _contentController.text = '''
Understanding marine laws and regulations is essential for protecting our ocean resources.

Key Regulatory Areas:
• Fishing licenses
• Catch limits
• Protected species
• Marine parks
• Vessel operations

Important Regulations:
1. Fishing seasons
2. Equipment restrictions
3. No-take zones
4. Reporting requirements
5. Safety protocols

Compliance Guidelines:
• License requirements
• Permitted activities
• Restricted areas
• Reporting procedures
• Penalties for violations

Stay informed about marine regulations to help protect our ocean resources.''';
          break;

        default:
          _titleController.text = 'Understanding Overfishing: A Global Crisis';
          _contentController.text = '''
Overfishing is a critical environmental challenge that threatens marine ecosystems, biodiversity, and the livelihoods of millions of people who depend on fishing.

Key Impacts of Overfishing:
• Disruption of marine food chains
• Collapse of fish populations
• Economic devastation for fishing communities
• Irreversible damage to ocean ecosystems

Why It Happens:
1. Unsustainable fishing practices
2. Lack of effective marine regulations
3. Advanced fishing technologies
4. Growing global demand for seafood

Prevention Strategies:
• Implement sustainable fishing quotas
• Protect marine breeding grounds
• Support local fishing communities
• Promote selective fishing techniques
• Raise awareness about marine conservation

Our mission is to educate and empower communities to protect marine resources and ensure a sustainable future for our oceans.''';
      }
    });
  }

  Future<void> _saveContent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 275.0,
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
                widget.category,
                labelstyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
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
                      opacity: 1,
                      child: Image.asset(
                        'assets/EducationalInfoBackground.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          myIcon(
                            Icons.waves_outlined,
                            color: Colors.white,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          myText(
                            'Protecting Our Oceans',
                            labelstyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
            ),
            actions: widget.isAdmin
                ? [
                    myIconbutton(
                      _isEditing ? Icons.save : Icons.edit,
                      _isEditing ? _saveContent : _toggleEdit,
                    ),
                  ]
                : null,
          ),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 12,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing && widget.isAdmin) ...[
                          myTextform(
                              controller: _titleController,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              inputDecoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validation: 'Please Enter Title'),
                          SizedBox(height: 20),
                          myTextform(
                              controller: _contentController,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                height: 1.5,
                              ),
                              inputDecoration: InputDecoration(
                                labelText: 'Content',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validation: 'Please Enter Content'),
                        ] else ...[
                          myText(
                            _titleController.text,
                            labelstyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 16),
                          myText(
                            _contentController.text,
                            labelstyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onBackground,
                              height: 1.5,
                            ),
                          ),
                        ],
                        SizedBox(height: 24),
                        if (!_isEditing)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade100,
                                  Colors.teal.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade700,
                                  child: Icon(Icons.warning_outlined,
                                      color: Colors.white),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: myText(
                                    'Every action counts. Together, we can prevent overfishing and protect our marine ecosystems.',
                                    labelstyle: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: FloatingNavBar(
          currentIndex: 1,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
