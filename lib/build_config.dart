class BuildConfig {
  static const int versionCode = int.fromEnvironment(
    "icey.versionCode",
    defaultValue: 1,
  );

  static const String versionName = String.fromEnvironment(
    'icey.versionName',
    defaultValue: 'SNAPSHOT',
  );

  static const int buildTime = int.fromEnvironment('icey.buildTime');

  static const String commitHash = String.fromEnvironment(
    'icey.commitHash',
    defaultValue: 'N/A',
  );
}
