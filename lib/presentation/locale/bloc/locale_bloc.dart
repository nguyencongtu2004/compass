import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/data/services/locale_service.dart';

part 'locale_event.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final LocaleService _localeService;

  LocaleBloc({required LocaleService localeService})
    : _localeService = localeService,
      super(LocaleInitial()) {
    on<LocaleInitialized>(_onLocaleInitialized);
    on<LocaleChanged>(_onLocaleChanged);
  }

  void _onLocaleInitialized(
    LocaleInitialized event,
    Emitter<LocaleState> emit,
  ) {
    try {
      final savedLocale = _localeService.getSavedLocale();
      emit(LocaleLoaded(savedLocale));
    } catch (e) {
      emit(LocaleError('Failed to load locale: ${e.toString()}'));
    }
  }

  void _onLocaleChanged(LocaleChanged event, Emitter<LocaleState> emit) async {
    try {
      if (_localeService.isSupported(event.locale)) {
        await _localeService.saveLocale(event.locale);
        emit(LocaleLoaded(event.locale));
      } else {
        emit(
          LocaleError('Locale ${event.locale.languageCode} is not supported'),
        );
      }
    } catch (e) {
      emit(LocaleError('Failed to change locale: ${e.toString()}'));
    }
  }

  /// Convenience method to change language by language code
  void changeLanguage(String languageCode) {
    final locale = LocaleService.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => LocaleService.fallbackLocale,
    );
    add(LocaleChanged(locale));
  }

  /// Get display name for a locale
  String getLocaleName(Locale locale) {
    return _localeService.getLocaleName(locale);
  }

  /// Get list of supported locales
  List<Locale> get supportedLocales => LocaleService.supportedLocales;
}
