import 'package:flutter/material.dart';

import '../models/login_ui_state.dart';
import 'auth_submit_button.dart';
import 'auth_text_field.dart';

/// Email/password form. Stateless: renders [state] and reports user input.
class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.state,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
  });

  final LoginUiState state;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Email',
            onChanged: onEmailChanged,
            enabled: !state.isSubmitting,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            onChanged: onPasswordChanged,
            enabled: !state.isSubmitting,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => onSubmit(),
          ),
          if (state.errorMessage case final message?) ...[
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 24),
          AuthSubmitButton(
            label: 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: state.canSubmit ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}
