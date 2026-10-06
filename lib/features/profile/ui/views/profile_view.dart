import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_starter/core/session/session_cubit.dart';
import 'package:project_starter/features/auth/data/services/auth_service.dart';
import 'package:project_starter/provider.dart';

import '../../data/services/profile_service.dart';
import '../models/profile_ui_state.dart';
import 'profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileViewModel(profileService: context.read<ProfileService>()),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final user = context.select((SessionCubit session) => session.state.user);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileViewModel, ProfileUiState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user?.displayName ?? 'Signed in as'),
                subtitle: Text(user?.email ?? ''),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () => _signOut(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signOut(BuildContext context) {
    final authService = context.read<AuthService>();
    authService.signOut();
    unawaited(AppProvider.clearAll(context));
  }
}
