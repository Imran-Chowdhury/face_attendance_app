import 'package:face_attendance_app/features/courses_selection/data/data_source/course_selection_data_source.dart';
import 'package:face_attendance_app/features/courses_selection/data/data_source/course_selection_data_source_impl.dart';
import 'package:face_attendance_app/features/courses_selection/domain/course_selection_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseSelectionRepositoryProvider = Provider((ref) {
  return CourseSelectionRepositoryImpl(
      dataSource: ref.read(courseSelectionDataSourceProvider));
});

class CourseSelectionRepositoryImpl extends CourseSelectionRepository {
  CourseSelectionRepositoryImpl({required this.dataSource});
  CourseSelectionDataSource dataSource;

  @override
  List<dynamic>? mapToList(Map<String, List<dynamic>>? attendanceSheetMap) {
    print('Lalalaa');
    List? daysList = [];
    try {
      if (attendanceSheetMap!.isNotEmpty) {
        for (String key in attendanceSheetMap.keys) {
          // daysList!.add(key);
          daysList.add(key);
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
}
