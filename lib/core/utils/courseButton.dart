import 'package:flutter/material.dart';

class CourseButton extends StatelessWidget {
  final String courseName;
  // final Future<Map<String, List<dynamic>>> listOfStudents;
  final VoidCallback goToCourse;

  const CourseButton(
      {super.key,
      required this.courseName,
      // required this.listOfStudents,
      required this.goToCourse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Set the width of the button to make it long
      child: ElevatedButton(
        onPressed: goToCourse,
        child: Text(courseName),
      ),
    );
  }
}
