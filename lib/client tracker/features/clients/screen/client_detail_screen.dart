import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_bloc.dart';
import '../bloc/client_event.dart';
import '../bloc/client_state.dart';
import 'package:my_app/client tracker/features/clients/widget/client_detail_widget.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';

class ClientDetailScreen extends StatefulWidget {
  final int clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ClientBloc>().add(LoadClientDetailEvent(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BlocBuilder<ClientBloc, ClientState>(
        builder: (ctx, state) {

          if (state is ClientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ClientDetailLoaded) {
            return DetailBody(state: state);
          }

          if (state is ClientError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}