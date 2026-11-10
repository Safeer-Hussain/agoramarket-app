import 'package:agora_market_app/domain/entities/chat_entities.dart';
import 'package:agora_market_app/domain/entities/comment.dart';
import 'package:agora_market_app/domain/entities/user_profile.dart';
import 'package:agora_market_app/domain/entities/video_pitch.dart';
import 'package:agora_market_app/domain/repositories/chat_repository.dart';
import 'package:agora_market_app/domain/repositories/marketplace_repository.dart';
import 'package:agora_market_app/domain/repositories/profile_repository.dart';
import 'package:latlong2/latlong.dart';

class MockMarketplaceRepository implements MarketplaceRepository {
  List<VideoPitch> pitches = [];
  Map<String, List<Comment>> comments = {};
  final Distance _distance = const Distance();

  MockMarketplaceRepository() {
    pitches = [
      const VideoPitch(
        id: 'pitch_test_01',
        title: 'Architecting 120FPS Vertical Video Feed',
        creatorName: 'Safeer Hussain',
        creatorAvatar: 'assets/images/avatar_safeer.png',
        role: 'Principal Flutter Architect',
        hourlyRate: 95.0,
        currency: 'USD',
        locationName: 'Gulberg III, Lahore',
        latitude: 31.5204,
        longitude: 74.3587,
        category: 'Freelancer',
        videoAsset: 'assets/images/thumb_mobile_arch.png',
        thumbnailAsset: 'assets/images/thumb_mobile_arch.png',
        likesCount: 1420,
        bookmarksCount: 612,
        isLiked: false,
        isBookmarked: false,
        pitchScript: 'Testing sub-second vertical video architecture.',
        skills: ['Flutter', 'Dart', 'Custom Canvas'],
        createdAt: '2026-11-06T00:00:00Z',
      ),
      const VideoPitch(
        id: 'pitch_test_02',
        title: 'Design System Overhaul',
        creatorName: 'Ayesha Khan',
        creatorAvatar: 'assets/images/avatar_ayesha.png',
        role: 'Lead Product Designer',
        hourlyRate: 75.0,
        currency: 'USD',
        locationName: 'DHA Phase 5, Lahore',
        latitude: 31.4697,
        longitude: 74.4084,
        category: 'Freelancer',
        videoAsset: 'assets/images/thumb_ui_ux.png',
        thumbnailAsset: 'assets/images/thumb_ui_ux.png',
        likesCount: 980,
        bookmarksCount: 415,
        isLiked: true,
        isBookmarked: true,
        pitchScript: 'Testing WCAG design systems.',
        skills: ['Figma', 'Tokens'],
        createdAt: '2026-11-06T00:00:00Z',
      ),
      const VideoPitch(
        id: 'pitch_test_03',
        title: 'Zero Downtime Multi Region Kubernetes',
        creatorName: 'Bilal Tariq',
        creatorAvatar: 'assets/images/avatar_bilal.png',
        role: 'Staff DevOps Specialist',
        hourlyRate: 140.0,
        currency: 'USD',
        locationName: 'Johar Town, Lahore',
        latitude: 31.4697,
        longitude: 74.2728,
        category: 'Agency',
        videoAsset: 'assets/images/thumb_cloud_devops.png',
        thumbnailAsset: 'assets/images/thumb_cloud_devops.png',
        likesCount: 500,
        bookmarksCount: 200,
        isLiked: false,
        isBookmarked: false,
        pitchScript: 'Testing Kubernetes multi region.',
        skills: ['Kubernetes', 'Terraform'],
        createdAt: '2026-11-06T00:00:00Z',
      ),
    ];

    comments['pitch_test_01'] = [
      const Comment(
        id: 'c_01',
        pitchId: 'pitch_test_01',
        authorName: 'Bilal Tariq',
        authorAvatar: 'assets/images/avatar_bilal.png',
        content: 'Impressive frame telemetry.',
        createdAt: '1h ago',
      ),
    ];
  }

  @override
  Future<List<VideoPitch>> getVideoPitches() async => List.from(pitches);

  @override
  Future<void> toggleLike(String pitchId) async {
    final idx = pitches.indexWhere((p) => p.id == pitchId);
    if (idx != -1) {
      final cur = pitches[idx];
      pitches[idx] = cur.copyWith(
        isLiked: !cur.isLiked,
        likesCount: !cur.isLiked ? cur.likesCount + 1 : cur.likesCount - 1,
      );
    }
  }

  @override
  Future<void> toggleBookmark(String pitchId) async {
    final idx = pitches.indexWhere((p) => p.id == pitchId);
    if (idx != -1) {
      final cur = pitches[idx];
      pitches[idx] = cur.copyWith(
        isBookmarked: !cur.isBookmarked,
        bookmarksCount: !cur.isBookmarked
            ? cur.bookmarksCount + 1
            : cur.bookmarksCount - 1,
      );
    }
  }

  @override
  Future<void> addVideoPitch(VideoPitch pitch) async {
    pitches.insert(0, pitch);
  }

  @override
  Future<List<Comment>> getComments(String pitchId) async {
    return List.from(comments[pitchId] ?? []);
  }

  @override
  Future<void> addComment(Comment comment) async {
    final list = comments[comment.pitchId] ?? [];
    comments[comment.pitchId] = [comment, ...list];
  }

  @override
  Future<List<VideoPitch>> searchPitches({
    String? query,
    String? category,
    double? maxRadiusKm,
    double? userLat,
    double? userLng,
    double? maxHourlyRate,
  }) async {
    return pitches.where((pitch) {
      if (query != null && query.isNotEmpty) {
        if (!pitch.title.toLowerCase().contains(query.toLowerCase()) &&
            !pitch.creatorName.toLowerCase().contains(query.toLowerCase())) {
          return false;
        }
      }
      if (category != null && category != 'All' && pitch.category != category) {
        return false;
      }
      if (maxHourlyRate != null && pitch.hourlyRate > maxHourlyRate) {
        return false;
      }
      if (maxRadiusKm != null && userLat != null && userLng != null) {
        final dist = _distance.as(
          LengthUnit.Kilometer,
          LatLng(userLat, userLng),
          LatLng(pitch.latitude, pitch.longitude),
        );
        if (dist > maxRadiusKm) return false;
      }
      return true;
    }).toList();
  }
}

class MockChatRepository implements ChatRepository {
  List<ChatConversation> conversations = [];
  Map<String, List<ChatMessage>> messages = {};
  Map<String, ContractOffer> contracts = {};

  MockChatRepository() {
    conversations = [
      const ChatConversation(
        id: 'conv_01',
        participantName: 'Ayesha Khan',
        participantAvatar: 'assets/images/avatar_ayesha.png',
        role: 'Lead Product Designer',
        lastMessage: 'Ready to proceed.',
        lastMessageTime: '10:42 AM',
        unreadCount: 1,
        isOnline: true,
      ),
    ];

    contracts['contract_01'] = const ContractOffer(
      id: 'contract_01',
      conversationId: 'conv_01',
      title: 'UI Architecture Overhaul',
      budget: 3500.0,
      currency: 'USD',
      deliveryDays: 14,
      status: 'PENDING',
      terms: 'Milestone 1 and 2 delivery.',
      createdAt: '2026-11-06T00:00:00Z',
    );

    messages['conv_01'] = [
      const ChatMessage(
        id: 'msg_01',
        conversationId: 'conv_01',
        senderId: 'ayesha',
        senderName: 'Ayesha Khan',
        text: 'Initial technical inquiry',
        timestamp: '10:00 AM',
        isContract: false,
      ),
      const ChatMessage(
        id: 'msg_02',
        conversationId: 'conv_01',
        senderId: 'safeer',
        senderName: 'Safeer Hussain',
        text: 'Proposal offer sent',
        timestamp: '10:05 AM',
        isContract: true,
        contractId: 'contract_01',
      ),
    ];
  }

  @override
  Future<List<ChatConversation>> getConversations() async =>
      List.from(conversations);

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async =>
      List.from(messages[conversationId] ?? []);

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final list = messages[message.conversationId] ?? [];
    messages[message.conversationId] = [...list, message];
  }

  @override
  Future<ContractOffer?> getContractOffer(String contractId) async =>
      contracts[contractId];

  @override
  Future<void> createContractOffer(ContractOffer offer) async {
    contracts[offer.id] = offer;
  }

  @override
  Future<void> updateContractStatus(String contractId, String status) async {
    final cur = contracts[contractId];
    if (cur != null) {
      contracts[contractId] = cur.copyWith(status: status);
    }
  }
}

class MockProfileRepository implements ProfileRepository {
  UserProfile profile = const UserProfile(
    id: 'user_01',
    name: 'Safeer Hussain',
    headline: 'Principal Mobile Architect',
    bio: 'Architecting high-concurrency vertical video marketplaces.',
    hourlyRate: 95.0,
    currency: 'USD',
    location: 'Lahore, Pakistan',
    isAvailable: true,
    rating: 4.98,
    reviewsCount: 42,
    skills: ['Flutter', 'Dart', 'Clean Architecture'],
    completedContracts: 38,
    avatarAsset: 'assets/images/avatar_safeer.png',
  );

  List<PortfolioItem> portfolio = [
    const PortfolioItem(
      id: 'p_01',
      title: 'Sub-Second Video Reel Pipeline',
      description: '120 FPS render telemetry.',
      category: 'Architecture',
      metric: 'Sub-8ms frame time',
      thumbnailAsset: 'assets/images/thumb_mobile_arch.png',
    ),
  ];

  @override
  Future<UserProfile> getUserProfile() async => profile;

  @override
  Future<void> updateUserProfile(UserProfile newProfile) async {
    profile = newProfile;
  }

  @override
  Future<void> toggleAvailability(bool isAvailable) async {
    profile = profile.copyWith(isAvailable: isAvailable);
  }

  @override
  Future<List<PortfolioItem>> getPortfolioItems() async => List.from(portfolio);

  @override
  Future<void> addPortfolioItem(PortfolioItem item) async {
    portfolio.insert(0, item);
  }
}
