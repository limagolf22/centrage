
import 'package:centrage/values.dart';
import 'package:flutter/foundation.dart';

/// Parses URL parameters and returns a map of parameter name to value.
/// For web, uses Uri.base.queryParameters.
/// For non-web platforms, returns an empty map.
Map<String, String> getUrlParameters() {
  if (kIsWeb) {
    return Uri.base.queryParameters;
  }
  return {};
}

/// Applies URL parameters to storedValues for a given plane.
/// Parameters can be slot names with numeric values.
/// Example URL: ?plane=F-GOVL
Plane? applyUrlParameters(Map<String, String> params) {
  if (params.isEmpty) return null;

  // If a specific plane is requested, find it in the list
  String? requestedPlane = params['plane'];
  if (requestedPlane != null) {
    for (var plane in planeList) {
      if (plane.name.toLowerCase() == requestedPlane.toLowerCase()) {
        return plane;
      }
    }
  }
  return null;
}