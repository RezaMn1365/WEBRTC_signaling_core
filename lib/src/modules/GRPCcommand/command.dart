import 'package:basir_core_sdk/src/generated/messages/messages.pb.dart';
import 'package:grpc/grpc.dart';

class Command {
  Command({required this.grpcChannelInstance});
  final ClientChannel grpcChannelInstance;

  void sendCommand() async {
    var data = GetLocation();
    var command = CommandMessage(getLocation: data).getLocation;
  }
}
