import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:learn_english_app/core/database/content_database.dart';
import 'package:learn_english_app/core/database/user_database.dart';
import 'package:learn_english_app/core/localization/content_localizer.dart';
import 'package:learn_english_app/core/localization/content_localizer_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

@module
abstract class ServiceModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

@module
abstract class DatabaseModule {
  @preResolve
  @singleton
  @Named('content')
  Future<Database> get contentDatabase => ContentDatabase.initDatabase();

  @preResolve
  @singleton
  @Named('user')
  Future<Database> get userDatabase => UserDatabase.open();
}

@module
abstract class LocalizationModule {
  /// Exposes the [ContentLocalizer] singleton for DI injection in tests and
  /// future usecases. The singleton is *initialised* by calling
  /// [ContentLocalizerImpl.instance.bind] in `main._initializeServices()`,
  /// not here — mirroring the [AppVoicePreferences] pattern.
  @singleton
  ContentLocalizer get contentLocalizer => ContentLocalizerImpl.instance;
}
