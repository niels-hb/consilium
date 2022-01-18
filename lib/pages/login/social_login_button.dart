import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: implementation_imports
import 'package:firebase_auth_platform_interface/src/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../environment.dart';

class SocialLoginButton extends StatefulWidget {
  const SocialLoginButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.webAuthenticationHandler,
    required this.nativeAuthenticationHandler,
  }) : super(key: key);

  factory SocialLoginButton.google(BuildContext context) {
    return SocialLoginButton(
      icon: FontAwesomeIcons.google,
      tooltip: AppLocalizations.of(context)!.signInWithGoogle,
      webAuthenticationHandler: () => getDefaultWebAuthenticationHandlerFor(
        GoogleAuthProvider(),
      ),
      nativeAuthenticationHandler: () async {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        return FirebaseAuth.instance.signInWithCredential(credential);
      },
    );
  }

  factory SocialLoginButton.apple(BuildContext context) {
    return SocialLoginButton(
      icon: FontAwesomeIcons.apple,
      tooltip: AppLocalizations.of(context)!.signInWithApple,
      webAuthenticationHandler: () async {
        final OAuthProvider provider = OAuthProvider('apple.com')
          ..addScope('email')
          ..addScope('name');

        return FirebaseAuth.instance.signInWithPopup(provider);
      },
      nativeAuthenticationHandler: () async {
        final String rawNonce = generateNonce();
        final String nonce = sha256ofString(rawNonce);

        final AuthorizationCredentialAppleID appleCredential =
            await SignInWithApple.getAppleIDCredential(
          scopes: <AppleIDAuthorizationScopes>[
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final OAuthCredential oauthCredential =
            OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        return FirebaseAuth.instance.signInWithCredential(oauthCredential);
      },
    );
  }

  factory SocialLoginButton.github(BuildContext context) {
    return SocialLoginButton(
      icon: FontAwesomeIcons.github,
      tooltip: AppLocalizations.of(context)!.signInWithGitHub,
      webAuthenticationHandler: () => getDefaultWebAuthenticationHandlerFor(
        GithubAuthProvider(),
      ),
      nativeAuthenticationHandler: () async {
        final GitHubSignIn gitHubSignIn = GitHubSignIn(
          clientId: githubClientId,
          clientSecret: githubClientSecret,
          redirectUrl: githubRedirectUrl,
          scope: 'user:email',
        );

        final GitHubSignInResult result = await gitHubSignIn.signIn(context);

        final OAuthCredential githubAuthCredential =
            GithubAuthProvider.credential(result.token!);

        return FirebaseAuth.instance.signInWithCredential(githubAuthCredential);
      },
    );
  }

  final IconData icon;
  final String tooltip;
  final Future<UserCredential> Function() webAuthenticationHandler;
  final Future<UserCredential> Function() nativeAuthenticationHandler;

  static String generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();

    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final List<int> bytes = utf8.encode(input);
    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }

  static Future<UserCredential> getDefaultWebAuthenticationHandlerFor(
    AuthProvider authProvider,
  ) {
    return FirebaseAuth.instance.signInWithPopup(authProvider);
  }

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _active ? _startAuth : null,
      icon: Icon(widget.icon),
      tooltip: widget.tooltip,
    );
  }

  Future<void> _startAuth() async {
    setState(() {
      _active = false;
    });

    try {
      if (kIsWeb) {
        await widget.webAuthenticationHandler();
      } else {
        await widget.nativeAuthenticationHandler();
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context)!.unknownError,
          ),
        ),
      );
    } finally {
      setState(() {
        _active = true;
      });
    }
  }
}
