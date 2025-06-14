part of 'locale_bloc.dart';

abstract class LocaleState extends Equatable {
  const LocaleState();

  @override
  List<Object?> get props => [];
}

class LocaleInitial extends LocaleState {
  const LocaleInitial();
}

class LocaleLoading extends LocaleState {
  const LocaleLoading();
}

class LocaleLoaded extends LocaleState {
  final Locale locale;

  const LocaleLoaded(this.locale);

  @override
  List<Object?> get props => [locale];
}

class LocaleError extends LocaleState {
  final String message;

  const LocaleError(this.message);

  @override
  List<Object?> get props => [message];
}
