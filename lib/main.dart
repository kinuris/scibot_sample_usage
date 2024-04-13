import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scibot_sample/chat_app.dart';
import 'package:flutter_chat/flutter_chat.dart';
import 'package:scibot_sample/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initLocalStorage();
  initApi(Env.apiKey);

  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sample Chat",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => const ChatAppScaffold(),
              settings: const RouteSettings(name: "/"),
            );
          default:
            throw Exception("Non-existent route: ${settings.name}");
        }
      },
    );
  }
}
