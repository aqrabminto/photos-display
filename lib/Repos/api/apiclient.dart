import 'package:get/get.dart';
import 'package:test_pro/core/api/endpoints.dart';


class ApiClient extends GetConnect implements GetxService {
  // late SharedPreferences sharedPreferences;
  late String token=Endpoints.unsplashApiClientID;
  final String appbaseUrl;
  late Map<String, String> _mainHeaders;
  ApiClient({required this.appbaseUrl}) {
    baseUrl = Endpoints.baseURL;
    timeout = const Duration(seconds: 30);

    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      "HttpHeaders.contentTypeHeader": "application/json",
    };
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer$token',
    };
  }

  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    print(uri);
    print(headers!.values);
    try {
      Response response = await get(uri, headers: headers ?? _mainHeaders);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  // Future<Response> postData(String uri, dynamic body) async {
  //   print("hello" + body.toString());
  //   try {
  //     Response response = await post(uri, body, headers: _mainHeaders);
  //     print(response.toString());
  //     return response;
  //   } catch (e) {
  //     print(e.toString());
  //     return Response(statusCode: 1, statusText: e.toString());
  //   }
  // }
}
