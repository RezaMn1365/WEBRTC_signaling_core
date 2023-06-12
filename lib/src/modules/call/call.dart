import 'package:basir_core_sdk/src/generated/user/user.pbgrpc.dart';
import 'package:basir_core_sdk/src/modules/auth/grpc/api_helper.dart';
import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:grpc/grpc.dart';
import '../auth/models/phone_history.dart';

class Call {
  Call({required this.grpcChannelInstance});
  final ClientChannel grpcChannelInstance;

  Future<Numbers> getNumbers({counter = 0}) async {
    List<Number> numbers = [];
    int total = 0;
    var resualt = Numbers(
      numbers: numbers,
      total: total,
    );

    try {
      var client = InternalCallServiceClient(
        grpcChannelInstance,
      );
      var response = await client.getUserPhones(Empty(),
          options: await getAuthorizableMetadata());
      if (response.hasTotal() && response.hasRequiredFields()) {
        // storeTokens(response.accessToken, response.refreshToken, response.exp);

      }
      return response;
    } on GrpcError catch (e) {
      if (e.code == 10) {
        if (counter < 2) {
          counter += 1;
          bool refreshed = await tryRefreshoken();
          if (refreshed) {
            return getNumbers(counter: counter);
          } else {
            rethrow;
          }
        } else {
          //await clearTokens();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Whitelists> getWhitelists(String number, {counter = 0}) async {
    GetWhitelist getlist = GetWhitelist(phone: number);
    try {
      var client = InternalCallServiceClient(grpcChannelInstance);
      var response = await client.getWhitelists(getlist,
          options: await getAuthorizableMetadata());
      if (response.hasRequiredFields()) {
        // storeTokens(response.accessToken, response.refreshToken, response.exp);

      }
      return response;
    } on GrpcError catch (e) {
      if (e.code == 10) {
        if (counter < 2) {
          counter += 1;
          bool refreshed = await tryRefreshoken();
          if (refreshed) {
            return getWhitelists(number, counter: counter);
          } else {
            rethrow;
          }
        } else {
          //await clearTokens();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Empty> addWhiteListNumber(String ownNumber, String peerNumber,
      {counter = 0}) async {
    AddWhiteListNumberRequest addList =
        AddWhiteListNumberRequest(ownNumber: ownNumber, peerNumber: peerNumber);
    try {
      var client = InternalCallServiceClient(grpcChannelInstance);
      var response = await client.addWhiteListNumber(addList,
          options: await getAuthorizableMetadata());
      if (response.hasRequiredFields()) {
        // storeTokens(response.accessToken, response.refreshToken, response.exp);

      }
      return response;
    } on GrpcError catch (e) {
      if (e.code == 10) {
        if (counter < 2) {
          counter += 1;
          bool refreshed = await tryRefreshoken();
          if (refreshed) {
            return addWhiteListNumber(ownNumber, peerNumber, counter: counter);
          } else {
            rethrow;
          }
        } else {
          //await clearTokens();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Empty> addWhiteListRange(String ownNumber, int from, int to,
      {counter = 0}) async {
    AddWhiteListRangeRequest addRange =
        AddWhiteListRangeRequest(ownNumber: ownNumber, from: from, to: to);
    try {
      var client = InternalCallServiceClient(grpcChannelInstance);
      var response = await client.addWhiteListRange(addRange,
          options: await getAuthorizableMetadata());
      if (response.hasRequiredFields()) {
        // storeTokens(response.accessToken, response.refreshToken, response.exp);

      }
      return response;
    } on GrpcError catch (e) {
      if (e.code == 10) {
        if (counter < 2) {
          counter += 1;
          bool refreshed = await tryRefreshoken();
          if (refreshed) {
            return addWhiteListRange(ownNumber, from, to, counter: counter);
          } else {
            rethrow;
          }
        } else {
          //await clearTokens();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Empty> addWhiteListLevel(String ownNumber, int level,
      {counter = 0}) async {
    AddWhiteListLevelRequest addLevel =
        AddWhiteListLevelRequest(ownNumber: ownNumber, level: level);
    try {
      var client = InternalCallServiceClient(grpcChannelInstance);
      var response = await client.addWhiteListLevel(addLevel,
          options: await getAuthorizableMetadata());
      if (response.hasRequiredFields()) {
        // storeTokens(response.accessToken, response.refreshToken, response.exp);

      }
      return response;
    } on GrpcError catch (e) {
      if (e.code == 10) {
        if (counter < 2) {
          counter += 1;
          bool refreshed = await tryRefreshoken();
          if (refreshed) {
            return addWhiteListLevel(ownNumber, level, counter: counter);
          } else {
            rethrow;
          }
        } else {
          //await clearTokens();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Future<bool> addNumToHistory(
  //   String ownNumber,
  //   List<String> numbers,
  //   Duration time,
  // ) async {
  //   PhoneNumbersHistory phoneNumbersHistoryInstance =
  //       PhoneNumbersHistory(ownNumber: ownNumber, numbers: numbers, time: time);
  //   List<PhoneNumbersHistory> phoneNumbersList = [];
  //   var fetchPhoneList = await Storage().getPhoneNumbers();

  //   if (fetchPhoneList != null) {
  //     phoneNumbersList.addAll(fetchPhoneList);
  //     phoneNumbersList.add(phoneNumbersHistoryInstance);
  //   } else {
  //     phoneNumbersList.add(phoneNumbersHistoryInstance);
  //   }

  //   try {
  //     await Storage().storePhoneNumbers(phoneNumbers: phoneNumbersList);

  //     return true;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<bool> tryRefreshoken() async {
    try {
      // ------------------ Authentication, Registration test
      var request = RenewTokenRequest(
          accessToken: await getAccessToken(),
          refreshToken: await getRefreshToken(),
          ip: null,
          agent: null,
          details: null);

      var client = AuthenticationServiceClient(grpcChannelInstance);
      var response = await client.renewToken(request);
      if (response.hasAccessToken() && response.hasRefreshToken()) {
        storeTokens(
            response.accessToken, response.refreshToken, 0); ///////exp/////////
        return true;
      } else {
        return false;
      }
    } on GrpcError catch (e) {
      if (e.code == 16) {
        print(e);
        //await clearTokens();
        return false;
        // NavigateToLoginPage();

      } //Unauthorized  Invalid or expired token
      else {
        return false;
      }
    }
  }
}
