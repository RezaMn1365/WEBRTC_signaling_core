import 'dart:async';
import 'dart:convert';
import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:basir_core_sdk/src/modules/call/call.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CallSocket {
  CallSocket({required this.storage, required this.call});
  late final Storage storage;
  late final Call call;
  late StreamController<dynamic> _controller;
  late IOWebSocketChannel _channel;
  bool initialized = false;

  // late StreamController<dynamic> _eventController;
  // Stream<dynamic> get events => _eventController.stream;

  WebSocketSink get sink => _channel.sink;
  Stream<dynamic> get stream => _controller.stream;

  bool connected = false;

  Future<void> initialize() async {
    // Timer.periodic(
    //     Duration(seconds: 5), ((timer) => print('Socket On: $timer')));
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse('wss://193.186.32.188:8086/websocket')); //8080
      _controller = StreamController<dynamic>.broadcast();
      _channel.stream.listen((event) {
        // print('Dataaaaa');
        _controller.sink.add(event);
      }, onDone: () {
        print('Socket On  Done');
      }, onError: (e) {
        print('Socket On  Error $e');
      });
      initialized = true;
    } catch (e) {
      initialized = false;
      rethrow;
    }
  }

  // Future<String> makeSocketSignInData() async {
  //   var tokens = await storage.getTokens();
  //   var getNumbers = await call.getNumbers();

  //   var socketSignInData = {
  //     "own_number": getNumbers.numbers[0].number,
  //     "token": tokens['accessToken'],
  //     "agent": 'mobile_device'
  //   };
  //   var socketData = const JsonEncoder()
  //       .convert({"event": 'user_signin', "data": socketSignInData});
  //   // print('Socket Data: $socketData');
  //   return socketData;
  // }

  // Future<void> connect() async {
  //   _eventController = StreamController<dynamic>.broadcast();
  //   await initialize();

  //   if (initialized) {
  //     sink.add(await makeSocketSignInData());
  //     stream.listen(
  //       (raw) async {
  //         try {
  //           _eventController.sink.add(await jsonDecode(raw));
  //           connected = true;
  //         } catch (e) {
  //           connected = false;
  //           rethrow;
  //         }
  //       },
  //       onDone: () {
  //         connected = false;
  //       },
  //       onError: (e) {
  //         connected = false;
  //       },
  //     );
  //   } else {}
  // }

  Future<void> dispose() async {
    _channel.sink.close();
    _controller.close();
  }
}
