import 'package:flutter/material.dart';

class InstanceScreen extends StatefulWidget {
  const InstanceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.login,color: Colors.white);
  }
}