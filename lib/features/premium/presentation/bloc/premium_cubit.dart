import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/premium.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/premium_usecases.dart';

// States
abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumLoaded extends PremiumState {
  final Premium premium;

  const PremiumLoaded(this.premium);

  @override
  List<Object?> get props => [premium];
}

class PremiumActivated extends PremiumState {
  final Premium premium;

  const PremiumActivated(this.premium);

  @override
  List<Object?> get props => [premium];
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class PremiumCubit extends Cubit<PremiumState> {
  final PremiumRepository repository;
  late final GetPremiumUseCase getPremiumUseCase;
  late final ActivatePremiumUseCase activatePremiumUseCase;
  late final DeactivatePremiumUseCase deactivatePremiumUseCase;
  late final CancelPremiumUseCase cancelPremiumUseCase;
  late final IsPremiumActiveUseCase isPremiumActiveUseCase;

  PremiumCubit(this.repository) : super(PremiumInitial()) {
    getPremiumUseCase = GetPremiumUseCase(repository);
    activatePremiumUseCase = ActivatePremiumUseCase(repository);
    deactivatePremiumUseCase = DeactivatePremiumUseCase(repository);
    cancelPremiumUseCase = CancelPremiumUseCase(repository);
    isPremiumActiveUseCase = IsPremiumActiveUseCase(repository);
  }

  Future<void> loadPremium(String userId) async {
    emit(PremiumLoading());
    try {
      final premium = await getPremiumUseCase(userId);
      if (premium != null) {
        emit(PremiumLoaded(premium));
      } else {
        emit(PremiumLoaded(Premium(userId: userId)));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> activatePremium({
    required String userId,
    required PremiumPlan plan,
    required int durationDays,
  }) async {
    emit(PremiumLoading());
    try {
      await activatePremiumUseCase(
        userId: userId,
        plan: plan,
        durationDays: durationDays,
      );
      final premium = await getPremiumUseCase(userId);
      if (premium != null) {
        emit(PremiumActivated(premium));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> deactivatePremium(String userId) async {
    emit(PremiumLoading());
    try {
      await deactivatePremiumUseCase(userId);
      final premium = await getPremiumUseCase(userId);
      if (premium != null) {
        emit(PremiumLoaded(premium));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> cancelPremium(String userId) async {
    emit(PremiumLoading());
    try {
      await cancelPremiumUseCase(userId);
      final premium = await getPremiumUseCase(userId);
      if (premium != null) {
        emit(PremiumLoaded(premium));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<bool> isPremiumActive(String userId) async {
    return isPremiumActiveUseCase(userId);
  }
}
