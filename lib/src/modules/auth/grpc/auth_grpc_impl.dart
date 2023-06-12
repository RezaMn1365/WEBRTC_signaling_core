import 'dart:math';

import 'package:basir_core_sdk/src/generated/user/user.pbgrpc.dart';
import 'package:basir_core_sdk/src/modules/auth/auth.dart';
import 'package:basir_core_sdk/src/modules/auth/grpc/api_helper.dart';
import 'package:grpc/grpc.dart';

class AuthGrpcImpl implements Auth {
  int latestexpirtyMillis = 0;

  AuthGrpcImpl({required this.grpcChannelInstance});
  final ClientChannel grpcChannelInstance;

  @override
  Future<bool> signInRequest(String username, String password, String agent, {counter = 0}) async {
    try {
      // ------------------ Authentication, Registration test
      var resualt = UserSigninRequest(
        username: username,
        password: password,
        agent: agent,
      );

      var client = AuthenticationServiceClient(grpcChannelInstance);
      var response = await client.authenticate(resualt);
      if (response.accessToken != '' && response.refreshToken != '' && response.exp > 0) {
        print(
          response.accessToken,
        );
        print(
          response.refreshToken,
        );
        print(response.exp);
        storeTokens(response.accessToken, response.refreshToken, response.exp);
        return true;
      }
    } on GrpcError catch (e) {
      print(e);
      return false;
      // if (e.code == 16) {
      //   if (counter < 2) {
      //     counter += 1;
      //     return sendPassword(passWord, authResponse, counter: counter);
      //   } else {
      //     await clearTokens();
      //     // NavigateToLoginPage();
      //   }
      // } //Unauthorized  Invalid or expired token
    } catch (e) {
      return false;
    }
    return false;
  }

  @override
  Future<bool> tryRefreshoken(String agent, {counter = 0}) async {
    try {
      print('Agent: $agent');
      // ------------------ Authentication, Registration test
      var request = RenewTokenRequest(
        accessToken: await getAccessToken(),
        refreshToken: await getRefreshToken(),
        // ip: null,
        agent: agent,
        // details: null
      );

      print(request.accessToken);
      print(request.refreshToken);
      print(request.agent);

      var client = AuthenticationServiceClient(grpcChannelInstance);
      var response = await client.renewToken(request, options: await getAuthorizableMetadata());
      print('tokens :${response.accessToken}');
      print('tokens :${response.refreshToken}');

      if (response.accessToken != '' && response.refreshToken != '') {
        storeTokens(response.accessToken, response.refreshToken, 900); ///////expirty Time should add to refreshToken API/////////
        return true;
      }
    } on GrpcError catch (e) {
      print(e);

      if (e.code == 16) {
        print('Errrrror $e');
        // await clearTokens();
        return false;
      } else {
        print('Errrrror $e');
        return false;
      }
      //   if (counter < 2) {
      //     counter += 1;
      //     await tryRefreshoken('mobile_device');
      //     return tryRefreshoken('mobile_device', counter: counter);
      //   } else {
      //     await clearTokens();
      //     return false;
      //   }
      // } //Unauthorized  Invalid or expired token
      // else {
      //   return false;
      // }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  @override
  Future<bool> logout() async {
    try {
      var request = LogoutRequest(
        accessToken: await getAccessToken(),
      );
      var client = AuthenticationServiceClient(grpcChannelInstance);
      var response = await client.logout(request, options: await getAuthorizableMetadata());
      await clearTokens();
      return true;
    } on GrpcError catch (e) {
      if (e.code == 16) {
        print('logout $e');
        // await clearTokens();
        return false;
      } //Unauthorized  Invalid or expired token
      else {
        print("logout Undefined Error");
        return false;
      }
    }
  }

  @override
  Future<Room> getRoomRequest(String roomId) async {
    try {
      var request = GetRoomRequest(roomId: roomId);
      var client = RoomManagementServiceClient(grpcChannelInstance, options: await getAuthorizableMetadata());
      var response = await client.getRoom(request);
      return response.room;
    } on GrpcError catch (e) {
      if (e.code == 16) {
        print(e);

        return Room();
      } //Unauthorized  Invalid or expired token
      else {
        print(e);
        return Room();
      }
    }
  }

  // @override
  // Future<Room> getDevices(String roomId) async {
  //   try {
  //     var request = GetRoomRequest(roomId: roomId);
  //     var client = RoomManagementServiceClient(grpcChannelInstance,
  //         options: await getAuthorizableMetadata());
  //     var response = await client.getRoom(request);
  //     response.room.devices;
  //     return response.room;
  //   } on GrpcError catch (e) {
  //     if (e.code == 16) {
  //       print(e);

  //       return Room();
  //     } //Unauthorized  Invalid or expired token
  //     else {
  //       print(e);
  //       return Room();
  //     }
  //   }
  // }

  @override
  Future<bool> getTicket({counter = 0}) async {
    try {
      var request = Empty();
      var client = ConnectorServiceClient(grpcChannelInstance, options: await getAuthorizableMetadata());
      var response = await client.getTicket(request);

      if (response.hasBrokerIp() && response.hasBrokerPort() && response.hasTicket()) {
        print(response.brokerIp);
        print(response.brokerPort);
        print(response.ticket);
        storeTicket(response.brokerIp, response.brokerPort, response.ticket);
        return true;
      } else {
        return false;
      }
    } on GrpcError catch (e) {
      // if (e.code == 16) {
      print(e);
      return false;
      // if (counter < 2) {
      // counter += 1;
      // await refreshTokenAPI('test_admin_agent');
      // return sendPassword(passWord, authResponse, counter: counter);
      // } else {
      //   await clearTokens();
      // NavigateToLoginPage();
      // }
    } //Unauthorized  Invalid or expired token
  }

  @override
  Future<bool> getProfile({counter = 0}) async {
    try {
      var request = Empty();
      var client = ProfilesServiceClient(grpcChannelInstance);
      var response = await client.getProfile(request);

      if (response.hasFirstName() && response.hasLastName() && response.hasSectionId() && response.hasUserId()) {
        print(response.firstName);
        print(response.lastName);
        print(response.userId);
        print(response.sectionId);
        storeProfile(response.firstName, response.lastName, response.sectionId, response.userId);
        return true;
      } else {
        return false;
      }
    } on GrpcError catch (e) {
      print(e);
      return false;
      // if (e.code == 16) {
      //   if (counter < 2) {
      //     counter += 1;
      //     await tryRefreshToken();
      //     return getProfile(counter: counter);
      //   } else {
      //     await clearTokens();
      //     return false;
      //     // NavigateToLoginPage();
      //   }
      // } //Unauthorized  Invalid or expired token
      // else {
      //   return false;
      // }
    }
  }

  @override
  Future<bool> getSection({counter = 0}) async {
    try {
      var request = GetSectionRequest(sectionId: await getSectionId());
      var client = SectionsServiceClient(grpcChannelInstance);
      var response = await client.getSection(request);

      if (response.hasSectionId() && response.hasTitle() && response.hasDesc()) {
        storeSection(
          response.sectionId,
          response.title,
          response.desc,
        );
        return true;
      } else {
        return false;
      }
    } on GrpcError catch (e) {
      print(e);
      return false;
      //   if (e.code == 16) {
      //   if (counter < 2) {
      //   counter += 1;
      //   await tryRefreshToken();
      //   return getSection( counter: counter);
      //   } else {
      //     await clearTokens();
      //     return false;
      //   // NavigateToLoginPage();
      //   }
      // } //Unauthorized  Invalid or expired token
      // else{
      //   return false;
      // }
    }
  }
}
