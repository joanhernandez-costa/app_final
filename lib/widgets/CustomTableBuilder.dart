import 'dart:ui';

import 'package:app_final/widgets/CustomTableStyle.dart';
import 'package:flutter/material.dart';

typedef CellBuilder = Widget Function(BuildContext context, int index);

class CustomTableBuilder extends StatefulWidget {
  final int? numberOfColumns;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Size? cellSize;
  final bool fixedSize;
  final CustomTableStyle style;
  final int itemCount;
  final CellBuilder cellBuilder;

  CustomTableBuilder({
    this.numberOfColumns,
    required this.horizontalSpacing,
    required this.verticalSpacing,
    this.cellSize,
    this.fixedSize = false,
    required this.style,
    required this.itemCount,
    required this.cellBuilder,
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
        int columns = widget.fixedSize ? (constraints.maxWidth / widget.cellSize!.width).floor() : widget.numberOfColumns ?? 3;
        double childAspectRatio = widget.fixedSize ? widget.cellSize!.width / widget.cellSize!.height : 1;

        return Container(
          decoration: BoxDecoration(
            color: widget.style.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(widget.style.borderRadius ?? 0)),
            border: widget.style.border,
          ),
          padding: widget.style.padding,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: widget.horizontalSpacing,
              mainAxisSpacing: widget.verticalSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) => widget.cellBuilder(context, index),
            itemCount: widget.itemCount,
          ),
        );
      },
    );
  }
}