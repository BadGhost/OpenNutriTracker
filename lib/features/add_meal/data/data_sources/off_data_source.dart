import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/app_const.dart';
import 'package:opennutritracker/core/utils/off_const.dart';
import 'package:opennutritracker/core/utils/ont_http_client.dart';
import 'package:opennutritracker/features/add_meal/data/dto/off_product_response.dart';
import 'package:opennutritracker/features/add_meal/data/dto/off_word_response.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OFFDataSource {
  static const _timeoutDuration = Duration(seconds: 10);
  final log = Logger('OFFDataSource');

  Future<OFFWordResponse> fetchSearchWordResults(String searchString) async {
    try {
      final searchUrlString = OFFConst.getOffWordSearchUrl(searchString);
      final userAgentString = await AppConst.getUserAgentString();
      final httpClient = ONTHttpClient(userAgentString, http.Client());

      final response =
          await httpClient.get(searchUrlString).timeout(_timeoutDuration);
      log.fine('Fetching OFF results from: $searchUrlString');
      if (response.statusCode == OFFConst.offHttpSuccessCode) {
        final wordResponse =
            OFFWordResponse.fromJson(jsonDecode(response.body));
        log.fine('Successful response from OFF');
        return wordResponse;
      } else {
        log.warning('Failed OFF call: ${response.statusCode}');
        return Future.error(response.statusCode);
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while getting OFF word search $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  Future<OFFProductResponse> fetchBarcodeResults(String barcode) async {
    try {
      final searchUrl = OFFConst.getOffBarcodeSearchUri(barcode);
      final userAgentString = await AppConst.getUserAgentString();
      final httpClient = ONTHttpClient(userAgentString, http.Client());

      final response =
          await httpClient.get(searchUrl).timeout(_timeoutDuration);
      log.fine('Fetching OFF result from: $searchUrl');
      if (response.statusCode == OFFConst.offHttpSuccessCode) {
        final productResponse =
            OFFProductResponse.fromJson(jsonDecode(response.body));
        log.fine('Successful response from OFF');
        return productResponse;
      } else {
        log.warning('Failed OFF call: ${response.statusCode}');
        return Future.error(response.statusCode);
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while getting OFF barcode search $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }
}