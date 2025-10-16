import 'package:get_it/get_it.dart';
import 'package:middle_paint/core/blocs/canvas_bloc/canvas_bloc.dart';
import 'package:middle_paint/core/firebase_services/authentication.dart';
import 'package:middle_paint/core/firebase_services/firestore_database.dart';
import 'package:middle_paint/core/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:middle_paint/core/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:middle_paint/core/services/image_picker_service.dart';
import 'package:middle_paint/core/services/image_saver_service.dart';
import 'package:middle_paint/core/firebase_services/storage_service.dart';
import 'package:middle_paint/core/blocs/artwork_bloc/artwork_bloc.dart';
import 'package:middle_paint/core/services/notification_service.dart';
import 'package:middle_paint/core/services/connectivity_service.dart';
import 'package:middle_paint/core/blocs/connectivity_bloc/connectivity_bloc.dart';

/// Global service locator instance using GetIt.
final sl = GetIt.instance;

/// Centralized function to register all dependencies (services and BLoCs)
/// for easy access throughout the application.
void call() {
  sl.registerLazySingleton(() => AuthenticationService());
  sl.registerLazySingleton(() => FirestoreDatabaseService());
  sl.registerLazySingleton(() => ImagePickerService());
  sl.registerLazySingleton(() => ImageSaverService());
  sl.registerLazySingleton(() => StorageService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => ConnectivityService());

  // SignUpBloc requires Authentication and Firestore services
  sl.registerFactory(() => SignUpBloc(sl(), sl()));

  // SignInBloc requires Authentication service
  sl.registerFactory(() => SignInBloc(sl()));

  // CanvasBloc requires all services for comprehensive canvas logic (save, share, load)
  sl.registerFactory(() => CanvasBloc(sl(), sl(), sl(), sl(), sl(), sl()));

  // ArtworkBloc requires Firestore, Authentication, and Storage for gallery management
  sl.registerFactory(() => ArtworkBloc(sl(), sl(), sl()));

  // ConnectivityBloc observes online/offline state
  sl.registerFactory(() => ConnectivityBloc(sl()));
}
