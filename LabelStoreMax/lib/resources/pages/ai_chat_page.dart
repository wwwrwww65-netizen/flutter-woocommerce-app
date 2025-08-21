import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:path/path.dart' as p;

class AiChatPage extends StatefulWidget {
  static const String path = "/ai-chat";
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _sendDeviceContext = false;
  bool _sendArticleContext = true;
  StreamSubscription<String>? _streamSub;
  File? _image;

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _send() async {
    final String content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: content));
      _controller.clear();
    });

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('apiAiChat');
    try {
      final result = await callable.call(<String, dynamic>{
        'message': content,
        'sendDeviceContext': _sendDeviceContext,
        'sendArticleContext': _sendArticleContext,
        'hasImage': _image != null,
      });

      final String reply = (result.data as Map)['reply'] as String? ?? '';
      if (reply.isNotEmpty) {
        setState(() => _messages.add(_ChatMessage(role: 'assistant', content: reply)));
      }
    } catch (e) {
      setState(() => _messages.add(_ChatMessage(role: 'assistant', content: 'Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat'.tr()),
        actions: [
          IconButton(onPressed: _pickImage, icon: const Icon(Icons.image_outlined)),
          Switch.adaptive(
            value: _sendDeviceContext,
            onChanged: (v) => setState(() => _sendDeviceContext = v),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: Text('Device'.tr())),
          ),
          Switch.adaptive(
            value: _sendArticleContext,
            onChanged: (v) => setState(() => _sendArticleContext = v),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: Text('Article'.tr())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m.content,
                      style: TextStyle(color: isUser ? Colors.white : null),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: Text(p.basename(_image!.path))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _image = null),
                  )
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message'.tr(),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: Text('Send'.tr()),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  _ChatMessage({required this.role, required this.content});
}

