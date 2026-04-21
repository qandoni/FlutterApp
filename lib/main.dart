import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/providers/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrentUserProvider(),
      child: MaterialApp(
        title: 'Складской учет',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: AuthScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
