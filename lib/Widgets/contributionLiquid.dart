import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class ContributionLiquid extends StatelessWidget {
  final double height;
  final double width;
  final double percent;
  final String text;

  ContributionLiquid({
    this.height = 140,
    this.width = 140,
    @required this.percent,
    this.text,
  }) : assert(percent >= 0.0 && percent <= 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      child: LiquidCircularProgressIndicator(
        value: percent,
        valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        borderWidth: 0.0,
        direction: Axis.vertical,
        center: Text(
          text ?? (percent * 100).toInt().toString() + "%",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
