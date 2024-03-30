import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/features/settings/domain/usecases/get_user_theme_mode_use_case.dart';

part 'current_theme_bloc.freezed.dart';

class CurrentThemeBloc extends Bloc<CurrentThemeEvent, CurrentThemeState> with AppPreferencesMixin {
  CurrentThemeBloc() : super(const CurrentThemeState(mode: ThemeMode.system)) {
    on<InitThemeEvent>(_onInitTheme);
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  final GetUserThemeModeUseCase _getUserThemeModeUseCase = const GetUserThemeModeUseCase();

  Future<void> _onInitTheme(
    InitThemeEvent event,
    Emitter<CurrentThemeState> emit,
  ) async {
    ThemeMode mode = _getUserThemeModeUseCase.execute();
    emit(CurrentThemeState(mode: mode));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<CurrentThemeState> emit,
  ) async {
    emit(CurrentThemeState(mode: event.mode));
  }
}

class CurrentThemeEvent extends Equatable {
  const CurrentThemeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class InitThemeEvent extends CurrentThemeEvent {}

class ChangeThemeEvent extends CurrentThemeEvent {
  const ChangeThemeEvent({required this.mode});

  final ThemeMode mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

@freezed
class CurrentThemeState with _$CurrentThemeState {
  const factory CurrentThemeState({
    required ThemeMode mode,
  }) = _CurrentThemeState;
}
