import 'package:basir_core_sdk/src/generated/user/user.pbgrpc.dart';

abstract class Auth {
  Future<bool> signInRequest(String username, String password, String agent);
  Future<bool> getTicket();
  Future<bool> logout();
  Future<bool> getProfile();
  Future<bool> getSection();
  Future<Room> getRoomRequest(String roomId);
  Future<bool> tryRefreshoken(String agent);
}
