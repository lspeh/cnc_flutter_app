import 'dart:convert';

import 'package:cnc_flutter_app/connections/db_helper.dart';
import 'package:cnc_flutter_app/models/fitness_activity_model.dart';
import 'package:http/http.dart' as http;

class FitnessActivityDBHelper extends DBHelper {
  var baseUrl = 'https://10.0.2.2:7777/';

  Future<http.Response> getActivities() async {
    var requestUrl = baseUrl + 'api/fitnessActivity/all';
    http.Response response =
        await http.get(Uri.encodeFull(requestUrl), headers: {});
    return response;
  }

  Future<http.Response> saveNewActivity(
      FitnessActivityModel fitnessActivityModel) async {
    var requestUrl = baseUrl + 'api/fitnessActivity/add/';
    var uriResponse = await http.post(requestUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'type': fitnessActivityModel.type,
          'intensity': fitnessActivityModel.intensity.toString(),
          'minutes': fitnessActivityModel.minutes.toString(),
        }));
    // print(await http.get(uriResponse.bodyFields['uri']));
  }
}