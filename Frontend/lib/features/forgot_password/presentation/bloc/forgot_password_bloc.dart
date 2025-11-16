import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/forgot_password_usecase.dart';

// Events
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends ForgotPasswordEvent {
  final String email;
  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class SubmitResetPassword extends ForgotPasswordEvent {
  const SubmitResetPassword();
}

// States
enum ForgotPasswordStatus { initial, loading, success, failure }

class ForgotPasswordState extends Equatable {
  final String email;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}

// Bloc
class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordBloc({
    required this.forgotPasswordUseCase,
  }) : super(const ForgotPasswordState()) {
    on<EmailChanged>(_onEmailChanged);
    on<SubmitResetPassword>(_onSubmitResetPassword);
  }

  void _onEmailChanged(EmailChanged event, Emitter<ForgotPasswordState> emit) {
    emit(state.copyWith(
      email: event.email,
      status: ForgotPasswordStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitResetPassword(
    SubmitResetPassword event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state.email.isEmpty) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Vui lòng nhập email',
      ));
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    try {
      await forgotPasswordUseCase(state.email);
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Không tìm thấy tài khoản với email này',
      ));
    }
  }
}