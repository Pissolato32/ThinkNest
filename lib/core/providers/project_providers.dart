import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/conversation/send_message.dart';
import '../application/project/create_project.dart';
import '../domain/ai/ai_provider.dart';
import '../domain/conversation/conversation_repository.dart';
import '../infrastructure/ai/echo_provider.dart';
import '../infrastructure/conversation/drift_conversation_repository.dart';
import '../domain/project/project.dart';
import '../domain/project/project_repository.dart';
import '../infrastructure/database/thinknest_database.dart' hide Project;
import '../infrastructure/project/drift_project_repository.dart';

final databaseProvider = Provider<ThinkNestDatabase>((ref) {
  final database = ThinkNestDatabase();
  ref.onDispose(database.close);
  return database;
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return DriftProjectRepository(ref.watch(databaseProvider));
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return DriftConversationRepository(ref.watch(databaseProvider));
});

final aiProvider = Provider<AiProvider>((ref) => const EchoProvider());

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(
    ref.watch(conversationRepositoryProvider),
    ref.watch(projectRepositoryProvider),
    ref.watch(aiProvider),
  );
});

final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAll();
});

final createProjectProvider = Provider<CreateProject>((ref) {
  return CreateProject(ref.watch(projectRepositoryProvider));
});
