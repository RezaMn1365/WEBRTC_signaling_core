import 'package:grpc/grpc.dart';

class ChannelMaker {
  static final ChannelMaker _singleton = ChannelMaker._internal();

  factory ChannelMaker() {
    return _singleton;
  }

  ChannelMaker._internal();

  // Future<void> init() async {}

  ClientChannel makeChannelInstance(String serverHost, int serverPort) {
    ClientChannel channel;

    channel = ClientChannel(
      serverHost,
      port: serverPort,
      options: // No credentials in this example
          const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    return channel;
  }
}
