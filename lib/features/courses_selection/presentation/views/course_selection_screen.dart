import 'dart:convert';

import 'package:face_attendance_app/features/courses_selection/presentation/views/course_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/courseButton.dart';

class CourseSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CourseSelectionScreen> createState() =>
      _CourseSelectionScreenState();
}

// 2. extend [ConsumerState]
class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
  // late Future<Map<String, List<dynamic>>> listOfStudents;

  // @override
  // void initState() {
  //   super.initState();

  //   listOfStudents = readMapFromSharedPreferences('Attendance');

  // }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF3a3b45),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CourseButton(
              courseName: 'Course 1',
              // listOfStudents: listOfStudents,
              goToCourse: () {
                navigateToCourses(context, 'Course 1');
              },
            ),
          ),
          Center(
            child: CourseButton(
                courseName: 'Course 2',
                // listOfStudents: listOfStudents,
                goToCourse: () {
                  navigateToCourses(context, 'Course 2');
                }),
          ),
          Center(
            child: CourseButton(
                courseName: 'Course 3',
                // listOfStudents: listOfStudents,
                goToCourse: () {
                  navigateToCourses(context, 'Course 3');
                }),
          ),
          Center(
            child: CourseButton(
              courseName: 'Course 4',
              // listOfStudents: listOfStudents,
              goToCourse: () {
                navigateToCourses(context, 'Course 4');
              },
            ),
          ),
        ],
      ),
    );
  }

  void navigateToCourses(context, String courseName) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => CourseScreen(
          courseName: courseName,
        ),
      ),
    );
  }
}
