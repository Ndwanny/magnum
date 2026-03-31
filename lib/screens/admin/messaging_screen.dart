import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminMessagingScreen extends StatefulWidget {
  const AdminMessagingScreen({super.key});
  @override
  State<AdminMessagingScreen> createState() => _AdminMessagingScreenState();
}

class _AdminMessagingScreenState extends State<AdminMessagingScreen> {
  int _selectedChannel = 0;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String,dynamic>> _localMessages = [];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _localMessages.add({'text': text, 'time': DateTime.now()});
      _inputCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final channels = MockDataExt.channels;
    final chan = channels[_selectedChannel];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(children: [
        if (isDesktop) const AdminSidebar(),
        Expanded(child: Column(children: [
          const AdminTopBar(title: 'Team Messaging'),
          Expanded(child: Row(children: [
            // Channel list
            Container(
              width: isDesktop ? 240 : 80,
              decoration: const BoxDecoration(
                color: AppColors.bgMid,
                border: Border(right: BorderSide(color: AppColors.divider)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isDesktop
                      ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Channels', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          IconButton(icon: const Icon(Icons.add, color: AppColors.primary, size: 18), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        ])
                      : const Icon(Icons.chat, color: AppColors.primary),
                ),
                const Divider(color: AppColors.divider, height: 1),
                ...channels.asMap().entries.map((e) {
                  final i = e.key;
                  final ch = e.value;
                  final isSelected = i == _selectedChannel;
                  return GestureDetector(
                    onTap: () => setState(() { _selectedChannel = i; _localMessages.clear(); }),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isDesktop ? 12 : 10),
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      child: Row(children: [
                        Container(
                          width: isDesktop ? 32 : 36, height: isDesktop ? 32 : 36,
                          decoration: BoxDecoration(
                            color: (ch.type == 'team' ? AppColors.primary : AppColors.info).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(ch.type == 'team' ? Icons.groups : Icons.apartment, color: ch.type == 'team' ? AppColors.primary : AppColors.info, size: 16),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(ch.name, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(ch.messages.isNotEmpty ? ch.messages.last.content : '', style: const TextStyle(color: AppColors.textMuted, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                          if (ch.unread > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                              child: Text('${ch.unread}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ]),
                    ),
                  );
                }),
              ]),
            ),
            // Message pane
            Expanded(child: Column(children: [
              // Chat header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.bgMid,
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle), child: Icon(chan.type == 'team' ? Icons.groups : Icons.apartment, color: AppColors.primary, size: 16)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(chan.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${chan.messages.length} messages', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ]),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search, color: AppColors.textMuted, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18), onPressed: () {}),
                ]),
              ),
              // Messages
              Expanded(child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: chan.messages.length + _localMessages.length,
                itemBuilder: (ctx, idx) {
                  if (idx < chan.messages.length) {
                    final msg = chan.messages[idx];
                    final isMe = msg.senderId == 'A001';
                    return _MessageBubble(senderName: msg.senderName, content: msg.content, time: msg.sentAt, isMe: isMe);
                  } else {
                    final m = _localMessages[(idx - chan.messages.length) as int];
                    return _MessageBubble(senderName: 'You', content: m['text'], time: m['time'], isMe: true);
                  }
                },
              )),
              // Input bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.bgMid,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        suffixIcon: IconButton(icon: const Icon(Icons.attach_file, color: AppColors.textMuted, size: 18), onPressed: () {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.send, color: Colors.black, size: 18),
                  ),
                ]),
              ),
            ])),
          ])),
        ])),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String senderName, content;
  final DateTime time;
  final bool isMe;
  const _MessageBubble({required this.senderName, required this.content, required this.time, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 14, backgroundColor: AppColors.info.withOpacity(0.15), child: Text(senderName[0], style: const TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(senderName, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 360),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isMe ? 14 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 14),
                    ),
                    border: Border.all(color: isMe ? AppColors.primary.withOpacity(0.3) : AppColors.cardBorder, width: 0.5),
                  ),
                  child: Text(content, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 2, right: 2),
                  child: Text(timeFmt.format(time), style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.15), child: const Text('A', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
          ],
        ],
      ),
    );
  }
}
