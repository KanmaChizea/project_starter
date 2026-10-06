import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/auth_service.dart';
import '../models/login_ui_state.dart';
import '../widgets/login_form.dart';
import 'login_view_model.dart';

/// Route-level page. Creates its [LoginViewModel], so the view model lives
/// exactly as long as this route.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginViewModel(authService: context.read<AuthService>()),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<LoginViewModel, LoginUiState>(
                    builder: (context, state) => LoginForm(
                      state: state,
                      onEmailChanged: viewModel.onEmailChanged,
                      onPasswordChanged: viewModel.onPasswordChanged,
                      onSubmit: viewModel.submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
