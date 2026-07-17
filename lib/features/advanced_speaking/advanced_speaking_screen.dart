import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/conversation_models.dart';
import 'models/ai_character.dart';
import 'models/speaking_progress.dart';
import 'speaking_controller.dart';

class AdvancedSpeakingScreen extends StatefulWidget {
  const AdvancedSpeakingScreen({super.key});

  @override
  State<AdvancedSpeakingScreen> createState() => _AdvancedSpeakingScreenState();
}

class _AdvancedSpeakingScreenState extends State<AdvancedSpeakingScreen> {
  final SpeakingController _controller = SpeakingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        title: Text(
          'Advanced Speaking Lab',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => _showProgressDashboard(context),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () => _showChallenges(context),
          ),
        ],
      ),
      body: _initialized
          ? _controller.currentSession == null || _controller.state == ConversationState.ended
              ? _buildScenarioSelection()
              : _buildConversationView()
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
    );
  }

  Widget _buildScenarioSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Memory Message
          if (_controller.memory.recentMistakes.isNotEmpty ||
              _controller.memory.vocabularyProblems.isNotEmpty)
            _buildMemoryCard(),

          const SizedBox(height: 20),

          // Character Card
          _buildCharacterCard(),

          const SizedBox(height: 24),

          // Scenarios Grid
          Text(
            'Choose a Scenario',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ConversationScenario.values.length,
            itemBuilder: (context, index) {
              final scenario = ConversationScenario.values[index];
              return _buildScenarioCard(scenario);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.2),
            const Color(0xFF00BCD4).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Color(0xFF6C63FF), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _controller.memory.memoryMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildCharacterCard() {
    final character = AICharacter.lexi();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  character.personality,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI German Teacher',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildScenarioCard(ConversationScenario scenario) {
    return GestureDetector(
      onTap: () async {
        await _controller.startConversation(scenario);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scenario.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              scenario.displayName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getLevelColor(scenario.difficulty).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                scenario.difficulty,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: _getLevelColor(scenario.difficulty),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildConversationView() {
    return Column(
      children: [
        // Session Info
        _buildSessionInfo(),

        // Messages
        Expanded(
          child: _buildMessagesList(),
        ),

        // Pronunciation Analysis
        if (_controller.lastAnalysis != null) _buildPronunciationCard(),

        // Voice Controls
        _buildVoiceControls(),
      ],
    );
  }

  Widget _buildSessionInfo() {
    final session = _controller.currentSession!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                session.scenario.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.scenario.displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${session.messages.length} messages',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildStateIndicator(),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.stop_circle, color: Colors.red),
                onPressed: () async {
                  await _controller.endConversation();
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    Color color;
    String text;
    IconData icon;

    switch (_controller.state) {
      case ConversationState.listening:
        color = Colors.green;
        text = 'Listening';
        icon = Icons.mic;
        break;
      case ConversationState.processing:
        color = Colors.orange;
        text = 'Processing';
        icon = Icons.hourglass_empty;
        break;
      case ConversationState.aiSpeaking:
        color = const Color(0xFF6C63FF);
        text = 'AI Speaking';
        icon = Icons.volume_up;
        break;
      default:
        color = Colors.white54;
        text = 'Idle';
        icon = Icons.mic_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = _controller.currentSession?.messages ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    final isAI = message.role == 'ai';
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF1A1A2E) : const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isAI ? const Radius.circular(16) : const Radius.circular(4),
            bottomLeft: isAI ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAI)
              Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Lexi',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            if (message.correction != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.correction!,
                        style: GoogleFonts.poppins(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildPronunciationCard() {
    final analysis = _controller.lastAnalysis!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pronunciation Analysis',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreCircle('Pronunciation', analysis.pronunciation, const Color(0xFF4CAF50)),
              _buildScoreCircle('Fluency', analysis.speakingSpeed, const Color(0xFF2196F3)),
              _buildScoreCircle('Grammar', analysis.confidence, const Color(0xFFFF9800)),
              _buildScoreCircle('Accuracy', analysis.wordAccuracy, const Color(0xFF6C63FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(String label, double score, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 4,
              ),
              Text(
                '${score.toInt()}',
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceControls() {
    final isListening = _controller.state == ConversationState.listening;
    final isAISpeaking = _controller.state == ConversationState.aiSpeaking;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          if (_controller.currentText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _controller.currentText,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stop button
              if (!isAISpeaking)
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 40),
                  onPressed: () async {
                    await _controller.endConversation();
                    setState(() {});
                  },
                ),
              const SizedBox(width: 20),
              // Main mic button
              GestureDetector(
                onTap: isAISpeaking
                    ? null
                    : () async {
                        if (isListening) {
                          await _controller.stopListening();
                        } else {
                          await _controller.startListening();
                        }
                        setState(() {});
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isListening ? Colors.green : const Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? Colors.green : const Color(0xFF6C63FF))
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Replay button
              IconButton(
                icon: const Icon(Icons.replay, color: Colors.white54, size: 40),
                onPressed: () async {
                  final lastAI = _controller.currentSession?.messages
                      .where((m) => m.role == 'ai')
                      .lastOrNull;
                  if (lastAI != null) {
                    await _controller.speakText(lastAI.content);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF4CAF50);
      case 'A2':
        return const Color(0xFF8BC34A);
      case 'B1':
        return const Color(0xFFFFC107);
      case 'B2':
        return const Color(0xFFFF9800);
      case 'C1':
        return const Color(0xFFFF5722);
      case 'C2':
        return const Color(0xFFF44336);
      default:
        return Colors.white54;
    }
  }

  void _showProgressDashboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0E21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProgressDashboard(),
    );
  }

  Widget _buildProgressDashboard() {
    final progress = _controller.progress;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Speaking Progress',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildProgressStat('Speaking Minutes', '${progress.totalSpeakingMinutes}', Icons.timer, const Color(0xFF6C63FF)),
                  _buildProgressStat('Words Spoken', '${progress.totalWordsSpoken}', Icons.record_voice_over, const Color(0xFF4CAF50)),
                  _buildProgressStat('Sessions', '${progress.totalSessions}', Icons.chat, const Color(0xFFFF9800)),
                  _buildProgressStat('Streak', '${progress.currentStreak} days', Icons.local_fire_department, const Color(0xFFF44336)),
                ],
              ),
              const SizedBox(height: 24),
              // Score Averages
              Text(
                'Average Scores',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildScoreBar('Pronunciation', progress.averagePronunciationScore, const Color(0xFF4CAF50)),
              const SizedBox(height: 8),
              _buildScoreBar('Fluency', progress.averageFluencyScore, const Color(0xFF2196F3)),
              const SizedBox(height: 24),
              // Common Mistakes
              if (progress.commonMistakes.isNotEmpty) ...[
                Text(
                  'Common Mistakes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ...progress.commonMistakes.map((mistake) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mistake.pattern,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              mistake.suggestion,
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            Text(
              '${score.toInt()}%',
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(color),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _showChallenges(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0E21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildChallengesSheet(),
    );
  }

  Widget _buildChallengesSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Speaking Challenges',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ..._controller.challenges.map((challenge) => _buildChallengeCard(challenge)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengeCard(SpeakingChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.isActive
              ? const Color(0xFF6C63FF).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                challenge.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: challenge.isActive
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.isActive ? 'Active' : 'Completed',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: challenge.isActive ? const Color(0xFF4CAF50) : Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          LinearProgressIndicator(
            value: challenge.progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${challenge.completedDays}/${challenge.targetDays} days completed',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          // Rewards
          Row(
            children: [
              _buildRewardBadge('XP', challenge.reward.xp.toString(), const Color(0xFFFF9800)),
              const SizedBox(width: 8),
              _buildRewardBadge('Gems', challenge.reward.gems.toString(), const Color(0xFF6C63FF)),
              if (challenge.reward.badgeId != null) ...[
                const SizedBox(width: 8),
                _buildRewardBadge('Badge', '★', const Color(0xFFFFD700)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
