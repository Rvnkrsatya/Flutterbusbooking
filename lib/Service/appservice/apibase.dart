// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'api_urls.dart';

class ApiBase {
  static Map<String, String> withOutTokenHeaders = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> getRequestHeaders() {
    var requestHeaders = {
      'Content-Type': 'application/json',
    };
    return requestHeaders;
  }

  static Uri url({
    required String extendedURL,
  }) {
    log('full url ${ApiUrls.baseUrl}$extendedURL');
    return Uri.parse(ApiUrls.baseUrl + extendedURL);
  }

  // static Uri url({
  //   String? fullUrl,
  //   String? extendedURL,
  // }) {
  //   if (fullUrl != null) {
  //     log('FULL URL → $fullUrl');
  //     return Uri.parse(fullUrl);
  //   } else if (extendedURL != null) {
  //     log('EXTENDED URL → ${ApiUrls.baseUrl}$extendedURL');
  //     return Uri.parse(ApiUrls.baseUrl + extendedURL);
  //   } else {
  //     throw ArgumentError('Either fullUrl or extendedURL must be provided.');
  //   }
  // }

  static Future getRequest({
    required String extendedURL,
    required bool withToken,
  }) async {
    final client = http.Client();
    var response = await client.get(
      url(extendedURL: extendedURL),
      headers: withToken ? getRequestHeaders() : withOutTokenHeaders,
    );
    if (response.statusCode == 403) {
      // logout();
    }
    return response;
  }
  // static Future postRequest({
  //   String? fullUrl,
  //   String? extendedURL,
  //   required Object body,
  //   required bool withToken,
  // }) async {
  //   log("Request Body: ${jsonEncode(body)}");
  //
  //   final client = http.Client();
  //   final uri = url(fullUrl: fullUrl, extendedURL: extendedURL);
  //
  //   final response = await client.post(
  //     uri,
  //     headers: withToken ? getRequestHeaders() : withOutTokenHeaders,
  //     body: jsonEncode(body),
  //   );
  //
  //   if (response.statusCode == 403) {
  //     // logout();
  //   }
  //
  //   return response;
  // }


  static Future   postRequest({
    required String extendedURL,
    required Object body,
    required bool withToken,
  }) async {
    log("body ${jsonEncode(body)}");
    final client = http.Client();

    var response = await client.post(url(extendedURL: extendedURL),
        headers: withToken ? getRequestHeaders() : withOutTokenHeaders,
        body: jsonEncode(body));
    if (response.statusCode == 403) {
      // logout();
    }
    return response;
  }


  static Future putRequest({
    required String extendedURL,
    required Object body,
  }) async {
    log("putRequest ${jsonEncode(body)}");
    final client = http.Client();

    return client.put(url(extendedURL: extendedURL),
        headers: getRequestHeaders(), body: jsonEncode(body));
  }

  static Future deleteRequest({
    required String extendedURL,
  }) async {
    final client = http.Client();
    return client.delete(
      url(extendedURL: extendedURL),
      headers: getRequestHeaders(),
    );
  }
}
