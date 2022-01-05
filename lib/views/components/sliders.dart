import 'package:flutter/material.dart';

class PiwigoSlider extends StatefulWidget {
  const PiwigoSlider({
    Key key,
    this.label = '',
    this.min = 0.0,
    this.max = 1.0,
    this.value = 0.0,
    this.onChangeEnd,
  }) : super(key: key);

  final String label;
  final double min;
  final double max;
  final double value;
  final Function(double) onChangeEnd;

  @override
  _PiwigoSliderState createState() => _PiwigoSliderState();
}
class _PiwigoSliderState extends State<PiwigoSlider> {

  double _currentValue;
  int _divisions;

  @override
  void initState() {
    _currentValue = widget.value;
    _divisions = widget.max.toInt()-widget.min.toInt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      label: widget.label,
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Theme.of(context).scaffoldBackgroundColor,
      divisions: _divisions,
      min: widget.min,
      max: widget.max,
      value: _currentValue,
      onChanged: (_newValue) {
        setState(() {
          _currentValue = _newValue;
        });

        widget.onChangeEnd(_newValue);
      },
      onChangeEnd: (_endValue) {
        setState(() {
          _currentValue = _endValue.ceilToDouble();
        });
      },
    );
  }
}
