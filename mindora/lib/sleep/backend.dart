import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../backend/main_query.dart';
import 'package:http/http.dart'
    as http; // Import the method to interact with the backend

Future<void> sleepInput({
  required int hours,
  required DateTime date,
  required String userId,
}) async {
  final Map<String, dynamic> payload = {
    'hours': hours,
    'date': date is DateTime
        ? DateFormat('yyyy-MM-dd').format(
            date,
          ) // or date.toIso8601String().split('T').first
        : date,
    'userId': userId,
  };

  print("Data for sleep: ");
  print(payload);
  await postToBackend('sleepinput', payload);
}

Future<List<dynamic>> fetchSleepTime({required String userId}) async {
  final data = await getFromBackend('getsleephours/$userId');
  return [data];
}

Future<bool> hasSleepRecord({
  required String userId,
  required DateTime date,
}) async {
  final datefinal = DateFormat('yyyy-MM-dd').format(date);
  final data = await getFromBackend('check/$userId/$datefinal');

  print("User data: ");
  print(data.length);

  if (data.length == 0)
    return true;
  else
    return false;
}
