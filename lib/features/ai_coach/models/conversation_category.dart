import 'package:flutter/material.dart';

class ConversationCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final Color color;
  final String? prompt;

  const ConversationCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    this.prompt,
  });

  static const List<ConversationCategory> categories = [
    ConversationCategory(
      id: 'restaurant',
      name: 'Restaurant',
      icon: '☕',
      description: 'Order food & drinks',
      color: Color(0xFFFF6B9D),
      prompt:
          'You are a waiter at a German restaurant. Greet the customer and take their order. Speak naturally in German.',
    ),
    ConversationCategory(
      id: 'travel',
      name: 'Travel',
      icon: '✈️',
      description: 'Navigate cities & transport',
      color: Color(0xFF2196F3),
      prompt:
          'You are a helpful local in Berlin. Help the tourist with directions and recommendations. Speak naturally in German.',
    ),
    ConversationCategory(
      id: 'work',
      name: 'Work',
      icon: '💼',
      description: 'Professional conversations',
      color: Color(0xFF9C27B0),
      prompt:
          'You are a German colleague at work. Have a professional conversation about projects and meetings. Speak naturally in German.',
    ),
    ConversationCategory(
      id: 'daily',
      name: 'Daily Life',
      icon: '🏠',
      description: 'Everyday situations',
      color: Color(0xFF4CAF50),
      prompt:
          'You are a friendly neighbor. Have a casual conversation about daily life topics like weather, hobbies, and family. Speak naturally in German.',
    ),
    ConversationCategory(
      id: 'free',
      name: 'Free Talk',
      icon: '🗣️',
      description: 'Practice anything',
      color: Color(0xFFFF9800),
      prompt:
          'You are Lexi, a friendly German AI tutor. Have a natural conversation in German. Correct mistakes gently and encourage the learner.',
    ),
    ConversationCategory(
      id: 'grammar',
      name: 'Grammar',
      icon: '📚',
      description: 'Learn grammar rules',
      color: Color(0xFF00BCD4),
      prompt:
          'You are a German grammar teacher. Help the student practice grammar through conversation. Explain rules when asked. Correct grammar mistakes with detailed explanations.',
    ),
  ];
}
