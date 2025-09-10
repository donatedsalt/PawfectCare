import 'package:flutter/material.dart';

/// A constant map of common icon names to their IconData objects.
///
/// This map is used to avoid non-constant invocations of IconData,
/// which can cause issues with tree-shaking in release builds.
const Map<String, IconData> iconMap = {
  'restaurant': Icons.restaurant,
  'local_cafe': Icons.local_cafe,
  'fastfood': Icons.fastfood,
  'fuel': Icons.local_gas_station,
  'flight': Icons.flight,
  'directions_car': Icons.directions_car,
  'shopping_bag': Icons.shopping_bag,
  'shopping_cart': Icons.shopping_cart,
  'store': Icons.store,
  'hotel': Icons.hotel,
  'receipt': Icons.receipt,
  'error': Icons.error,
  'info_outline': Icons.info_outline,
};
