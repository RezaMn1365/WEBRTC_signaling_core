///
/// More dartdocs go here.
library basir_core_sdk;

import 'dart:io';

import 'package:basir_core_sdk/src/modules/auth/grpc/auth_grpc_impl.dart';
import 'package:basir_core_sdk/src/modules/auth/http/auth_http_impl.dart';
import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:basir_core_sdk/src/modules/call/call.dart';
import 'package:basir_core_sdk/src/modules/socket/socket_connection.dart';
import 'package:basir_core_sdk/src/modules/socket/socket_impl.dart';
import 'package:grpc/grpc.dart';
export 'package:basir_core_sdk/src/modules/auth/models/phone_history.dart';
// export 'src/basir_cor
// e_sdk_base.dart';

class BasirCore {
  //convert to singletone
  static final BasirCore _singleton = BasirCore._internal();
  factory BasirCore() {
    return _singleton;
  }
  BasirCore._internal();

  late final ClientChannel grpcChannelInstance;
  late final AuthHttpImpl authHttpImpl;
  late final AuthGrpcImpl authGrpcImpl;
  late final SockeImpl tcpSocket;
  late final Storage storage;
  late final Call call;
  late final CallSocket callSocket;

  Future<void> init({required String serverIp, int? grpcServerPort, int? httpServerPort}) async {
    HttpOverrides.global = MyHttpOverrides();

    await Storage().init();
    storage = Storage();

    if (grpcServerPort != null) {
      var getServerCFG = await Storage().getServerCFG();
      if (getServerCFG['ip'] != null && getServerCFG['port'] != null) {
        serverIp = getServerCFG['ip'];
        grpcServerPort = int.parse(getServerCFG['port']);
        print('got Server CFG');
        print(serverIp);
        print(grpcServerPort);
      } else {
        await BasirCore().storage.storeServerCFG(ip: serverIp, port: grpcServerPort.toString());
      }

      grpcChannelInstance = ClientChannel(
        serverIp,
        port: grpcServerPort,
        options: // No credentials in this example
            const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      authGrpcImpl = AuthGrpcImpl(grpcChannelInstance: grpcChannelInstance);
      call = Call(grpcChannelInstance: grpcChannelInstance);
      if (httpServerPort != null) {
        authHttpImpl = AuthHttpImpl(baseUrl: serverIp, port: httpServerPort.toString());
      }
    } else {
      // authHttpImpl = AuthHttpImpl(baseUrl: serverIp, port: httpServerPort.toString());
    }
    tcpSocket = SockeImpl();
    callSocket = CallSocket(storage: storage, call: call);
  }

  // Future<void> updateServerCFG() async {
  //   String serverIp;
  //   int grpcServerPort;

  //   await shutdown();

  //   var getServerCFG = await Storage().getServerCFG();
  //   if (getServerCFG['ip'] != null && getServerCFG['port'] != null) {
  //     serverIp = getServerCFG['ip'];
  //     grpcServerPort = int.parse(getServerCFG['port']);
  //     print('update Server CFG');
  //     print(serverIp);
  //     print(grpcServerPort);

  //     grpcChannelInstance = ClientChannel(
  //       serverIp,
  //       port: grpcServerPort,
  //       options: // No credentials in this example
  //           const ChannelOptions(
  //         credentials: ChannelCredentials.insecure(),
  //       ),
  //     );
  //     authGrpcImpl = AuthGrpcImpl(grpcChannelInstance: grpcChannelInstance);
  //     call = Call(grpcChannelInstance: grpcChannelInstance);

  //     tcpSocket = SockeImpl();
  //     callSocket = CallSocket(storage: storage, call: call);
  //   }
  // }

  Future<void> shutdown() async {
    await grpcChannelInstance.shutdown();
    //await Storage().shutdown();
    // await tcpSocket.closeSocketConnection();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // add your localhost detection logic here if you want
  }
}
