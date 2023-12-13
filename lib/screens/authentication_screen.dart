import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication.dart';
import '../models/http_exception.dart';

enum AuthenticationMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.5),
                  Colors.orange.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Magazin Engross',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 30,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthenticationCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthenticationCard extends StatefulWidget {
  const AuthenticationCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthenticationCardState createState() => _AuthenticationCardState();
}

class _AuthenticationCardState extends State<AuthenticationCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthenticationMode _authenticationMode = AuthenticationMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _controller as Animation<double>,
            curve: Curves.fastEaseInToSlowEaseOut));

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller as Animation<double>, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('A aparut o eroare! Incearca din nou!'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    try {
      if (_authenticationMode == AuthenticationMode.Login) {
        await Provider.of<Authentication>(context, listen: false).login(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Authentication>(context, listen: false).signUp(
            _authData['email'] as String, _authData['password'] as String);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Autentificarea nu a avut succes';

      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Adresa de email este deja folosita';
      } else if (error.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
        errorMessage = 'Date de logare incorecte';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Parola este prea slaba. Incearca mai multe caractere.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage =
            'Nu exista niciun utilizator cu adresa de email adaugata.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Parola incorecta';
      } else if (error.toString().contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
        errorMessage =
            'Accesul la acest cont este temporar inchis datorita multiplelor incercari esuate.' +
                'Incearca mai tarziu.';
      }

      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Autentificarea nu a avut succes';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthenticationMode() {
    if (_authenticationMode == AuthenticationMode.Login) {
      setState(() {
        _authenticationMode = AuthenticationMode.SignUp;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authenticationMode = AuthenticationMode.Login;
      });
      _controller!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authenticationMode == AuthenticationMode.SignUp ? 360 : 310,
          constraints: BoxConstraints(
            minHeight:
                _authenticationMode == AuthenticationMode.SignUp ? 360 : 310,
          ),
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    // ignore: body_might_complete_normally_nullable
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Email invalid';
                      }
                    },
                    onSaved: (value) {
                      _authData['email'] = value as String;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Parola'),
                    obscureText: true,
                    controller: _passwordController,
                    // ignore: body_might_complete_normally_nullable
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Parola este prea scurta';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value as String;
                    },
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight:
                            _authenticationMode == AuthenticationMode.SignUp
                                ? 60
                                : 0,
                        maxHeight:
                            _authenticationMode == AuthenticationMode.SignUp
                                ? 120
                                : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation as Animation<double>,
                      child: SlideTransition(
                        position: _slideAnimation as Animation<Offset>,
                        child: TextFormField(
                          enabled:
                              _authenticationMode == AuthenticationMode.SignUp,
                          decoration:
                              InputDecoration(labelText: 'Confirma parola'),
                          obscureText: true,
                          validator: _authenticationMode ==
                                  AuthenticationMode.SignUp
                              // ignore: body_might_complete_normally_nullable
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Parolele nu se potrivesc';
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      child: Text(
                          _authenticationMode == AuthenticationMode.Login
                              ? 'AUTENTIFICARE'
                              : 'INREGISTRARE'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  TextButton(
                    child: Text(
                        '${_authenticationMode == AuthenticationMode.Login ? 'N-ai cont? Inregistreaza-te' : 'Ai cont? Logheaza-te'}'),
                    onPressed: _switchAuthenticationMode,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 4),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
