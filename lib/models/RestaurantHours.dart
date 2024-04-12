class RestaurantHours {
  final String? opening_time_lj;
  final String? closing_time_lj;
  final String? opening_time_vs;
  final String? closing_time_vs;

  RestaurantHours({
    this.opening_time_lj,
    this.closing_time_lj,
    this.opening_time_vs,
    this.closing_time_vs
  });

  static Map<String, dynamic> toJson(RestaurantHours hours) {
    return {
      'opening_time_lj': hours.opening_time_lj,
      'closing_time_lj': hours.closing_time_lj,
      'opening_time_vs': hours.opening_time_vs,
      'closing_time_vs': hours.closing_time_vs
    };
  }

  static RestaurantHours fromJson(Map<String, dynamic> json) {
    return RestaurantHours(
      opening_time_lj: json['opening_time_lj'] as String? ?? 'Horario desconocido',
      closing_time_lj: json['closing_time_lj'] as String? ?? 'Horario desconocido',
      opening_time_vs: json['opening_time_vs'] as String? ?? 'Horario desconocido',
      closing_time_vs: json['closing_time_vs'] as String? ?? 'Horario desconocido'
    );
  }
}