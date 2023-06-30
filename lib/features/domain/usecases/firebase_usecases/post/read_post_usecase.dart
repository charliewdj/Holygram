

import 'package:instagram_clone/features/domain/entities/posts/post_entity.dart';
import '../../../repository/firebase_repository.dart';

class ReadPostUseCase {
  final FirebaseRepository repository;

  ReadPostUseCase({required this.repository});

  Stream<List<PostEntity>> call(PostEntity post) {
    return repository.readPosts(post);
  }
}