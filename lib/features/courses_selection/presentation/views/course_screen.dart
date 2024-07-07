import 'dart:convert';

import 'package:face_attendance_app/features/courses_selection/presentation/riverpod/course_selection_riverpod.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/views/course_day.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({super.key, required this.courseName});
  final String courseName;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

// 2. extend [ConsumerState]
class _CourseScreenState extends ConsumerState<CourseScreen> {
  late Future<Map<String, List<dynamic>>> listOfStudents;
  // late Future<Map<String, List<dynamic>>> attendanceSheet;
  late Map<String, List<dynamic>> attendanceSheet;
  late String day;

  @override
  void initState() {
    super.initState();
    listOfStudents = getAllStudents('Total_Students');

    // attendanceSheet = getAttendanceSheet(widget.courseName);
    getAttendanceSheet(widget.courseName);
  }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    // var dayState = ref.watch(CourseProvider(day));
    // CourseNotifier dayController = ref.watch(CourseProvider(day).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF3a3b45),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.courseName),
          GestureDetector(
            onTap: () {
              navigateToDay(context, 'day1', attendanceSheet);
            },
            child: Container(
              color: Colors.red,
              height: 100,
              width: 100,
              child: const Text('Day 1'),
            ),
          ),
          GestureDetector(
            child: Container(
              color: Colors.red,
              height: 100,
              width: 100,
              child: const Text('Day 2'),
            ),
          ),
          Container(
            color: Colors.red,
            height: 100,
            width: 100,
            child: const Text('Day 3'),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     color: Colors.blue,
          //     height: 50,
          //     width: 50,
          //     child: const Center(
          //       child: ElevatedButton(onPressed: onPressed, child: Text('Attend')),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void navigateToDay(context, String day, dynamic attendanceSheet) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) => CourseDayScreen(
          day: day,
          attendedStudentsMap: attendanceSheet,
        ),
      ),
    );
  }

  Future<Map<String, List<dynamic>>> getAllStudents(
      String nameOfJsonFile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      return decodedMap;
    } else {
      return {};
    }
  }

  Future<void> getAttendanceSheet(
    String nameOfJsonFile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      attendanceSheet = decodedMap;
      // return decodedMap;
    } else {
      attendanceSheet = {};
      // return {};
    }
  }

  // Future<Map<String, List<dynamic>>> getAttendanceSheet(
  //   String nameOfJsonFile,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonMap = prefs.getString(nameOfJsonFile);
  //   if (jsonMap != null) {
  //     final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
  //     attendanceSheet = decodedMap;
  //     return decodedMap;
  //   } else {
  //     return {};
  //   }
  // }
  // Future<void>
}
