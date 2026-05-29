import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/core/utils/app_routes.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/core/utils/validators.dart';
import 'package:ingredio/presentation/providers/theme_mode_provider.dart';
import 'package:ingredio/presentation/providers/user_profile_provider.dart';
import 'package:ingredio/presentation/widgets/theme_mode_selector.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final name = _nameController.text.trim();
    await ref.read(userProfileProvider.notifier).register(name);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer
                                .withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Ingredio',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose how the app should look, then enter your name.',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ThemeModeSelector(
                  value: themeMode,
                  onChanged: (mode) {
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  },
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  validator: validateName,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Alex',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
