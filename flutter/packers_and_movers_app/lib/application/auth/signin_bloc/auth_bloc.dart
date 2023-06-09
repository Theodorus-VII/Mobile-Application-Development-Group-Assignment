import 'package:bloc/bloc.dart';
import 'package:packers_and_movers_app/domain/models/models.dart';
import 'package:packers_and_movers_app/infrastructure/data_sources/remote_data_source/api_response.dart';
import 'package:packers_and_movers_app/infrastructure/repository/auth/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthLoading()) {
    on<AuthMoverSignUp>((event, emit) async {
      emit(MoverSigningUp(event.mover));
    });

    on<AuthDefaultEvent>((event, emit) async {
      emit(AuthLoading());
    });
    on<AuthSignIn>((event, emit) async {
      print("AUTHSIGNIN");
      try {
        ApiResponse account =
            await authRepository.signIn(event.email, event.password);
        print("account $account");
        print("AUTHENTICATED");
        emit(Authenticated(user: account.data));
      } catch (error) {
        print("unAUTHENTICATED $error");
        emit(Unauthenticated(error));
      }
    });

    on<AuthMoverSignUpSubmit>((event, emit) async {
      print("Mover SignUp");
      try {
        ApiResponse account = await authRepository.moverSignUp(event.mover);
        if (account.apiError != null) {
          throw "${account.apiError}";
        }
        emit(AuthSignUpSuccess());
      } catch (e) {
        print("signup failed here");
        emit(SignUpFailed('$e'));
      }
    });

    on<AuthUserSignUp>((event, emit) async {
      print("User signup");
      try {
        ApiResponse account = await authRepository.userSignUp(event.newUser);
        if (account.apiError != null) {
          throw "${account.apiError}";
        }
        emit(AuthSignUpSuccess());
        return;
      } catch (e) {
        print("e");
        emit(SignUpFailed('$e'));
      }
    });

    on<AuthGetUser>((event, emit) {
      // emit();
    });

    on<AuthLogoutEvent>(
      (event, emit) async {
        print("logging out");
        if (await authRepository.logout()) {
          emit(AuthLogoutSuccess());
        }
      },
    );

    on<AuthUserUpdate>(
      (event, emit) async {
        if (await authRepository.remoteDataProvider
            .updatePassword(event.password)) {
          emit(AuthUserUpdateSuccess());
        } else {
          emit(AuthUserUpdateFail());
        }
      },
    );
  }
}
