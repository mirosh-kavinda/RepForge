import 'package:repforge/features/logger/domain/rest_alarm.dart';

class FakeRestAlarm implements RestAlarm {
  FakeRestAlarm({this.granted = true, this.allowOnRequest = true});

  bool granted;
  bool allowOnRequest;
  var requests = 0;
  var settingsOpened = 0;
  ({DateTime at, String title, String body})? scheduled;

  @override
  Future<bool> allowed() async => granted;

  @override
  Future<bool> request() async {
    requests++;
    granted = allowOnRequest;
    return granted;
  }

  @override
  Future<void> schedule(
    DateTime at, {
    required String title,
    required String body,
  }) async => scheduled = (at: at, title: title, body: body);

  @override
  Future<void> cancel() async => scheduled = null;

  @override
  Future<void> openSettings() async => settingsOpened++;
}
