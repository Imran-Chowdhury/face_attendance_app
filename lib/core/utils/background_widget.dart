import 'package:flutter/material.dart';

import '../constants/constants.dart';

class BackgroudContainer extends StatelessWidget {
  const BackgroudContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          ColorConst.backgroundColor,
          Color.fromARGB(92, 95, 167, 231),
        ]),
      ),
    );
  }
}
