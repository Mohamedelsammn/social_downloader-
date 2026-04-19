import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_downloader/shell/splash_screen.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/download_video/presentation/bloc/download_bloc.dart';
import 'features/downloads_library/presentation/bloc/library_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'injection_container.dart';

class SocialDownloaderApp extends StatelessWidget {
  const SocialDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DownloadBloc>(create: (_) => sl<DownloadBloc>()),
        BlocProvider<LibraryBloc>(create: (_) => sl<LibraryBloc>()),
        BlocProvider<SettingsBloc>(create: (_) => sl<SettingsBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashScreen(),
      ),
    );
  }
}
