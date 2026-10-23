import 'package:flutter/material.dart';
import '../auth/account.dart';
import '../orders/order.dart';
import '../orders/order_store.dart';
import 'shared.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _farm = TextEditingController();
  final _region = TextEditingController();
  bool _register = false, _busy = false, _obscure = true;
  AccountRole _role = AccountRole.buyer;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _password,
      _confirmation,
      _farm,
      _region,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalid.first.context,
        duration: const Duration(milliseconds: 200),
        alignment: 0.1,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = OrderScope.of(context);
      if (_register) {
        await store.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          role: _role,
          farmName: _farm.text,
          region: _region.text,
        );
      } else {
        await store.signIn(_email.text, _password.text);
      }
    } on OrderException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(
    String key,
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: Key(key),
      controller: controller,
      enabled: !_busy,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(labelText: label),
      textInputAction: TextInputAction.next,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final store = OrderScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          color: Color(0xFFBBDD9C),
                          size: 32,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'farmdirect',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Closer to the farm.\nClearer on the price.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Buy directly. Grow your business.',
                          style: TextStyle(
                            color: Color(0xFFBED2C9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    _register ? 'Create your account' : 'Welcome back',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Local prototype · use sample details and a demo password. Accounts stay on this device. Sign in again after restarting.',
                    style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                  ),
                  if (store.loadFailed)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Saved data could not be loaded. This session will not overwrite it.',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                  const SizedBox(height: 22),
                  Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_register) ...[
                          _field('auth-name', 'Your name', _name, nameError),
                          const Text(
                            'I want to',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final role in [
                                AccountRole.buyer,
                                AccountRole.farmer,
                              ])
                                ChoiceChip(
                                  key: Key('register-${role.name}'),
                                  label: Text(
                                    role == AccountRole.buyer
                                        ? 'Buy produce'
                                        : 'Sell as a farmer',
                                  ),
                                  selected: _role == role,
                                  onSelected: _busy
                                      ? null
                                      : (_) => setState(() {
                                          _role = role;
                                          _error = null;
                                        }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_role == AccountRole.farmer) ...[
                            _field(
                              'auth-farm',
                              'Farm name',
                              _farm,
                              (v) =>
                                  (v?.trim().length ?? 0) < 2 ||
                                      v!.trim().length > 80
                                  ? 'Use 2–80 characters.'
                                  : null,
                            ),
                            _field(
                              'auth-region',
                              'Farm region',
                              _region,
                              (v) =>
                                  (v?.trim().length ?? 0) < 2 ||
                                      v!.trim().length > 100
                                  ? 'Use 2–100 characters.'
                                  : null,
                            ),
                          ],
                        ],
                        _field(
                          'auth-email',
                          'Email',
                          _email,
                          emailError,
                          keyboard: TextInputType.emailAddress,
                        ),
                        TextFormField(
                          key: const Key('auth-password'),
                          controller: _password,
                          enabled: !_busy,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: _register
                              ? passwordError
                              : (v) => v == null || v.isEmpty
                                    ? 'Enter your password.'
                                    : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (_) {
                            if (!_busy) _submit();
                          },
                        ),
                        if (_register)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFormField(
                              key: const Key('auth-confirm-password'),
                              controller: _confirmation,
                              enabled: !_busy,
                              obscureText: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                labelText: 'Confirm password',
                              ),
                              validator: (v) =>
                                  v != _password.text || v!.isEmpty
                                  ? 'Passwords must match.'
                                  : null,
                            ),
                          ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                _error!,
                                key: const Key('auth-error'),
                                style: const TextStyle(
                                  color: Color(0xFFAA3030),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 22),
                        FilledButton(
                          key: const Key('auth-submit'),
                          onPressed: _busy ? null : _submit,
                          child: Text(
                            _busy
                                ? 'Please wait…'
                                : _register
                                ? 'Create account'
                                : 'Sign in',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          key: const Key('auth-toggle'),
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _register = !_register;
                                  _error = null;
                                  _password.clear();
                                  _confirmation.clear();
                                  _form.currentState?.reset();
                                }),
                          child: Text(
                            _register
                                ? 'Already registered? Sign in'
                                : 'New here? Create an account',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_register) ...[
                    const SizedBox(height: 10),
                    ExpansionTile(
                      key: const Key('demo-accounts'),
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Try a demo account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Buyer, farmer or administrator',
                        style: TextStyle(fontSize: 12),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: SelectableText(
                            'Shared demo password: FarmDemo2026!',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ),
                        for (final account in demoAccounts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(account.name),
                            subtitle: Text(
                              '${account.role.label} · ${account.email}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_outward, size: 18),
                            onTap: _busy
                                ? null
                                : () => setState(() {
                                    _email.text = account.email;
                                    _password.text = demoPassword;
                                    _error = null;
                                  }),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
