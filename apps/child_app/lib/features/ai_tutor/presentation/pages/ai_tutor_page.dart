import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:child_app/features/ai_tutor/providers/ai_tutor_providers.dart';
import '../../launcher/providers/launcher_providers.dart' as launcher;

class AiTutorPage extends ConsumerStatefulWidget {
  const AiTutorPage({super.key});

  @override
  ConsumerState<AiTutorPage> createState() => _AiTutorPageState();
}

class _AiTutorPageState extends ConsumerState<AiTutorPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedTheme = '🐾 Binatang';

  static const _themes = ['🐾 Binatang', '🌊 Petualangan', '🔬 Sains', '🏡 Keluarga'];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tierAsync = ref.watch(aiTutorTierGateProvider);
    final childAsync = ref.watch(launcher.currentChildProvider);

    return tierAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('AI Tutor')),
        body: Center(child: Text('Gagal memuat: $e')),
      ),
      data: (allowed) {
        if (!allowed) {
          return Scaffold(
            appBar: AppBar(title: const Text('AI Tutor')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Tutor hanya untuk Premium',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minta orang tua upgrade ke Premium',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }
        final child = childAsync.valueOrNull;
        final isYoungChild = child != null &&
            (child.ageGroup == AgeGroup.earlyChildhood ||
                child.ageGroup == AgeGroup.primary);
        return _buildTutorUi(context, cs, isYoungChild: isYoungChild);
      },
    );
  }

  Widget _buildTutorUi(BuildContext context, ColorScheme cs, {required bool isYoungChild}) {
    final tutorAsync = ref.watch(aiTutorProvider);

    final messages = tutorAsync.whenOrNull(data: (tutor) => tutor.messages) ?? [];

    final appBarTitle = isYoungChild ? 'Cerita Bareng 🤖' : 'AI Tutor';
    final hintText = isYoungChild
        ? 'Aku akan cerita cerita seru! Ketik tema yang kamu mau ya!'
        : 'Aku akan memberi petunjuk, bukan langsung jawab ya! Supaya kamu makin pintar 😊';

    return Scaffold(
      appBar: AppBar(
        title: isYoungChild
            ? Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF9B59B6),
                    child: const Text('🤖', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cerita Bareng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(
                        'Online',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
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
                      Text(
                        'Online',
                        style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                      ),
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
            padding: EdgeInsets.all(isYoungChild ? 16 : 12),
            decoration: BoxDecoration(
              color: isYoungChild ? const Color(0xFFFDE8F0) : cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: isYoungChild ? const Color(0xFFE91E63) : cs.primary,
                  size: isYoungChild ? 24 : 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hintText,
                    style: TextStyle(
                      fontSize: isYoungChild ? 15 : 13,
                      fontWeight: isYoungChild ? FontWeight.w600 : FontWeight.normal,
                      color: isYoungChild ? const Color(0xFF880E4F) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Theme picker for young children
          if (isYoungChild) ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _themes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final theme = _themes[i];
                  final selected = theme == _selectedTheme;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = theme),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF9B59B6) : const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(20),
                        border: selected ? null : Border.all(color: const Color(0xFFCE93D8), width: 1),
                      ),
                      child: Text(
                        theme,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF7B1FA2),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isYoungChild ? '🌟' : '🤖', style: TextStyle(fontSize: isYoungChild ? 72 : 64)),
                        const SizedBox(height: 16),
                        Text(
                          isYoungChild ? 'Halo! Aku Growly 🌱' : 'Halo! Aku Growly AI Tutor 🌱',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isYoungChild ? 22 : 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isYoungChild ? 'Mau cerita tentang apa hari ini?' : 'Mau tanya apa hari ini?',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: isYoungChild ? 16 : 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: isYoungChild ? 12 : 16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[i];
                      return _ChatBubble(
                        text: msg.content,
                        isAI: msg.isAI,
                        isYoungChild: isYoungChild,
                      );
                    },
                  ),
          ),
          // Typing indicator
          tutorAsync.whenOrNull(
                data: (tutor) => tutor.isLoading ? _TypingIndicator(isYoungChild: isYoungChild) : null,
              ) ??
              const SizedBox.shrink(),
          // Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(fontSize: isYoungChild ? 17 : 15),
                    decoration: InputDecoration(
                      hintText: isYoungChild ? 'Ketik tema cerita...' : 'Ketik pertanyaanmu...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isYoungChild ? 28 : 24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isYoungChild ? 22 : 20,
                        vertical: isYoungChild ? 16 : 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: tutorAsync.valueOrNull?.isLoading == true ? null : _send,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(isYoungChild ? 56 : 52, isYoungChild ? 56 : 52),
                    shape: const CircleBorder(),
                    backgroundColor: isYoungChild ? const Color(0xFF9B59B6) : null,
                  ),
                  child: Icon(Icons.send_rounded, size: isYoungChild ? 26 : 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _scrollToBottom();

    // Determine mode based on child age group
    final child = ref.read(launcher.currentChildProvider).valueOrNull;
    final isYoungChild = child != null &&
        (child.ageGroup == AgeGroup.earlyChildhood || child.ageGroup == AgeGroup.primary);
    final mode = isYoungChild ? 'story' : 'general';

    // Prepend theme for young children
    final messageText = isYoungChild && _selectedTheme.isNotEmpty
        ? '${_selectedTheme.replaceAll(RegExp(r'[^\w\s]'), '')}: $text'
        : text;

    await ref.read(aiTutorProvider.notifier).sendMessage(messageText, mode: mode);
    _scrollToBottom();
  }
}

class _TypingIndicator extends StatelessWidget {
  final bool isYoungChild;
  const _TypingIndicator({required this.isYoungChild});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bubbleColor = isYoungChild ? const Color(0xFFF3E5F5) : cs.primaryContainer;
    final textColor = isYoungChild ? const Color(0xFF7B1FA2) : cs.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isYoungChild ? 'Growly sedang bercerita' : 'Growly sedang mengetik',
                style: TextStyle(color: textColor, fontSize: isYoungChild ? 14 : 13),
              ),
              const SizedBox(width: 8),
              _Dot(),
              _Dot(delay: 1),
              _Dot(delay: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay * 200), () {
      if (mounted) _ctrl.forward();
    });
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade600
        : Colors.grey.shade400;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.5 + 0.5 * _anim.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isAI;
  final bool isYoungChild;

  const _ChatBubble({
    required this.text,
    required this.isAI,
    this.isYoungChild = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bubbleColor = isYoungChild
        ? (isAI ? const Color(0xFFF8E8FF) : const Color(0xFF9B59B6))
        : (isAI ? cs.primaryContainer : cs.primary);

    final textColor = isYoungChild
        ? (isAI ? const Color(0xFF4A148C) : Colors.white)
        : (isAI ? cs.onPrimaryContainer : cs.onPrimary);

    final fontSize = isYoungChild ? (isAI ? 17 : 16) : 15;
    final borderRadius = isYoungChild
        ? BorderRadius.circular(20)
        : (isAI
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ));

    final bubblePadding = isYoungChild
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isYoungChild ? 7 : 6),
        padding: bubblePadding,
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (isYoungChild ? 0.82 : 0.75)),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          boxShadow: isYoungChild && isAI
              ? [BoxShadow(color: const Color(0xFFCE93D8).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}