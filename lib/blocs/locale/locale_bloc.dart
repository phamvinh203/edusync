import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'locale';

  LocaleBloc() : super(const LocaleState()) {
    on<LocaleLoaded>(_onLocaleLoaded);
    on<LocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onLocaleLoaded(
    LocaleLoaded event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'vi';
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }
}
