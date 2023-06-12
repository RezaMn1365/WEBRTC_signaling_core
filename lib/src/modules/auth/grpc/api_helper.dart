import 'package:basir_core_sdk/src/modules/auth/storage/storage.dart';
import 'package:grpc/grpc.dart';

Future<void> storeTokens(
    String accessToken, String refreshToken, int expirtyMillis) async {
  var expMillis =
      DateTime.now().millisecondsSinceEpoch + (expirtyMillis * 1000);
  // print(expirtyMillis);
  // print('new exp: $expMillis');
  await Storage().storeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expirtyMillis: expMillis);
  // print('1: ${(await Storage().getTokens())['accessToken']}');
  // print('2: ${(await Storage().getTokens())['refreshToken']}');
  // print('3: ${(await Storage().getTokens())['expirtyMillis']}');
}

Future<void> clearTokens() async {
  final tokens = await Storage().clearUser();
}

Future<String?> getAccessToken() async {
  final tokens = await Storage().getTokens();
  String? accessToken = tokens['accessToken'];
  return accessToken;
}

Future<String?> getRefreshToken() async {
  final tokens = await Storage().getTokens();
  String? refreshtoken = tokens['refreshToken'];
  return refreshtoken;
}

Future<int> getExpirtyMillis() async {
  final tokens = await Storage().getTokens();
  int expirtyMillis = tokens['expirtyMillis'];
  return expirtyMillis;
}

Future<CallOptions> getAuthorizableMetadata() async {
  var token = await getAccessToken();
  token ??= '';
  print(token);
  return CallOptions(metadata: {
    'authorization': 'Bearer ' + token,
    'agent': 'mobile_device',
  });
}

Future<void> storeTicket(
    String brokerIp, String brokerPort, String ticket) async {
  await Storage()
      .storeTicket(brokerIp: brokerIp, brokerPort: brokerIp, ticket: ticket);
}

Future<void> storeProfile(
    String firstName, String lastName, String section, String id) async {
  await Storage().storeProfile(
      firstName: firstName, lastName: lastName, id: id, section: section);
}

Future<String?> getFirstName() async {
  final profile = await Storage().getProfile();
  String? firstName = profile['firstName'];
  return firstName;
}

Future<String?> getLastName() async {
  final profile = await Storage().getProfile();
  String? lastName = profile['lastName'];
  return lastName;
}

Future<String?> getSectionId() async {
  final profile = await Storage().getProfile();
  String? section = profile['section_id'];
  return section;
}

Future<String?> getUserId() async {
  final profile = await Storage().getProfile();
  String? user = profile['user_id'];
  return user;
}

Future<void> storeSection(String sectionId, String title, String desc) async {
  await Storage().storeSection(sectionId: sectionId, title: title, desc: desc);
}

Future<String?> getSectionId2() async {
  final section = await Storage().getSection();
  String? sectionId = section['section_id'];
  return sectionId;
}

Future<String?> getTitle() async {
  final section = await Storage().getSection();
  String? title = section['title'];
  return title;
}

Future<String?> getDesc() async {
  final section = await Storage().getSection();
  String? desc = section['desc'];
  return desc;
}
