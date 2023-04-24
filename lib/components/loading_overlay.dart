import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.black38,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
