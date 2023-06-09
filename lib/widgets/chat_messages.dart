import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return Center(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, chatSnapshots) {
            if (chatSnapshots.connectionState == ConnectionState.waiting) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
              return const Center(
                child: Text('No messages found'),
              );
            }
            if (chatSnapshots.hasError) {
              return const Center(
                child: Text('Something went wrong...'),
              );
            }
            final loadedMessages = chatSnapshots.data!.docs;
            return ListView.builder(
                padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
                reverse: true,
                itemCount: loadedMessages.length,
                itemBuilder: (context, index) {
                  final chatMessage = loadedMessages[index].data();
                  final nextChatMessage = index + 1 < loadedMessages.length
                      ? loadedMessages[index + 1].data()
                      : null;
                  final currentMessageUsernameId = chatMessage['user_id'];
                  final nextMessageUsernameId = nextChatMessage != null
                      ? nextChatMessage['user_id']
                      : null;
                  final nextUserIsSame =
                      nextMessageUsernameId == currentMessageUsernameId;
                  if (nextUserIsSame) {
                    return MessageBubble.next(
                        message: chatMessage['text'],
                        isMe:
                        authenticatedUser.uid == currentMessageUsernameId);
                  } else {
                    return MessageBubble.first(
                        userImage: chatMessage['userImage'],
                        username: chatMessage['username'],
                        message: chatMessage['text'],
                        isMe:
                        authenticatedUser.uid == currentMessageUsernameId);
                  }
                });
          }),
    );
  }
}
