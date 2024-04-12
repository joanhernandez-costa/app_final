import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class RestaurantDetail {
  final List<LatLng>? perimeterPoints;
  final double? height;

  RestaurantDetail({
    this.perimeterPoints,
    this.height,
  });

  static Map<String, dynamic> toJson(RestaurantDetail detail) {
    String? perimeterPointsEncoded;
    if (detail.perimeterPoints != null) {
      perimeterPointsEncoded = jsonEncode(detail.perimeterPoints!
          .map((point) => [point.latitude, point.longitude])
          .toList());
    }

    return {
      'perimeter_points': perimeterPointsEncoded,
      'height': detail.height,
    };
  }

  static RestaurantDetail fromJson(Map<String, dynamic> json) {
    List<LatLng>? perimeterPoints;
    if (json['perimeter_points'] != null) {
      Iterable decodedPoints = jsonDecode(json['perimeter_points']);
      perimeterPoints = decodedPoints.map((point) => LatLng(point[0], point[1])).toList();
    } else {
      perimeterPoints = [];
    }

    return RestaurantDetail(
      perimeterPoints: perimeterPoints,
      height: (json['height'] as num?)?.toDouble() ?? 20.0,
    );
  } 
}