import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

enum AccountRole {
  buyer('Buyer'),
  farmer('Farmer'),
  admin('Administrator');

  const AccountRole(this.label);
  final String label;
}

String? emailError(String? value) {
  final email = value?.trim() ?? '';
  return email.length > 254 ||
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? 'Enter a valid email address.'
      : null;
}

String? passwordError(String? value) =>
    value == null || value.length < 8 || value.length > 128
    ? 'Use 8–128 characters.'
    : null;

/// Local demo credentials only. Production authentication requires a server.
class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.salt,
    required this.passwordHash,
    this.farmId,
  });
  final String id, name, email, salt, passwordHash;
  final AccountRole role;
  final String? farmId;

  static const iterations = 100000;
  static final _kdf = Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
  static Future<String> hash(String password, String salt) async =>
      base64Encode(
        await (await _kdf.deriveKeyFromPassword(
          password: password,
          nonce: base64Decode(salt),
        )).extractBytes(),
      );
  static String newSalt() {
    final random = Random.secure();
    return base64Encode(List.generate(16, (_) => random.nextInt(256)));
  }

  Future<bool> verifies(String password) async {
    final candidate = base64Decode(await hash(password, salt));
    final expected = base64Decode(passwordHash);
    var difference = candidate.length ^ expected.length;
    for (var i = 0; i < expected.length; i++) {
      difference |= candidate[i] ^ expected[i];
    }
    return difference == 0;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'farmId': farmId,
    'salt': salt,
    'passwordHash': passwordHash,
    'iterations': iterations,
  };
  factory DemoAccount.fromJson(Map<String, dynamic> json) {
    final account = DemoAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: AccountRole.values.byName(json['role'] as String),
      farmId: json['farmId'] as String?,
      salt: json['salt'] as String,
      passwordHash: json['passwordHash'] as String,
    );
    if (account.id.isEmpty ||
        account.name.trim().length < 2 ||
        account.name.length > 80 ||
        emailError(account.email) != null ||
        account.email != account.email.toLowerCase().trim() ||
        base64Decode(account.salt).length != 16 ||
        base64Decode(account.passwordHash).length != 32 ||
        json['iterations'] != iterations ||
        (account.role == AccountRole.farmer
            ? account.farmId == null || account.farmId!.isEmpty
            : account.farmId != null)) {
      throw const FormatException('Invalid demo account.');
    }
    return account;
  }
}

const demoPassword = 'FarmDemo2026!';
final demoAccounts = <DemoAccount>[
  DemoAccount(
    id: 'demo-buyer',
    name: 'Demo Buyer',
    email: 'buyer@farm.demo',
    role: AccountRole.buyer,
    salt: '2E5ewNuz/FOe7+3EWzHc6w==',
    passwordHash: '8JKwS9CF6e4HQKmiWdugzkk5wS3AGDazi+mBHl4cs7Q=',
    farmId: null,
  ),
  DemoAccount(
    id: 'demo-admin',
    name: 'Demo Administrator',
    email: 'admin@farm.demo',
    role: AccountRole.admin,
    salt: 'q2+yhXE+Xf2cm8RiX0RdmQ==',
    passwordHash: 'IG7CPD0ra69hbttjmZx3UoZI0Azz31OUjN5RcvpU6Ns=',
    farmId: null,
  ),
  DemoAccount(
    id: 'demo-saryarka',
    name: 'Saryarka Farm',
    email: 'saryarka@farm.demo',
    role: AccountRole.farmer,
    salt: 'jMtxY9UFQRi1eUXXh7LWrg==',
    passwordHash: 'kTKhcOqtQhewkUzl9kH40fUmDgyaYzM9UDEIE0vq4/8=',
    farmId: 'saryarka',
  ),
  DemoAccount(
    id: 'demo-green-valley',
    name: 'Green Valley Farm',
    email: 'green-valley@farm.demo',
    role: AccountRole.farmer,
    salt: 'Fc+4kGDoGehlVELcNnqWDA==',
    passwordHash: '8nNw7pwu8tGHaDWxPQFVt0LFzwhXm8vduvNPUD2KVsE=',
    farmId: 'green-valley',
  ),
  DemoAccount(
    id: 'demo-bereke',
    name: 'Bereke Family Farm',
    email: 'bereke@farm.demo',
    role: AccountRole.farmer,
    salt: '9I98dqVtioLiEo13HMgumA==',
    passwordHash: 'JOraRbi8YFzydzD4ZUbcTB6foU67wop8dPLcc1WOvwI=',
    farmId: 'bereke',
  ),
  DemoAccount(
    id: 'demo-sunrise',
    name: 'Sunrise Farm',
    email: 'sunrise@farm.demo',
    role: AccountRole.farmer,
    salt: 'bU1fSxCWq+rSf1apx7yjsQ==',
    passwordHash: 'gddHr7Z8r9d58wA0XXOmM9apZCHZSqsyouMEmOUkRDw=',
    farmId: 'sunrise',
  ),
  DemoAccount(
    id: 'demo-alatau',
    name: 'Alatau Orchard',
    email: 'alatau@farm.demo',
    role: AccountRole.farmer,
    salt: 'my6oowjxVX0pBdxF5sS/7g==',
    passwordHash: '8DOiJHSYUjMmKArhHAydi6e1wfU75f6jcQQupO5lIJU=',
    farmId: 'alatau',
  ),
];

String farmDemoEmail(String farmId) =>
    demoAccounts.firstWhere((a) => a.farmId == farmId).email;
