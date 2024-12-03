import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  bool _isVisible = true;
  int _currentIndex = 0;
  AnimationController? _animationController;

  bool get isVisible => _isVisible;
  int get currentIndex => _currentIndex;

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  Future<void> toggleNavBar() async {
    if (_animationController?.status == AnimationStatus.forward || _animationController?.status == AnimationStatus.reverse) return;
    
    _isVisible = !_isVisible;
    
    try {
      if (_isVisible && _animationController != null) {
        await _animationController!.forward();
      } else if (!_isVisible && _animationController != null) {
        await _animationController!.reverse();
      }
    } catch (e) {
      print('Animation error handled: $e');
    }
    
    notifyListeners();
  }

  void updateIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _animationController = null;
    super.dispose();
  }
} 