/// @file lib/features/chat/presentation/screens/chat_list_screen.dart
/// @brief Main chat list screen showing all conversations
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the main chat list screen that displays all user conversations
/// including 1-to-1 chats, group chats, and anonymous chats. It includes search functionality,
/// real-time updates, chat filtering, and navigation to individual chat screens.
/// The screen serves as the primary navigation hub for the messaging experience.

import 'package:chatly/core/constants/route_constants.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/core/providers/theme_provider.dart';
import 'package:chatly/core/utils/handlers/toast_handler.dart';
import 'package:chatly/core/widgets/common/custom_button.dart';
import 'package:chatly/data/models/chat_model.dart';
import 'package:chatly/data/models/user_model.dart';
import 'package:chatly/features/chat/presentation/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatModel> _filteredChats = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      // In a real app, this would filter actual chat data
      // For now, we'll simulate with mock data
      _filteredChats = _getSampleChats().where((chat) {
        return chat.chatName.toLowerCase().contains(_searchQuery) ||
               chat.lastMessageText.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  List<ChatModel> _getSampleChats() {
    // This would be replaced with actual data from repository in production
    return [
      ChatModel(
        chatId: 'chat1',
        participantIds: ['user1', 'user2'],
        chatName: 'John Doe',
        lastMessageText: 'Hey! How are you doing?',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
        lastMessageSenderId: 'user2',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isGroup: false,
      ),
      ChatModel(
        chatId: 'chat2',
        participantIds: ['user1', 'user3'],
        chatName: 'Jane Smith',
        lastMessageText: 'See you tomorrow at 3PM',
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessageSenderId: 'user3',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isGroup: false,
      ),
      ChatModel(
        chatId: 'group1',
        participantIds: ['user1', 'user2', 'user3', 'user4'],
        chatName: 'Work Team',
        lastMessageText: 'Meeting rescheduled to 4PM',
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
        lastMessageSenderId: 'user4',
        createdAt: DateTime.now().subtract(const Duration(weeks: 1)),
        isGroup: true,
        maxParticipants: 25,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Initialize filtered chats
    if (_filteredChats.isEmpty) {
      _filteredChats = _getSampleChats();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _filteredChats = _getSampleChats();
                    });
                  },
                ),
              ),
              style: theme.textTheme.bodyLarge,
              onChanged: _filterChats,
            )
          : Text(
              'Chats',
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
                Future.microtask(() {
                  _searchController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _searchController.text.length,
                  );
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Premium banner (simulated)
            if (authProvider.userProfile?.tier == 'free')
              _buildPremiumBanner(theme, screenSize),
            
            // No chats message
            if (_filteredChats.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: theme.colorScheme.secondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: theme.textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new chat to connect with friends and family',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.textTheme.bodyMedium!.color!.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'New Chat',
                          onPressed: () {
                            Navigator.pushNamed(context, RouteConstants.newChat);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Chat list
            if (_filteredChats.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // In real app, this would refresh chat data
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _filteredChats = _getSampleChats().where((chat) {
                        return chat.chatName.toLowerCase().contains(_searchQuery) ||
                               chat.lastMessageText.toLowerCase().contains(_searchQuery);
                      }).toList();
                    });
                  },
                  child: ListView.builder(
                    itemCount: _filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = _filteredChats[index];
                      
                      // Get mock participant data
                      final participants = [
                        UserModel(
                          uid: 'user1',
                          email: 'user1@example.com',
                          username: authProvider.userProfile?.username ?? 'Me',
                          tier: authProvider.userProfile?.tier ?? 'free',
                          createdAt: DateTime.now(),
                          lastSeen: DateTime.now(),
                        ),
                        UserModel(
                          uid: 'user2',
                          email: 'john@example.com',
                          username: 'John Doe',
                          tier: 'pro',
                          createdAt: DateTime.now(),
                          lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
                        ),
                      ];
                      
                      return ChatListItem(
                        chat: chat,
                        participants: participants,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstants.chat,
                            arguments: {'chatId': chat.chatId},
                          );
                        },
                        onLongPress: () {
                          _showChatOptions(context, chat);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.newChat);
        },
        child: const Icon(Icons.add),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
    );
  }

  Widget _buildPremiumBanner(ThemeData theme, Size screenSize) {
    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔒 Premium Features',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Get unlimited anonymous chats and group creation',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.premiumScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'Upgrade',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: const Color(0xFF8B5CF6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: Text('Chat Info'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to chat info screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(chat.isMuted('current_user') ? 'Unmute Notifications' : 'Mute Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle mute/unmute
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: Text('Archive Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle archive
                },
              ),
              if (!chat.isGroup)
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text('Block User'),
                  textColor: theme.colorScheme.error,
                  onTap: () {
                    Navigator.pop(context);
                    // Handle block
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Chat', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, chat);
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.primaryColor)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          title: Text('Delete Chat'),
          content: Text(
            'Are you sure you want to delete this chat? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle chat deletion
                setState(() {
                  _filteredChats.removeWhere((c) => c.chatId == chat.chatId);
                });
                ToastHandler.showSuccess(context, 'Chat deleted successfully');
              },
              child: Text(
                'Delete',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
