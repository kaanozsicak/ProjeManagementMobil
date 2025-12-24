import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

/// Screen for joining a workspace via invite code
class JoinWorkspaceScreen extends ConsumerStatefulWidget {
  const JoinWorkspaceScreen({super.key});

  @override
  ConsumerState<JoinWorkspaceScreen> createState() =>
      _JoinWorkspaceScreenState();
}

class _JoinWorkspaceScreenState extends ConsumerState<JoinWorkspaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteController = TextEditingController();

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _joinWorkspace() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(joinWorkspaceProvider.notifier)
        .joinWithInvite(_inviteController.text.trim());

    if (success && mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final state = ref.read(joinWorkspaceProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Katılım Başarılı!'),
          ],
        ),
        content: Text(
          '"${state.joinedWorkspace?.name}" workspace\'ine başarıyla katıldınız.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(joinWorkspaceProvider.notifier).reset();
              ref.read(workspaceListProvider.notifier).loadWorkspaces();
              context.go('/workspaces');
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(joinWorkspaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace\'e Katıl'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.group_add,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Bir workspace\'e katılmak için davet kodunu veya linkini yapıştırın.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Invite code input
              TextFormField(
                controller: _inviteController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Davet Kodu',
                  hintText: 'Örn: abc123:XYZ789 veya link yapıştırın',
                  prefixIcon: Icon(Icons.link),
                  helperText: 'Davet kodu veya linki yapıştırın',
                ),
                maxLines: 2,
                minLines: 1,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir davet kodu girin';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _joinWorkspace(),
              ),
              const SizedBox(height: 24),

              // Error message
              if (state.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getErrorIcon(state.result),
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Already member info
              if (state.result == JoinResult.alreadyMember &&
                  state.joinedWorkspace != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workspace: ${state.joinedWorkspace!.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(joinWorkspaceProvider.notifier).reset();
                          context.go(
                            '/workspace/${state.joinedWorkspace!.id}',
                          );
                        },
                        child: const Text('Workspace\'e Git'),
                      ),
                    ],
                  ),
                ),

              // Join button
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : _joinWorkspace,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(state.isLoading ? 'Katılınıyor...' : 'Katıl'),
              ),

              const Spacer(),

              // Help text
              Text(
                'Davet kodu formatları:\n'
                '• workspaceId:token\n'
                '• kimne://join?workspace=XXX&token=YYY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon(JoinResult? result) {
    switch (result) {
      case JoinResult.expired:
        return Icons.access_time;
      case JoinResult.maxUses:
        return Icons.group_off;
      case JoinResult.alreadyMember:
        return Icons.info;
      case JoinResult.invalidCode:
      default:
        return Icons.error;
    }
  }
}
