import 'dart:ui';

import 'package:app_final/widgets/CustomTableStyle.dart';
import 'package:flutter/material.dart';

class CustomTableBuilder extends StatefulWidget {
  final int? numberOfColumns;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Size? cellSize;
  final bool fixedSize;
  final CustomTableStyle style;
  final int itemCount;

  CustomTableBuilder({
    this.numberOfColumns,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    this.cellSize,
    this.fixedSize = false,
    required this.style,
    required this.itemCount,
  }) : assert(fixedSize && cellSize != null || !fixedSize && numberOfColumns != null,
             'Si fixedSize es true, cellSize no puede ser nulo. Si fixedSize es false, numberOfColumns no puede ser nulo.');

  @override
  CustomTableBuilderState createState() => CustomTableBuilderState();
}


class CustomTableBuilderState extends State<CustomTableBuilder> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int columns = widget.numberOfColumns ?? 3;
        double childAspectRatio = 1;

        if (widget.fixedSize) {
          columns = (constraints.maxWidth / widget.cellSize!.width).floor();
          childAspectRatio = widget.cellSize!.width / widget.cellSize!.height;
        } 

        return Container(
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(widget.style.borderRadius ?? 0)),
            border: widget.style.border,
          ),
          padding: widget.style.padding,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: widget.horizontalSpacing,
              mainAxisSpacing: widget.verticalSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              return Container(color: Colors.blue, child: Center(child: Text(index.toString()))); // Placeholder para la celda.
            },
            itemCount: widget.itemCount,
          ),
        );
      },
    );
  }
}