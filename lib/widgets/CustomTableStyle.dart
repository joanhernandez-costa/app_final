import 'dart:ui';

import 'package:flutter/material.dart';

class CustomTableStyle {
  final Color backgroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final Border? border;

  CustomTableStyle({
    this.backgroundColor = Colors.white,
    this.borderRadius,
    this.padding,
    this.border,
  });
}
