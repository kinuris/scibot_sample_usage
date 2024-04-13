import 'package:flutter/material.dart';
import 'package:flutter_chat/flutter_chat.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:localstorage/localstorage.dart';

class ChatAppScaffold extends StatefulWidget {
  const ChatAppScaffold({super.key});

  @override
  State<ChatAppScaffold> createState() => _ChatAppScaffoldState();
}

class _ChatAppScaffoldState extends State<ChatAppScaffold> {
  @override
  Widget build(BuildContext context) {
    final refreshKey = UniqueKey();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Sample Chat Usage"),
        actions: [
          IconButton(
            onPressed: () {
              // NOTE: This clears the chat history
              localStorage.clear();

              setState(() {});
            },
            icon: const Icon(
              Icons.refresh,
              size: 32,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ChatApp(key: refreshKey),
        ),
      ),
    );
  }
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final _messageController = TextEditingController();
  var _session = MessageSession();

  @override
  void initState() {
    super.initState();

    final history = localStorage.getItem("history");

    if (history == null) {
      _session.queueSystemMessage(
        """You are an AI Chatbot assistant of Joecil Villanueva, a grade 9 science teacher, you are very eager to educate students, you must ensure to the best of your capabilities that your answers comply with the science curriculum's Most Essential Learning Competencies (MELCs) defined by the Department of Education in the Philippines.
          You must refuse to answer questions not directly relevant to the topics in the MELCs. Greet your student, make sure to mention your creator Joecil Villanueva. You can answer questions about yourself. Do not mention that you are limited to the topics within the MELCs. List the topics in the MELCs ONLY WHEN ASKED.""",
      );

      return;
    }

    _session = MessageSession.fromJsonEncrypted(history);
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: when play() is called, it will return a Stream<String> if the last message in its history does not come from an Assistant
    final possibleResponse = _session.play();

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ..._session.history.map(
                (record) => Row(
                  mainAxisAlignment: record.role == "User"
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    record.role == "Assistant"
                        ? const Icon(Icons.face_3)
                        : const SizedBox(),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
                      constraints: const BoxConstraints(maxWidth: 250),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: record.role == "User"
                            ? Colors.blue[200]
                            : Colors.deepOrange[200],
                      ),
                      child: Text(
                        record.message,
                      ),
                    ),
                    record.role == "User"
                        ? const Icon(Icons.face)
                        : const SizedBox(),
                  ],
                ),
              ),
              possibleResponse == null
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.face_3),
                        StreamBuilder(
                          stream: possibleResponse,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                  right: 10,
                                ),
                                constraints:
                                    const BoxConstraints(maxWidth: 275),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.deepOrange[200],
                                ),
                                child: SpinKitRing(
                                  color: Colors.blue.shade300,
                                  size: 25,
                                  lineWidth: 4,
                                ),
                              );
                            }

                            return Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                                left: 10,
                                right: 10,
                              ),
                              constraints: const BoxConstraints(maxWidth: 275),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.deepOrange[200],
                              ),
                              child: Text(
                                snapshot.data!,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (_messageController.text.isEmpty) {
                  return;
                }

                setState(() {
                  _session.queueUserMessage(_messageController.text);
                  _messageController.text = "";
                });
              },
              icon: const Icon(Icons.send),
            ),
            IconButton(
              onPressed: () {
                localStorage.setItem(
                  "history",
                  _session.toJsonEncrypted(),
                );
              },
              icon: const Icon(Icons.save),
            )
          ],
        ),
      ],
    );
  }
}
