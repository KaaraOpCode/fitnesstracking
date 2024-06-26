// ignore_for_file: deprecated_member_use, constant_identifier_names, use_super_parameters, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthApp extends StatefulWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  _HealthAppState createState() => _HealthAppState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  STEPS_READY,
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 0;

  final List<HealthDataType> _dataTypesAndroid = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.HEIGHT,
    HealthDataType.WEIGHT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
  ];

  late Health _healthInstance; // Declare Health instance

  @override
  void initState() {
    super.initState();
    _healthInstance = Health(); // Initialize Health instance
    _initializeHealth();
  }

  Future<void> _initializeHealth() async {
    try {
      await _healthInstance.configure(useHealthConnectIfAvailable: false);
    } catch (e) {
      debugPrint("Error configuring Health instance: $e");
      // Handle initialization errors if needed
    }
  }
  Future<void> authorize() async {
    try {
      await Permission.activityRecognition.request();
      await Permission.location.request();

      bool? hasPermissions = await _healthInstance.hasPermissions(_dataTypesAndroid);

      if (!hasPermissions!) {
        bool authorized = await _healthInstance.requestAuthorization(_dataTypesAndroid);
        setState(() =>
            _state = authorized ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED);
      } else {
        setState(() => _state = AppState.AUTHORIZED);
      }
    } catch (error) {
      debugPrint("Exception in authorize: $error");
      setState(() => _state = AppState.AUTH_NOT_GRANTED);
    }
  }
  Future<void> fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    _healthDataList.clear();

    try {
      List<HealthDataPoint> healthData = await _healthInstance.getHealthDataFromTypes(
        types: _dataTypesAndroid,
        startTime: yesterday,
        endTime: now,
      );

      _healthDataList = healthData;

      setState(() {
        _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } catch (error) {
      debugPrint("Exception in getHealthDataFromTypes: $error");
      setState(() => _state = AppState.NO_DATA);
    }
  }

  Future<void> fetchStepData() async {
    int? steps;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      steps = await _healthInstance.getTotalStepsInInterval(midnight, now);
      setState(() {
        _nofSteps = steps ?? 0;
        _state = steps == null ? AppState.NO_DATA : AppState.STEPS_READY;
      });
    } catch (error) {
      debugPrint("Exception in getTotalStepsInInterval: $error");
      setState(() => _state = AppState.NO_DATA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Example'),
        ),
        body: Column(
          children: [
            Wrap(
              spacing: 10,
              children: [
                TextButton(
                  onPressed: authorize,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                  child: const Text("Authenticate",
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: fetchData,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                  child: const Text("Fetch Data",
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: fetchStepData,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                  child: const Text("Fetch Step Data",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const Divider(thickness: 3),
            Expanded(child: Center(child: _content)),
          ],
        ),
      ),
    );
  }

  Widget get _content => (() {
        switch (_state) {
          case AppState.DATA_READY:
            return _contentDataReady;
          case AppState.DATA_NOT_FETCHED:
            return const Text('Press the fetch button to fetch data.');
          case AppState.NO_DATA:
            return const Text('No Data to show');
          case AppState.AUTH_NOT_GRANTED:
            return const Text('Authorization not given.');
          case AppState.FETCHING_DATA:
            return _contentFetchingData;
          case AppState.STEPS_READY:
            return Text('Total number of steps: $_nofSteps');
          case AppState.AUTHORIZED:
            return const Text('Authorization granted!');
          default:
            return const Text('Unknown state');
        }
      })();

  Widget get _contentFetchingData => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 10),
          SizedBox(height: 20),
          Text('Fetching data...'),
        ],
      );

  Widget get _contentDataReady => ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];
          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text(p.unitString),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        },
      );
}
