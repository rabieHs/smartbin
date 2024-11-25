import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_bin/models/container.dart';
import 'package:smart_bin/utils/strings.dart';

import '../models/container.dart';

class MapsMethods {
  Set<Marker> getMarkers(List<Trash> containers, BitmapDescriptor icon,
      void Function(Trash)? onTap) {
    return containers
        .map((e) => Marker(
            icon: icon,
            markerId: MarkerId(e.id),
            position: LatLng(e.latitude, e.longitude),
            infoWindow: InfoWindow(title: e.id, onTap: () {}),
            onTap: () => onTap!(e)))
        .toSet();
  }

  Future<CameraPosition> getCurrentUserCameraPosition() async {
    LatLng userPositionLatLang = await getCurrentUserPosition();

    return CameraPosition(target: userPositionLatLang, zoom: 15);
  }

  Future<String> getMapsCountry(GoogleMapController controller) async {
    final region = await controller.getVisibleRegion();

    final lat = (region.northeast.latitude + region.southwest.latitude) / 2;
    final long = (region.northeast.longitude + region.southwest.longitude) / 2;
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(lat, long);
      return placemarks[0].isoCountryCode!;
    } catch (e) {
      throw Exception("Error in getting country code");
    }
  }

  Future<String> getUserAddress() async {
    LatLng userPosition = await getCurrentUserPosition();

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
              userPosition.latitude, userPosition.longitude);
      return "${placemarks[0].subLocality} ${placemarks[0].locality} ${placemarks[0].isoCountryCode}";
    } catch (e) {
      throw Exception("Error in getting country code");
    }
  }

  Future<LatLng> getCurrentUserPosition() async {
    if (await Geolocator.checkPermission() == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position userPositon = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    LatLng userPositionLatLang =
        LatLng(userPositon.latitude, userPositon.longitude);
    return userPositionLatLang;
  }

  Future<String> getJsonStyle(String stylePath) async {
    ByteData byteData = await rootBundle.load(stylePath);

    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  Future<BitmapDescriptor> getMarkerIcon() async {
    return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(50, 50)),
        "assets/images/trash_pin.png");
  }

  Future<double> calculateDistance(double lat, double long) async {
    LatLng currentPosition = await getCurrentUserPosition();
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      lat,
      long,
    );
    return double.parse((distance / 1000).toStringAsFixed(1));
  }

  double calculateEstimatedTime(double distance) {
    final estimatedTime = (distance / 5) * 60;
    return double.parse(estimatedTime.toStringAsFixed(2));
  }

  Future<String> getRoadName(double lat, double long) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(lat, long);
      if (placemarks != null && placemarks.isNotEmpty) {
        geocoding.Placemark placemark = placemarks[0];
        return placemark.street ?? placemark.name ?? placemark.locality!;
      } else {
        return 'Unknown location';
      }
    } catch (e) {
      return 'Unknown location';
    }
  }

  // get bounds

  Future<LatLngBounds> getBounds(LatLng containerPosition) async {
    final userPosition = await getCurrentUserPosition();
    final double lat1 = userPosition.latitude;
    final double lon1 = userPosition.longitude;
    final double lat2 = containerPosition.latitude;
    final double lon2 = containerPosition.longitude;

    final double south = lat1 < lat2 ? lat1 : lat2;
    final double west = lon1 < lon2 ? lon1 : lon2;
    final double north = lat1 > lat2 ? lat1 : lat2;
    final double east = lon1 > lon2 ? lon1 : lon2;

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  Future<List<LatLng>> showRouteBetweenUserAndBin(
      LatLng containerPosition) async {
    final userPosition = await getCurrentUserPosition();
    print(userPosition.latitude);
    print(userPosition.longitude);
    print(containerPosition.latitude);
    print(containerPosition.longitude);
    try {
      final PolylinePoints polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: MAPS_API_KEY,
          request: PolylineRequest(
              origin:
                  PointLatLng(userPosition.latitude, userPosition.longitude),
              destination: PointLatLng(
                  containerPosition.latitude, containerPosition.longitude),
              mode: TravelMode.driving));
      return result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
    } catch (e) {
      print(e);
      throw Exception("Error in getting polyline points");
    }
  }

  Future<Trash> getNearbyContainer(
      List<Trash> containers, LatLng currentPosition) async {
    Trash? nearestContainer;
    double nearestDistance = double.infinity;

    for (Trash container in containers) {
      double distance =
          await calculateDistance(container.latitude, container.longitude);

      // Check if the container is closer and has volume < 90
      if (distance < nearestDistance && container.volume < 90) {
        nearestDistance = distance;
        nearestContainer = container;
      }
    }

    // Return the nearest valid container or throw exception if none found
    if (nearestContainer != null) {
      return nearestContainer;
    } else {
      throw Exception("No nearby container found with acceptable volume");
    }
  }

  Future<List<Trash>> getNearbyContainersInRange(
      List<Trash> containers, LatLng currentPosition) async {
    // List to store containers with their distances
    List<(Trash, double)> containersWithDistance = [];

    // Maximum range in kilometers
    const double maxRange = 5.0;

    // Calculate distance for each container and store if within range
    for (Trash container in containers) {
      double distance =
          await calculateDistance(container.latitude, container.longitude);

      // Only include containers within maxRange kilometers and with volume < 90
      if (distance <= maxRange && container.volume < 90) {
        containersWithDistance.add((container, distance));
      }
    }

    // Sort containers by distance
    containersWithDistance.sort((a, b) => a.$2.compareTo(b.$2));

    // If no containers found within range, throw exception
    if (containersWithDistance.isEmpty) {
      throw Exception(
          "No containers found within 2KM range with acceptable volume");
    }

    // Return list of containers (without distances)
    return containersWithDistance.map((e) => e.$1).toList();
  }
}
