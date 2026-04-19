import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'core/error/exception_mapper.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'features/download_video/data/datasources/download_remote_datasource.dart';
import 'features/download_video/data/datasources/resolve_remote_datasource.dart';
import 'features/download_video/data/repositories/download_repository_impl.dart';
import 'features/download_video/domain/repositories/download_repository.dart';
import 'features/download_video/domain/usecases/download_video_usecase.dart';
import 'features/download_video/domain/usecases/resolve_video_usecase.dart';
import 'features/download_video/presentation/bloc/download_bloc.dart';
import 'features/downloads_library/data/datasources/library_local_datasource.dart';
import 'features/downloads_library/data/repositories/library_repository_impl.dart';
import 'features/downloads_library/domain/repositories/library_repository.dart';
import 'features/downloads_library/domain/usecases/delete_download_usecase.dart';
import 'features/downloads_library/domain/usecases/get_downloads_usecase.dart';
import 'features/downloads_library/domain/usecases/share_download_usecase.dart';
import 'features/downloads_library/presentation/bloc/library_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Externals
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Uuid>(() => const Uuid());

  // Core
  sl.registerLazySingleton<DioExceptionMapper>(
    () => const DioExceptionMapper(),
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient.create(mapper: sl<DioExceptionMapper>()),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Data sources
  sl.registerLazySingleton<ResolveRemoteDataSource>(
    () => ResolveRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<DownloadRemoteDataSource>(
    () => DownloadRemoteDataSourceImpl(sl<DioClient>().raw),
  );
  sl.registerLazySingleton<LibraryLocalDataSource>(
    () => LibraryLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  // Repositories
  sl.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      resolveDataSource: sl<ResolveRemoteDataSource>(),
      downloadDataSource: sl<DownloadRemoteDataSource>(),
      libraryDataSource: sl<LibraryLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      uuid: sl<Uuid>(),
    ),
  );
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(sl<LibraryLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => ResolveVideoUseCase(sl<DownloadRepository>()));
  sl.registerLazySingleton(
    () => DownloadVideoUseCase(sl<DownloadRepository>()),
  );
  sl.registerLazySingleton(() => GetDownloadsUseCase(sl<LibraryRepository>()));
  sl.registerLazySingleton(
    () => DeleteDownloadUseCase(sl<LibraryRepository>()),
  );
  sl.registerLazySingleton(() => ShareDownloadUseCase(sl<LibraryRepository>()));

  // BLoCs
  sl.registerFactory<DownloadBloc>(
    () => DownloadBloc(
      resolveVideo: sl<ResolveVideoUseCase>(),
      downloadVideo: sl<DownloadVideoUseCase>(),
    ),
  );
  sl.registerFactory<LibraryBloc>(
    () => LibraryBloc(
      getDownloads: sl<GetDownloadsUseCase>(),
      deleteDownload: sl<DeleteDownloadUseCase>(),
      shareDownload: sl<ShareDownloadUseCase>(),
    ),
  );
  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(sl<SharedPreferences>()),
  );
}
