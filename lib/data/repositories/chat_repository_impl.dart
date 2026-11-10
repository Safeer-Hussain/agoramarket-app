import '../../core/database/app_database.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AppDatabase _database;

  ChatRepositoryImpl({AppDatabase? database})
    : _database = database ?? AppDatabase();

  @override
  Future<List<ChatConversation>> getConversations() async {
    final db = await _database.database;
    final rows = await db.query('chat_conversations');
    return rows.map((r) => ChatConversation.fromMap(r)).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final db = await _database.database;
    final rows = await db.query(
      'chat_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return rows.map((r) => ChatMessage.fromMap(r)).toList();
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final db = await _database.database;
    await db.insert('chat_messages', message.toMap());

    // Update conversation last_message
    await db.update(
      'chat_conversations',
      {
        'last_message': message.isContract
            ? 'Contract Proposal Sent'
            : message.text,
        'last_message_time': message.timestamp,
      },
      where: 'id = ?',
      whereArgs: [message.conversationId],
    );
  }

  @override
  Future<ContractOffer?> getContractOffer(String contractId) async {
    final db = await _database.database;
    final rows = await db.query(
      'contract_offers',
      where: 'id = ?',
      whereArgs: [contractId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ContractOffer.fromMap(rows.first);
  }

  @override
  Future<void> createContractOffer(ContractOffer offer) async {
    final db = await _database.database;
    await db.insert('contract_offers', offer.toMap());
  }

  @override
  Future<void> updateContractStatus(String contractId, String status) async {
    final db = await _database.database;
    await db.update(
      'contract_offers',
      {'status': status},
      where: 'id = ?',
      whereArgs: [contractId],
    );
  }
}
