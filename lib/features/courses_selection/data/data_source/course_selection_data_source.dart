abstract class CourseSelectionDataSource {
  Future<Map<String, List<dynamic>>> getAttendanceMap(String nameOfJsonFile);
  Future<Map<String, List<dynamic>>> getAllStudentsMap(String nameOfJsonFile);
}
