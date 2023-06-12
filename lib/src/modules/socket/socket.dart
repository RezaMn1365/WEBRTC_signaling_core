import 'package:basir_core_sdk/src/generated/socket/socket.pbgrpc.dart';

abstract class SocketApi {
  ///
  ///initialinig Socket I/O then start listening to it.
  ///
  Future<bool> initSoket(Function(dynamic data) onTcpData);

  ///
  ///this functions sends data on previously opened Socket
  ///
  Future<void> sendDataOnSocket(dynamic message);
  Future<void> sendVerifyReqSocket();

  ///
  ///this function invokes when closing socket needed
  ///
  Future<void> closeSocketConnection();
}
