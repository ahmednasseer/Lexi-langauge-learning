import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/widgets/state_widgets.dart';
import 'models/live_room.dart';
import 'models/language_partner.dart';
import 'models/learning_group.dart';
import 'models/community_event.dart';
import 'live_learning_controller.dart';

class LiveLearningScreen extends StatefulWidget {
  const LiveLearningScreen({super.key});

  @override
  State<LiveLearningScreen> createState() => _LiveLearningScreenState();
}

class _LiveLearningScreenState extends State<LiveLearningScreen> {
  final LiveLearningController _controller = LiveLearningController();
  bool _initialized = false;
  bool _initError = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    setState(() {
      _initError = false;
      _initialized = false;
    });
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _initialized = true;
      _initError = _controller.error.isNotEmpty;
    });
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
          'Live Learning',
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
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateRoomDialog(context),
          ),
        ],
      ),
      body: !_initialized
          ? (_initError
              ? ErrorState(
                  message: 'Failed to load live sessions. Please try again.',
                  onRetry: _initializeController,
                )
              : const LoadingState(message: 'Loading live sessions...'))
          : RefreshIndicator(
              color: const Color(0xFF6C63FF),
              onRefresh: () async {
                await _controller.initialize();
                if (mounted) setState(() => _initError = _controller.error.isNotEmpty);
              },
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Rooms', Icons.meeting_room),
          _buildTab(1, 'Partners', Icons.people),
          _buildTab(2, 'Groups', Icons.group),
          _buildTab(3, 'Events', Icons.celebration),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildRoomsTab();
      case 1:
        return _buildPartnersTab();
      case 2:
        return _buildGroupsTab();
      case 3:
        return _buildEventsTab();
      default:
        return _buildRoomsTab();
    }
  }

  Widget _buildRoomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Speaking Rooms',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join a room and practice speaking German with others',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ..._controller.rooms.map((room) => _buildRoomCard(room)),
        ],
      ),
    );
  }

  Widget _buildRoomCard(LiveRoom room) {
    final statusColor = room.status == RoomStatus.active
        ? Colors.green
        : room.status == RoomStatus.waiting
            ? Colors.orange
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  room.status.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            room.topic,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                room.hostName,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.signal_cellular_alt, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                room.level.displayName,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${room.currentParticipants}/${room.maxParticipants}',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${room.durationMinutes} min',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: room.canJoin ? () => _joinRoom(room) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                room.canJoin ? 'Join Room' : (room.isFull ? 'Full' : 'Ended'),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildPartnersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language Partner Matching',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find a language exchange partner',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchButton(),
          const SizedBox(height: 16),
          Text(
            'Available Partners',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._controller.partners.map((partner) => _buildPartnerCard(partner)),
        ],
      ),
    );
  }

  Widget _buildMatchButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Match',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'We\'ll match you with the perfect language partner',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.7)),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(LanguagePartner partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                partner.userName[0],
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      partner.nativeLanguage,
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                    const Text(' → ', style: TextStyle(color: Colors.white54)),
                    Text(
                      partner.learningLanguage,
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  partner.level,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFF6C63FF)),
            onPressed: () {},
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Classes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join a group and learn together',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ..._controller.groups.map((group) => _buildGroupCard(group)),
        ],
      ),
    );
  }

  Widget _buildGroupCard(LearningGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.level,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            group.description,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '${group.currentMembers}/${group.maxMembers}',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                group.averageRating.toStringAsFixed(1),
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                group.frequency.displayName,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: group.canJoin ? () => _joinGroup(group) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                group.canJoin ? 'Join Group' : 'Full',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Events',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join exciting events and earn rewards',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ..._controller.events.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(CommunityEvent event) {
    final statusColor = event.status == EventStatus.active
        ? Colors.green
        : event.status == EventStatus.upcoming
            ? Colors.orange
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.status.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '${event.currentParticipants}/${event.maxParticipants}',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${event.reward.xp} XP',
                style: GoogleFonts.poppins(color: Colors.orange, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: event.canJoin ? () => _joinEvent(event) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                event.canJoin ? 'Join Event' : 'Full',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  void _joinRoom(LiveRoom room) async {
    await _controller.joinRoom(room.id, 'current_user', 'You');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${room.title}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _joinGroup(LearningGroup group) async {
    await _controller.joinGroup(group.id, 'current_user', 'You');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${group.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _joinEvent(CommunityEvent event) async {
    await _controller.joinEvent(event.id, 'current_user', 'You');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${event.title}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showCreateRoomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0E21),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreateRoomSheet(),
    );
  }

  Widget _buildCreateRoomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                'Create Room',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Room Title',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., German Café',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Topic',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'e.g., Travel Conversation',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RoomLevel>(
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Level',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                items: RoomLevel.values.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level.displayName));
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Max Participants',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                items: [5, 8, 10, 15, 20].map((count) {
                  return DropdownMenuItem(value: count, child: Text('$count'));
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Room created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Room',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
