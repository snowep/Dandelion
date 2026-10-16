import 'dart:io';

import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late BookRepositoryImpl repository;

  Future<void> openDatabase() async {
    database = AppDatabase(
      NativeDatabase(File('${directory.path}//library.db')),
    );
    repository = BookRepositoryImpl(database);
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('dandelion-wishlist-');
    await openDatabase();
  });

  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('toggle wishlist persists across close/reopen', () async {
    final id = await repository.createBook(
      Book(id: 0, title: 'Wishlist Book', authors: 'A. Author'),
    );

    var book = await repository.getBookById(id);
    expect(book?.isInWishlist, false);

    await repository.toggleWishlist(id);
    book = await repository.getBookById(id);
    expect(book?.isInWishlist, true);

    await repository.toggleWishlist(id);
    book = await repository.getBookById(id);
    expect(book?.isInWishlist, false);

    await repository.close();
    await openDatabase();

    book = await repository.getBookById(id);
    expect(book?.isInWishlist, false);
  });
}
