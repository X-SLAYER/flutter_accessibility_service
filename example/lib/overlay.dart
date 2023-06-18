import 'package:flutter/material.dart';

class BlockingOverlay extends StatelessWidget {
  const BlockingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock,
              color: Colors.red,
              size: 70.0,
            ),
            SizedBox(height: 10.0),
            Text(
              'This app is locked',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
