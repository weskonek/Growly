import 'package:flutter/material.dart';

class AiTutorPage extends StatefulWidget {
  const AiTutorPage({super.key});

  @override
  State<AiTutorPage> createState() => _AiTutorPageState();
}

class _AiTutorPageState extends State<AiTutorPage> {
  final _controller = TextEditingController();
  final _messages = <_Message>[
    _Message(text: 'Halo! Aku Growly AI Tutor 🌱 Aku siap bantu kamu belajar. Mau tanya apa hari ini?', isAI: true),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: const Text('🤖', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Tutor', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.green.shade600)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Hint banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: cs.primary),
                const SizedBox(width: 8),
                const Expanded(child: Text('Aku akan memberi petunjuk, bukan langsung jawab ya! Supaya kamu makin pintar 😊', style: TextStyle(fontSize: 13))),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
            ),
          ),
          // Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ketik pertanyaanmu...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sendMessage,
                  style: FilledButton.styleFrom(minimumSize: const Size(52, 52), shape: const CircleBorder()),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(text: _controller.text.trim(), isAI: false));
      // TODO: integrate with AI gateway Edge Function
      _messages.add(_Message(text: 'Pertanyaan bagus! 🌟 Coba kita pikirkan dulu... Apa yang sudah kamu tahu tentang ini?', isAI: true));
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Message {
  final String text;
  final bool isAI;
  _Message({required this.text, required this.isAI});
}

class _ChatBubble extends StatelessWidget {
  final _Message message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isAI ? cs.primaryContainer : cs.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isAI ? 4 : 16),
            bottomRight: Radius.circular(message.isAI ? 16 : 4),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isAI ? cs.onPrimaryContainer : cs.onPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
