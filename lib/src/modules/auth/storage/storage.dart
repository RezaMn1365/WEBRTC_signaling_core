import 'dart:convert';

import 'package:basir_core_sdk/src/generated/user/user.pbgrpc.dart';
import 'package:basir_core_sdk/src/modules/auth/models/broker_ticket.dart';
import 'package:basir_core_sdk/src/modules/auth/models/phone_history.dart';
import 'package:basir_core_sdk/src/modules/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_storage.dart';
import 'storage_driver.dart';
import 'package:basir_core_sdk/src/modules/auth/models/device_model.dart' as d;

//APP SERVER CONFIG
const String SERVER_IP = 'SERVERIP';
const String SERVER_PORT = 'SERVERPORT';

//APP PIN CODE
const String APP_PINCODE = 'APPPINCODE';
const String APP_FINGEREN = 'APPFINGEREN';

//PHONE NUMBERS
const String PHONE_NUMBERS = 'PHONENUMBERS';

//ROOM
const String KEY_ROOM = 'ROOM';

//USER
const String KEY_USERNAME = 'USERNAME';
const String KEY_PASSWORD = 'PASSWORD';

//DEVICE
const String KEY_DEV_ID = 'ID';
const String KEY_SECRET = 'SECRET';
const String KEY_LOCAL = 'LOCAL';
const String KEY_SERIAL = 'SERIAL';

//SECTION
const String KEY_SECTIONID = 'SECTIONID';
const String KEY_TITLE = 'TITLE';
const String KEY_DESC = 'DESC';

//PROFILE
const String KEY_FIRSTNAME = 'FIRSTNAME';
const String KEY_LASTNAME = 'LASTNAME';
const String KEY_SECTION = 'SECTION';
const String KEY_ID = 'ID';

//TOKEN
const String KEY_HIVE_SECURE_TOKEN_BOX = 'KEY_HIVE_SECURE_TOKEN_BOX';
const String KEY_ACCESSTOKENT = 'ACCESSTOKENT';
const String KEY_REFERESHTOKENT = 'REFERESHTOKENT';
const String KEY_EXPIRTY_MILLIS = 'EXPIRTY_MILLIS';

//TIKET
const String KEY_TICKET = 'TICKET';
const String KEY_BROKERIP = 'BROKER_ADDRESS';
const String KEY_BROKERPORT = 'BROKER_PORT';

const String SECURE_STORAGE_KEY1 = 'HIVE_ENCYPTED_KEY1';
const String SECURE_STORAGE_KEY2 = 'HIVE_ENCYPTED_KEY2';

const String SECURE_STORAGE_TOKEN_KEY = 'SECURE_STORAGE_TOKEN_KEY';

// const FlutterSecureStorage secureStorage1 = FlutterSecureStorage();

class Storage {
  late StorageDriver _storage;

  var tokenBox;

//MAKE SINGLETON
  static final Storage _singleton = Storage._internal();
  factory Storage() {
    return _singleton;
  }
  //In java
  // static Storage getInstance() {
  //   return _singleton;
  // }
  Storage._internal();
  //END OF SINGLETON

  Future<void> init() async {
    // WidgetsFlutterBinding.ensureInitialized();
    _storage = HiveStorage();
    await _storage.init();
    Hive.registerAdapter(PhoneNumbersHistoryAdapter());

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    bool containsEncryptionKey = await secureStorage.containsKey(key: SECURE_STORAGE_TOKEN_KEY);

    List<int> hiveSecureKey;

    if (!containsEncryptionKey) {
      var newHiveSecureKey = Hive.generateSecureKey();
      hiveSecureKey = newHiveSecureKey;
      await secureStorage.write(key: SECURE_STORAGE_TOKEN_KEY, value: json.encode(newHiveSecureKey));
    } else {
      var initialSecureStorageKey = await secureStorage.read(key: SECURE_STORAGE_TOKEN_KEY);
      hiveSecureKey = (json.decode(initialSecureStorageKey!) as List<dynamic>).cast<int>();
    }
    tokenBox = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX, encryptionCipher: HiveAesCipher(hiveSecureKey));

    await Hive.openBox(
      KEY_HIVE_SECURE_TOKEN_BOX,
    );

    // _storage = SqliteStorage();
    // _storage = SharedPreferenceStorage();
  }

  Future storeServerCFG({required String ip, required String port}) async {
    await tokenBox.put(SERVER_IP, ip);
    await tokenBox.put(SERVER_PORT, port);
  }

  Future<Map<String, dynamic>> getServerCFG() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? ip = await tokenBox.get(SERVER_IP);
    String? port = await tokenBox.get(SERVER_PORT);

    if (ip != null && port != null) {
      return {
        'ip': ip,
        'port': port,
      };
    } else {
      return {'ip': null, 'port': null};
    }
  }

  Future storePinCode({required String pinCode, required bool fingerPrintEn}) async {
    await tokenBox.put(APP_PINCODE, pinCode);
    await tokenBox.put(APP_FINGEREN, fingerPrintEn);
  }

  Future<Map<String, dynamic>> getPinCode() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? pinCode = await tokenBox.get(APP_PINCODE);
    bool? fingerPrintEn = await tokenBox.get(APP_FINGEREN);

    if (pinCode != null) {
      return {
        'pinCode': pinCode,
        'fingerPrintEn': fingerPrintEn,
      };
    } else {
      return {'pinCode': null, 'fingerPrintEn': false};
    }
  }

  Future storePhoneNumbers({
    required PhoneNumbersHistory phoneNumbers,
  }) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));
    await tokenBox.put(PHONE_NUMBERS, phoneNumbers);
  }

  Future<PhoneNumbersHistory?> getPhoneNumbers() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    PhoneNumbersHistory? phoneNumbers = await tokenBox.get(PHONE_NUMBERS);

    if (phoneNumbers != null) {
      return phoneNumbers;
    } else {
      return null;
    }
  }

  Future storeTokens({required String accessToken, required String refreshToken, required int expirtyMillis}) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    await tokenBox.put(KEY_ACCESSTOKENT, accessToken);
    await tokenBox.put(KEY_REFERESHTOKENT, refreshToken);
    await tokenBox.put(KEY_EXPIRTY_MILLIS, expirtyMillis);
  }

  Future<Map<String, dynamic>> getTokens() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? accessToken = await tokenBox.get(KEY_ACCESSTOKENT);
    String? refreshToken = await tokenBox.get(KEY_REFERESHTOKENT);
    int? expirtyMillis = await tokenBox.get(KEY_EXPIRTY_MILLIS);
    // _encryptedBox1.close();
    // print(accessToken);
    // print(refreshToken);

    if (accessToken != null && refreshToken != null) {
      return {'accessToken': accessToken, 'refreshToken': refreshToken, 'expirtyMillis': expirtyMillis};
    } else {
      return {'accessToken': null, 'refreshToken': null, 'expirtyMillis': null};
    }
  }

  Future<void> storeRoom({
    required String room,
  }) async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_ROOM, room);
  }

  Future<String?> getRoom() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? room = await tokenBox.get(KEY_ROOM);

    if (room != null) {
      return room;
    }
    return null;
  }

  Future<void> storeUser({
    required String userName,
    required String passWord,
  }) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_USERNAME, userName);
    await tokenBox.put(KEY_PASSWORD, passWord);
  }

  Future<User?> getUser() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? userName = await tokenBox.get(KEY_USERNAME);
    String? passWord = await tokenBox.get(KEY_PASSWORD);

    if (userName != null && passWord != null) {
      return User(userName: userName, passWord: passWord);
    }
    return null;
  }

  Future<void> storeDevice({
    required String deviceId,
    required String localId,
    required String serial,
    required String secret,
  }) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_DEV_ID, deviceId);
    await tokenBox.put(KEY_LOCAL, localId);
    await tokenBox.put(KEY_SERIAL, serial);
    await tokenBox.put(KEY_SECRET, secret);
  }

  Future<d.Device?> getDevice() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? deviceId = await tokenBox.get(KEY_DEV_ID);
    String? localId = await tokenBox.get(KEY_LOCAL);
    String? serial = await tokenBox.get(KEY_SERIAL);
    String? secret = await tokenBox.get(KEY_SECRET);

    if (deviceId != null && localId != null && serial != null && secret != null) {
      return d.Device(deviceId: deviceId, localId: localId, secret: secret, serial: serial);
    }
    return null;
  }

  Future<void> storeTicket({required String ticket, required String brokerIp, required String brokerPort}) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_TICKET, ticket);
    await tokenBox.put(KEY_BROKERIP, brokerIp);
    await tokenBox.put(KEY_BROKERPORT, brokerPort);
  }

  Future<BrokerTicket?> getTicket() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? ticket = await tokenBox.get(KEY_TICKET);
    String? brokerIp = await tokenBox.get(KEY_BROKERIP);
    String? brokerPort = await tokenBox.get(KEY_BROKERPORT);
    // _encryptedBox1.close();
    // print(accessToken);
    // print(refreshToken);
    var port = brokerPort != null ? int.tryParse(brokerPort) : null;

    if (ticket != null && brokerIp != null && port != null) {
      return BrokerTicket(ticket, brokerIp, port);
    }
    return null;
  }

  Future storeProfile({required String firstName, required String lastName, required String id, required String section}) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_FIRSTNAME, firstName);
    await tokenBox.put(KEY_LASTNAME, lastName);
    await tokenBox.put(KEY_ID, id);
    await tokenBox.put(KEY_SECTION, section);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? firstName = await tokenBox.get(KEY_FIRSTNAME);
    String? lastName = await tokenBox.get(KEY_LASTNAME);
    String? id = await tokenBox.get(KEY_ID);
    String? section = await tokenBox.get(KEY_SECTION);

    if (firstName != null && lastName != null && id != null && section != null) {
      return {
        'first_name': firstName,
        'last_name': lastName,
        'section_id': section,
        'user_id': id,
      };
    } else {
      return {'first_name': null, 'last_name': null, 'section_id': null, 'user_id': null};
    }
  }

  Future storeSection({required String sectionId, required String title, required String desc}) async {
    // final encryptedBox1 = await Hive.openBox(KEY_HIVE_SECURE_TOKEN_BOX,
    //     encryptionCipher: HiveAesCipher(secureKey1));

    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.put(KEY_SECTIONID, sectionId);
    await tokenBox.put(KEY_TITLE, title);
    await tokenBox.put(KEY_DESC, desc);
  }

  Future<Map<String, dynamic>> getSection() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    String? sectionId = await tokenBox.get(KEY_SECTIONID);
    String? title = await tokenBox.get(KEY_TITLE);
    String? desc = await tokenBox.get(KEY_DESC);
    // _encryptedBox1.close();
    // print(accessToken);
    // print(refreshToken);

    if (sectionId != null && title != null && desc != null) {
      return {'section_id': sectionId, 'title': title, 'desc': desc};
    } else {
      return {'section_id': null, 'title': null, 'desc': null};
    }
  }

  Future<void> clearUser() async {
    final tokenBox = Hive.box(KEY_HIVE_SECURE_TOKEN_BOX);
    await tokenBox.clear();
    // await _storage.clear();
  }
}
