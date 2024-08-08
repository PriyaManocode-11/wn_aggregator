import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:wn_aggregator/constants.dart/constant_params.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherFactory _weatherFactory =
      WeatherFactory(ConstantParams.openWeatherApiKey);
  Weather? _weather;
  List<Weather>? _forecast;
  bool isCelsius = true;
  bool _loading = false;

  Weather? get weather => _weather;
  List<Weather>? get forecast => _forecast;
  bool get loading => _loading;

  Future<void> fetchWeather() async {
    _loading = true;
    notifyListeners();

    try {
      Position position = await _determinePosition();
      _weather = await _weatherFactory.currentWeatherByLocation(
          position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error fetching current weather: $e');
      _weather = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFiveDayForecast() async {
    _loading = true;
    notifyListeners();

    try {
      Position position = await _determinePosition();
      _forecast = await _weatherFactory.fiveDayForecastByLocation(
          position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error fetching five day forecast: $e');
      _forecast = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  String determineWeatherCondition(double? temperature) {
    if (temperature == null) return 'no temperature';

    if (temperature <= 10) {
      return 'cold';
    } else {
      return 'hot';
    }
  }
}
