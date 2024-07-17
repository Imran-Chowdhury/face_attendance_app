import 'package:face_attendance_app/core/constants/constants.dart';
import 'package:flutter/material.dart';

class CourseButton extends StatelessWidget {
  final String courseName;
  final String courseTeacher;
  // final Future<Map<String, List<dynamic>>> listOfStudents;
  final VoidCallback goToCourse;

  const CourseButton(
      {super.key,
      required this.courseName,
      required this.courseTeacher,
      required this.goToCourse});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: goToCourse,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(
            // colors: [Color(0xFF0cdec1), Color(0xFF0ad8e6)],
            colors: [ColorConst.lightButtonColor, ColorConst.darkButtonColor],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 200,
        width: 175,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                courseName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                courseTeacher,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
