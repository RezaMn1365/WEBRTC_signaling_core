import 'dart:async';
import 'dart:io';

import 'package:basir_core_sdk/src/generated/socket/socket.pbgrpc.dart';
import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:basir_core_sdk/src/modules/socket/socket.dart';

late Socket socket;

class SockeImpl implements SocketApi {
  // String host = '';
  // int port = 0;
  // SockeImpl({required this.host, required this.port});

  @override
  Future<bool> initSoket(Function(dynamic data) onTcpData) async {
    var ticket = await Storage().getTicket();
    if (ticket == null) {
      return false;
    }
    print('start socket');

    try {
      final socketConnection =
          await Socket.connect(ticket.brokerIp, ticket.port);
      socket = socketConnection;
      socket.listen(onTcpData,
          onError: errorHandler, onDone: doneHandler, cancelOnError: true);
      return true;
    } catch (e) {
      return false;
    }

    // await Socket.connect(host, port).then((Socket socketConnection) {
    //   socket = socketConnection;
    //   socket.listen((data) {
    //     print('tcpdata: $data');
    //     onTcpData(data);
    //   }, onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    // }).catchError((e) {
    //   print("Unable to connect: $e");
    // });
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    socket.destroy();
  }

  @override
  Future<void> sendDataOnSocket(dynamic message) async {
    try {
      // HelloRequest helloRequest = HelloRequest(name: message);
      // var buffer = helloRequest.writeToBuffer();
      // socket.add(buffer);

      var buffer = message.writeToBuffer();
      socket.add(buffer);
    } catch (e) {
      print(' connecting to server failed!');
    }
  }

  @override
  Future<void> sendVerifyReqSocket() async {
    var ticket = await Storage().getTicket();
    var verificationRequest = VerificationRequest(ticket: ticket?.ticket);
    try {
      var buffer = verificationRequest.writeToBuffer();
      socket.add(buffer);

      // List<int> list = 'xxx'.codeUnits; //for Test Server
      // Uint8List bytes = Uint8List.fromList(list); //for Test Server
      // socket.add(bytes);
    } catch (e) {
      print(' connecting to server failed! $e');
    }
  }

  @override
  Future<void> closeSocketConnection() async {
    socket.destroy();
  }
}
