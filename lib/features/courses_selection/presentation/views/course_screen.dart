import 'dart:convert';

import 'package:face_attendance_app/core/base_state/course_screen_state.dart';
import 'package:face_attendance_app/features/courses_selection/presentation/riverpod/course_screen_riverpod.dart';

import 'package:face_attendance_app/features/courses_selection/presentation/views/course_day.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constants.dart';

class CourseScreen extends ConsumerStatefulWidget {
  const CourseScreen({super.key, required this.courseName});
  final String courseName;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

// 2. extend [ConsumerState]
class _CourseScreenState extends ConsumerState<CourseScreen> {
  Constants constant = Constants();
  Map<String, List<dynamic>> mapOfStudents = {};

  Map<String, List<dynamic>>? attendanceSheetMap = {};
  late String day;
  // List<dynamic>? daysFromMap;
  List<dynamic>? listOfDays;

  @override
  void initState() {
    super.initState();

    fetchInitialData();

    print('The attendance map is $attendanceSheetMap');
  }

  Future<void> fetchInitialData() async {
    final attendance = await getAttendanceMap(widget.courseName);
    final students = await getAllStudentsMap(constant.allStudent);

    setState(() {
      attendanceSheetMap = attendance;
      mapOfStudents = students;
    });
  }

  @override
  Widget build(BuildContext context) {
    var courseScreenState = ref.watch(courseScreenProvider(widget.courseName));
    var courseScreenNotifier =
        ref.watch(courseScreenProvider(widget.courseName).notifier);

    List<dynamic>? listOfDays = mapToList(attendanceSheetMap);
    if (courseScreenState is CourseScreeenSuccessState) {
      listOfDays = courseScreenState.data;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF3a3b45),
      body: listOfDays!.isEmpty
          ? const Center(
              child: Text('Start Class'),
            )
          : (courseScreenState is CourseScreeenSuccessState)
              ? ListofDates(courseScreenState.data)
              : ListofDates(listOfDays),

      // ListView.builder(
      //     itemCount: listOfDays.length,
      //     itemBuilder: (context, index) {
      //       print('The list of days is $listOfDays');
      //       return ListTile(
      //         title: Text(listOfDays![index]),
      //       );
      //     },
      //   ),
      floatingActionButton:
          add(context, courseScreenNotifier, listOfDays, attendanceSheetMap),
    );
  }

  Widget ListofDates(List<dynamic>? listOfDays) {
    return ListView.builder(
      itemCount: listOfDays?.length,
      itemBuilder: (context, index) {
        print('The list of days is $listOfDays');
        return ListTile(
          title: Text(listOfDays![index]),
        );
      },
    );
  }

  Widget add(BuildContext context, CourseScreenNotifier courseScreenNotifier,
      List<dynamic>? listOfDays, Map<String, List<dynamic>>? attendanceMap) {
    return FloatingActionButton(onPressed: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        courseScreenNotifier.dayList(widget.courseName, pickedDate.toString(),
            listOfDays, attendanceMap);
      }
    });
  }

  List<dynamic>? mapToList(Map<String, List<dynamic>>? attendanceSheetMap) {
    print('Lalalaa');
    List? daysList = [];
    try {
      if (attendanceSheetMap!.isNotEmpty) {
        for (String key in attendanceSheetMap.keys) {
          daysList!.add(key);
        }
        print(daysList);
      } else {
        daysList = [];
      }
    } catch (e) {
      rethrow;
    }
    return daysList;
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

  Future<Map<String, List<dynamic>>> getAllStudentsMap(
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

  Future<Map<String, List<dynamic>>> getAttendanceMap(
    String nameOfJsonFile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // attendanceSheet = decodedMap;
      return decodedMap;
    } else {
      return {};
    }
  }
}
