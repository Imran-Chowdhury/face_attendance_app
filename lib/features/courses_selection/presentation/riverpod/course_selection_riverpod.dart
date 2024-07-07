import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base_state/course_state.dart';
import '../../../live_feed/presentation/views/live_feed_screen.dart';

final courseProvider =
    StateNotifierProvider.family((ref, day) => CourseNotifier());

class CourseNotifier extends StateNotifier<CourseState> {
  CourseNotifier() : super(const CourseInitialState());

  void navigateToLiveFeed(context, String courseName) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => LiveFeedScreen(),
      ),
    );
  }
}
