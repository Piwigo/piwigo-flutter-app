import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piwigo_ng/core/data/datasources/remote/api_client.dart';
import 'package:piwigo_ng/core/network/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> init() async {
  // Core
  serviceLocator
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(serviceLocator()))
    ..registerLazySingleton(() => Connectivity())
    ..registerLazySingleton(() => ApiClient())
    ..registerLazySingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance())
    ..registerLazySingletonAsync<PackageInfo>(() => PackageInfo.fromPlatform());

  await serviceLocator.isReady<SharedPreferences>();
  await serviceLocator.isReady<PackageInfo>();
}
