import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/download_video/presentation/bloc/download_bloc.dart';
import 'features/downloads_library/presentation/bloc/library_bloc.dart';
import 'injection_container.dart';
import 'shell/app_shell.dart';

class LuminescentVaultApp extends StatelessWidget {
  const LuminescentVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DownloadBloc>(create: (_) => sl<DownloadBloc>()),
        BlocProvider<LibraryBloc>(create: (_) => sl<LibraryBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const AppShell(),
      ),
    );
  }
}
