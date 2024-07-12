import 'dart:convert';

import 'package:face_attendance_app/features/courses_selection/data/data_source/course_selection_data_source.dart';
import 'package:face_attendance_app/features/courses_selection/domain/course_selection_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final courseSelectionDataSourceProvider = Provider((ref) {
  return CourseSelectionDataSourceImpl();
});

class CourseSelectionDataSourceImpl extends CourseSelectionDataSource {
  @override
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

  @override
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
}
