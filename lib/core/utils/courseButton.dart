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
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              Text(
                courseTeacher,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
