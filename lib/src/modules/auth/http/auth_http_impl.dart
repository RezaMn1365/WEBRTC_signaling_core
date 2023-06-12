import 'package:basir_core_sdk/src/modules/auth/auth.dart';
import 'package:basir_core_sdk/src/base/basic_api_response.dart';
import 'package:basir_core_sdk/src/modules/auth/grpc/api_helper.dart';
import 'package:basir_core_sdk/src/modules/auth/models/refresh_token.dart';
import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:dio/dio.dart';
import 'package:dio_logging_interceptor/dio_logging_interceptor.dart';

import '../models/device_model.dart';

class AuthHttpImpl {
  int latestexpirtyMillis = 0;
  String baseUrl;
  String port;
  AuthHttpImpl({required this.baseUrl, required this.port});

  Future<bool> signInRequest(Device deviceData) async {
    var response = await _post('http://$baseUrl:$port/authentication/signin', deviceData.toJson());

    if (response.success && response.data != null) {
      String accessToken = response.data['access_token'];
      String refreshToken = response.data['refresh_token'];
      int expirtyMillis = response.data['exp'];
      expirtyMillis = DateTime.now().millisecondsSinceEpoch + (expirtyMillis * 1000);
      await _storeTokens(accessToken, refreshToken, expirtyMillis);
    }

    if (response.success) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestTicket() async {
    var response = await _get('http://' + baseUrl + ':' + port + '/connector/get', authorized: true, firstTry: true);

    if (response.success && response.data != null) {
      String ticket = response.data['ticket'];
      String brokerIp = response.data['broker_ip'];
      String brokerPort = response.data['broker_port'];
      await _storeTicket(ticket, brokerIp, brokerPort);
    }

    if (response.success) {
      return true;
    } else {
      return false;
    }
  }

  Future<BasicApiResponse> logout() async {
    var _response = await _get('http://' + baseUrl + ':' + port + '/authentication/logout', authorized: true, firstTry: true);

    return _response;
  }

  Future<bool> checkRoom(String roomId) async {
    var response = await _post('http://' + baseUrl + ':' + port + '/webrtc/room/check', {"room_id": roomId}, authorized: true);
    print('dataaaa: ${response.message}');
    print('dataaaa: ${response.errorMessage}');
    if (response.success && response.message != null) {
      String message = response.message!;
      if (message == "room found") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //post//post//post//post//post//post//post//post//post//post//post//post
  Future<BasicApiResponse> _post(String url, dynamic data, {bool firstTry = true, bool authorized = false}) async {
    var _dio = Dio();

    _dio.options.contentType = 'application/json; charset=UTF-8';

    if (authorized) {
      var token = await getAccessToken();
      if (token != null) {
        _dio.options.headers["Authorization"] = 'Bearer ' + token;
      }
    }

    _dio.interceptors.add(
      DioLoggingInterceptor(
        level: Level.body,
        compact: false,
      ),
    );

    try {
      var response = await _dio.post(
        url,
        data: data,
      );

      print('Response: ${response.statusCode}, ${response.statusMessage}: ${response.data}');

      return BasicApiResponse.fromJson(response.data);
    } on DioError catch (e) {
      return _handleExceptions(e, url, data, true, authorized, firstTry);
    } catch (e) {
      print('Http post Error: Failed to get response from server.');
      return BasicApiResponse.failed('Failed to get response from server.');
    }
  }

  //_get//_get//_get//_get//_get//_get//_get//_get//_get//_get//_get//_get
  Future<BasicApiResponse> _get(String url, {bool firstTry = true, bool authorized = false}) async {
    var _dio = Dio();

    _dio.options.contentType = 'application/json; charset=UTF-8';

    if (authorized) {
      var token = await getAccessToken();
      print(token);
      if (token != null) {
        _dio.options.headers["Authorization"] = 'Bearer ' + token;
      }
    }

    _dio.interceptors.add(
      DioLoggingInterceptor(
        level: Level.body,
        compact: false,
      ),
    );

    try {
      var response = await _dio.get(
        url,
      );

      return BasicApiResponse.fromJson((response.data));
    } on DioError catch (e) {
      return _handleExceptions(e, url, null, false, authorized, firstTry);
    } catch (e) {
      print('Http Get Error: Failed to get response from server.');
      return BasicApiResponse.failed('Failed to get response from server.');
    }
  }

  // Future<String?> _getAccessToken() async {
  //   final tokens = await Storage().getTokens();
  //   String? accessToken = tokens['accessToken'];
  //   return accessToken;
  // }

  // Future<String?> _getRefreshToken() async {
  //   final tokens = await Storage().getTokens();
  //   String? refreshtoken = tokens['refreshToken'];
  //   return refreshtoken;
  // }

  // Future<int> _getExpirtyMillis() async {
  //   final tokens = await Storage().getTokens();
  //   int expirtyMillis = tokens['expirtyMillis'];
  //   return expirtyMillis;
  // }

  Future<void> _storeTokens(String accessToken, String refreshToken, int expirtyMillis) async {
    await Storage().storeTokens(accessToken: accessToken, refreshToken: refreshToken, expirtyMillis: expirtyMillis);
  }

  Future<String?> _getTicket() async {
    final tokens = await Storage().getTicket();
    String? ticket = tokens!.ticket;
    return ticket;
  }

  Future<String?> _getBrokerIp() async {
    final tokens = await Storage().getTicket();
    String? brokerIp = tokens!.brokerIp;
    return brokerIp;
  }

  Future<int?> _getBrokerPort() async {
    final tokens = await Storage().getTicket();
    int? brokerPort = tokens!.port;
    return brokerPort;
  }

  Future<void> _storeTicket(String ticket, String brokerIp, String brokerPort) async {
    await Storage().storeTicket(ticket: ticket, brokerIp: brokerIp, brokerPort: brokerPort);
  }

  Future<void> _clearTokens() async {
    await Storage().clearUser();
  }

  Future<bool> tryRefreshToken() async {
    print('Performin refresh token');
    String _url = baseUrl + '/authentication/renew_token';

    var request = RefreshToken(accessToken: await getAccessToken(), refreshToken: await getRefreshToken()).toJson();

    var dio = Dio();
    dio.options.contentType = 'application/json';
    dio.interceptors.add(
      DioLoggingInterceptor(
        level: Level.body,
        compact: false,
      ),
    );

    try {
      var response = await dio.post(_url, data: request);

      var _response = BasicApiResponse.fromJson((response.data));

      if (_response.success && _response.data != null) {
        // print('trueeeeeeeeeeeeeeeeeeeeeeee');
        String accessToken = _response.data['access_token'];
        String refreshToken = _response.data['refresh_token'];
        int expirtyMillis = await getExpirtyMillis();
        // DateTime.now().millisecondsSinceEpoch + (expirtyMillis * 1000);

        await _storeTokens(accessToken, refreshToken, expirtyMillis);

        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
      // print('DioError $e');

      return false;
    } catch (e) {
      // print('Error $e');
      return false;
    }
    // return false;
  }

  Future<BasicApiResponse> _handleExceptions(DioError e, String url, dynamic data, bool isPost, bool authorized, bool firstTry) async {
    if (e.response != null) {
      if (e.response?.statusCode == 400) {
        //Invalid Parameters
        return BasicApiResponse.missingParams(e.response?.data);
      } else if (e.response?.statusCode == 401 && firstTry) {
        // Unauthorized
        var refreshDone = await tryRefreshToken();
        if (refreshDone) {
          if (isPost) {
            print('Recalling $url with $data as POST');
            return await _post(url, data, authorized: authorized, firstTry: false);
          } else {
            print('Recalling $url as GET');
            return await _get(url, authorized: authorized, firstTry: false);
          }
        } else {
          _clearTokens();

          // final NavigationService _navigationService =
          //     locator<NavigationService>();
          // _navigationService.navigateTo(routes.LoginPage);
          //notify to go to login page
          // Shared().notifyLoginRequired();
          print('Exception: Unauthorized. Login required.');
          return BasicApiResponse.failed('Unauthorized. Login required.');
        }
      }
      return BasicApiResponse.fromJson(e.response?.data);
    }
    if (e.message.contains('SocketException')) {
      print('Exception: Failed to connect to server.');
      return BasicApiResponse.failed('Failed to connect to server.');
    }
    print('BasicApiResponse.failed');
    print('Exception Fatal: ${e.message}.');
    return BasicApiResponse.failed(e.message);
  }
}
