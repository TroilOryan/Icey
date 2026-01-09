part of 'page.dart';

final state = AboutState();

Future onInit() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  state.version.value = packageInfo.version;
}
