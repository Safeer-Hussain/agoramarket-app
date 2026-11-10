import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // If in flutter test or desktop without flutter engine, use ffi
    if (kIsWeb) {
      // In web or tests
    } else if (Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(docDir.path, AppConstants.dbName);
    }

    return await openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE video_pitches (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        creator_name TEXT NOT NULL,
        creator_avatar TEXT NOT NULL,
        role TEXT NOT NULL,
        hourly_rate REAL NOT NULL,
        currency TEXT NOT NULL,
        location_name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        category TEXT NOT NULL,
        video_asset TEXT NOT NULL,
        thumbnail_asset TEXT NOT NULL,
        likes_count INTEGER NOT NULL,
        bookmarks_count INTEGER NOT NULL,
        is_liked INTEGER NOT NULL,
        is_bookmarked INTEGER NOT NULL,
        pitch_script TEXT NOT NULL,
        skills TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        pitch_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_conversations (
        id TEXT PRIMARY KEY,
        participant_name TEXT NOT NULL,
        participant_avatar TEXT NOT NULL,
        role TEXT NOT NULL,
        last_message TEXT NOT NULL,
        last_message_time TEXT NOT NULL,
        unread_count INTEGER NOT NULL,
        is_online INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_contract INTEGER NOT NULL,
        contract_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE contract_offers (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        title TEXT NOT NULL,
        budget REAL NOT NULL,
        currency TEXT NOT NULL,
        delivery_days INTEGER NOT NULL,
        status TEXT NOT NULL,
        terms TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        headline TEXT NOT NULL,
        bio TEXT NOT NULL,
        hourly_rate REAL NOT NULL,
        currency TEXT NOT NULL,
        location TEXT NOT NULL,
        is_available INTEGER NOT NULL,
        rating REAL NOT NULL,
        reviews_count INTEGER NOT NULL,
        skills TEXT NOT NULL,
        completed_contracts INTEGER NOT NULL,
        avatar_asset TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE portfolio_items (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        metric TEXT NOT NULL,
        thumbnail_asset TEXT NOT NULL
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 1. Seed User Profile: Safeer Hussain
    await db.insert('user_profile', {
      'id': 'user_safeer_001',
      'name': 'Safeer Hussain',
      'headline': 'Principal Mobile & Marketplace Architect',
      'bio': 'Architecting high-concurrency vertical video marketplaces, low-latency client-side frame engines, and offline-first mobile applications.',
      'hourly_rate': 95.0,
      'currency': 'USD',
      'location': 'Lahore, Pakistan (Global Remote)',
      'is_available': 1,
      'rating': 4.98,
      'reviews_count': 42,
      'skills': 'Flutter,Dart,Clean Architecture,High-Throughput WebSockets,SQLite,Offline Sync,Custom Canvas,Micro-Frontends',
      'completed_contracts': 38,
      'avatar_asset': 'assets/images/avatar_safeer.png',
    });

    // 2. Seed Portfolio Items
    final portfolio = [
      {
        'id': 'port_001',
        'title': 'Sub-Second Video Reel Pipeline',
        'description': 'Engineered custom canvas multi-threaded video scrubber achieving 120 FPS render telemetry with zero drop frames.',
        'category': 'Architecture',
        'metric': 'Sub-8ms frame time',
        'thumbnail_asset': 'assets/images/thumb_mobile_arch.png',
      },
      {
        'id': 'port_002',
        'title': 'Offline-First Spatial Mapping Engine',
        'description': 'Vector bounding box spatial cluster index on SQLite enabling offline radius search across 100,000 coordinates.',
        'category': 'Mobile GIS',
        'metric': '100% offline query',
        'thumbnail_asset': 'assets/images/thumb_cloud_devops.png',
      },
      {
        'id': 'port_003',
        'title': 'Autonomous Real-Time Contract Protocol',
        'description': 'Structured milestone escrow negotiation protocol embedded directly within client-side encrypted chat streams.',
        'category': 'Fintech',
        'metric': 'Zero-dispute delivery',
        'thumbnail_asset': 'assets/images/thumb_ai_automation.png',
      },
    ];
    for (final item in portfolio) {
      await db.insert('portfolio_items', item);
    }

    // 3. Seed Video Pitches
    final pitches = [
      {
        'id': 'pitch_001',
        'title': 'Architecting 120FPS Vertical Video Feed with Sub-Second Viewport Cache',
        'creator_name': 'Safeer Hussain',
        'creator_avatar': 'assets/images/avatar_safeer.png',
        'role': 'Principal Flutter Architect',
        'hourly_rate': 95.0,
        'currency': 'USD',
        'location_name': 'Gulberg III, Lahore',
        'latitude': 31.5204,
        'longitude': 74.3587,
        'category': 'Freelancer',
        'video_asset': 'assets/images/thumb_mobile_arch.png',
        'thumbnail_asset': 'assets/images/thumb_mobile_arch.png',
        'likes_count': 1420,
        'bookmarks_count': 612,
        'is_liked': 1,
        'is_bookmarked': 1,
        'pitch_script': 'In this 60-second pitch, I walk through how we eliminated frame stutter in vertical video feeds using ahead-of-time bitmap pre-caching, isolator-driven decompression, and custom canvas telemetry.',
        'skills': 'Flutter,Dart,Performance,Custom Canvas,Clean Architecture',
        'created_at': now,
      },
      {
        'id': 'pitch_002',
        'title': 'Design System Overhaul for Hyper-Growth Fintech & Crypto Platforms',
        'creator_name': 'Ayesha Khan',
        'creator_avatar': 'assets/images/avatar_ayesha.png',
        'role': 'Lead Product & UX Designer',
        'hourly_rate': 75.0,
        'currency': 'USD',
        'location_name': 'DHA Phase 5, Lahore',
        'latitude': 31.4697,
        'longitude': 74.4084,
        'category': 'Freelancer',
        'video_asset': 'assets/images/thumb_ui_ux.png',
        'thumbnail_asset': 'assets/images/thumb_ui_ux.png',
        'likes_count': 980,
        'bookmarks_count': 415,
        'is_liked': 0,
        'is_bookmarked': 0,
        'pitch_script': 'Consolidated 400+ fragmented UI components into a strict WCAG-compliant design token system reducing sprint cycle design friction by 40%.',
        'skills': 'Figma,Design Systems,Tokens,Fintech UX,Prototyping',
        'created_at': now,
      },
      {
        'id': 'pitch_003',
        'title':
            'Zero-Downtime Multi-Region Kubernetes & Infrastructure as Code',
        'creator_name': 'Bilal Tariq',
        'creator_avatar': 'assets/images/avatar_bilal.png',
        'role': 'Staff Cloud DevOps Specialist',
        'hourly_rate': 85.0,
        'currency': 'USD',
        'location_name': 'Arfa Software Park, Lahore',
        'latitude': 31.4759,
        'longitude': 74.3414,
        'category': 'Agency',
        'video_asset': 'assets/images/thumb_cloud_devops.png',
        'thumbnail_asset': 'assets/images/thumb_cloud_devops.png',
        'likes_count': 1130,
        'bookmarks_count': 534,
        'is_liked': 0,
        'is_bookmarked': 1,
        'pitch_script': 'Showcasing automated Terraform and ArgoCD GitOps pipelines handling 50k requests per second with automatic multi-zone failover.',
        'skills': 'Kubernetes,Terraform,AWS,CI/CD,Observability',
        'created_at': now,
      },
      {
        'id': 'pitch_004',
        'title': 'Autonomous Enterprise LLM Agents & Deterministic Tool Orchestration',
        'creator_name': 'Zoya Fatima',
        'creator_avatar': 'assets/images/avatar_zoya.png',
        'role': 'AI Automation Architect',
        'hourly_rate': 110.0,
        'currency': 'USD',
        'location_name': 'Johar Town, Lahore',
        'latitude': 31.4697,
        'longitude': 74.2728,
        'category': 'Job',
        'video_asset': 'assets/images/thumb_ai_automation.png',
        'thumbnail_asset': 'assets/images/thumb_ai_automation.png',
        'likes_count': 2340,
        'bookmarks_count': 1088,
        'is_liked': 1,
        'is_bookmarked': 0,
        'pitch_script': 'Demonstrating strict type-safe structured JSON extraction and multi-agent coordination with local embedding search and verification gates.',
        'skills': 'LLM,Python,Agents,Vector Search,Prompt Engineering',
        'created_at': now,
      },
    ];

    for (final pitch in pitches) {
      await db.insert('video_pitches', pitch);
    }

    // 4. Seed Comments
    final comments = [
      {
        'id': 'c_001',
        'pitch_id': 'pitch_001',
        'author_name': 'Hamza Sheikh',
        'author_avatar': 'assets/images/avatar_bilal.png',
        'content': 'The custom canvas scrubber telemetry is exceptional. Zero jank on 120Hz displays.',
        'created_at': now,
      },
      {
        'id': 'c_002',
        'pitch_id': 'pitch_001',
        'author_name': 'Maryam Noor',
        'author_avatar': 'assets/images/avatar_ayesha.png',
        'content':
            'Sent a contract proposal for our upcoming marketplace revamp.',
        'created_at': now,
      },
    ];
    for (final c in comments) {
      await db.insert('comments', c);
    }

    // 5. Seed Conversations
    final convos = [
      {
        'id': 'conv_ayesha',
        'participant_name': 'Ayesha Khan',
        'participant_avatar': 'assets/images/avatar_ayesha.png',
        'role': 'Lead Product & UX Designer',
        'last_message':
            'I have reviewed your proposal milestones. Ready to proceed.',
        'last_message_time': '10:42 AM',
        'unread_count': 1,
        'is_online': 1,
      },
      {
        'id': 'conv_bilal',
        'participant_name': 'Bilal Tariq',
        'participant_avatar': 'assets/images/avatar_bilal.png',
        'role': 'Staff Cloud DevOps Specialist',
        'last_message':
            'DevOps cluster deployment is primed for staging tests.',
        'last_message_time': 'Yesterday',
        'unread_count': 0,
        'is_online': 0,
      },
      {
        'id': 'conv_zoya',
        'participant_name': 'Zoya Fatima',
        'participant_avatar': 'assets/images/avatar_zoya.png',
        'role': 'AI Automation Architect',
        'last_message': 'Contract Milestone #1 marked as accepted.',
        'last_message_time': 'Oct 29',
        'unread_count': 0,
        'is_online': 1,
      },
    ];
    for (final cv in convos) {
      await db.insert('chat_conversations', cv);
    }

    // 6. Seed Messages & Contract Offers
    final contractId = 'contract_ayesha_01';
    await db.insert('contract_offers', {
      'id': contractId,
      'conversation_id': 'conv_ayesha',
      'title': 'High-Performance Vertical Video Marketplace UI Overhaul',
      'budget': 3800.0,
      'currency': 'USD',
      'delivery_days': 14,
      'status': 'PENDING',
      'terms': 'Delivery of responsive two-pane adaptive layouts, custom canvas video scrubber, and full dark-mode parity.',
      'created_at': now,
    });

    final messages = [
      {
        'id': 'msg_001',
        'conversation_id': 'conv_ayesha',
        'sender_id': 'ayesha',
        'sender_name': 'Ayesha Khan',
        'text': 'Hi Safeer, your vertical video architecture pitch on the marketplace caught our eye.',
        'timestamp': '10:30 AM',
        'is_contract': 0,
        'contract_id': null,
      },
      {
        'id': 'msg_002',
        'conversation_id': 'conv_ayesha',
        'sender_id': 'safeer',
        'sender_name': 'Safeer Hussain',
        'text': 'Thanks Ayesha. We can structure the deliverable into two clean 7-day milestones.',
        'timestamp': '10:34 AM',
        'is_contract': 0,
        'contract_id': null,
      },
      {
        'id': 'msg_003',
        'conversation_id': 'conv_ayesha',
        'sender_id': 'safeer',
        'sender_name': 'Safeer Hussain',
        'text':
            'Here is the formal project milestone proposal for your review:',
        'timestamp': '10:35 AM',
        'is_contract': 1,
        'contract_id': contractId,
      },
      {
        'id': 'msg_004',
        'conversation_id': 'conv_ayesha',
        'sender_id': 'ayesha',
        'sender_name': 'Ayesha Khan',
        'text': 'I have reviewed your proposal milestones. Ready to proceed.',
        'timestamp': '10:42 AM',
        'is_contract': 0,
        'contract_id': null,
      },
    ];
    for (final m in messages) {
      await db.insert('chat_messages', m);
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('video_pitches');
    await db.delete('comments');
    await db.delete('chat_conversations');
    await db.delete('chat_messages');
    await db.delete('contract_offers');
    await db.delete('user_profile');
    await db.delete('portfolio_items');
    await _seedInitialData(db);
  }
}
