import 'package:equatable/equatable.dart';

abstract class PlayerVsBotEvent extends Equatable {
  const PlayerVsBotEvent();
  @override
  List<Object?> get props => [];
}

class ScreenOpened extends PlayerVsBotEvent {}

class NewGameRequested extends PlayerVsBotEvent {}

class SquareTapped extends PlayerVsBotEvent {
  final int index; // 0..63
  const SquareTapped(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitPlayerMove extends PlayerVsBotEvent {}

class BotMoveArrived extends PlayerVsBotEvent {
  final int from;
  final int to;
  final String? fen;
  const BotMoveArrived({required this.from, required this.to, this.fen});
  @override
  List<Object?> get props => [from, to, fen];
}

class ErrorOccurred extends PlayerVsBotEvent {
  final String message;
  const ErrorOccurred(this.message);
}

class UpdatePlayerTime extends PlayerVsBotEvent {
  final int seconds;
  const UpdatePlayerTime(this.seconds);
}

class UpdateBotTime extends PlayerVsBotEvent {
  final int seconds;
  const UpdateBotTime(this.seconds);
}
