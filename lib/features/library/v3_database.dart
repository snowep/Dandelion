part of 'book_database.dart';

/// V3 database schema (before purchase/lending columns were added).
///
/// Used only by tests to create a pre-migration database and verify that
/// [AppDatabase] upgrades it to v4 without losing data.
@pragma('vm:entry-point')
class V3Database extends _$AppDatabase {
  V3Database(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      // Remove columns that were added in v4 to get v3 schema
      await migrator.dropColumn(books, books.purchasePrice.name);
      await migrator.dropColumn(books, books.purchaseCurrency.name);
      await migrator.dropColumn(books, books.isBorrowed.name);
      await migrator.dropColumn(books, books.lenderName.name);
      await migrator.dropColumn(books, books.lenderContact.name);
      await migrator.dropColumn(books, books.borrowDate.name);
      await migrator.dropColumn(books, books.expectedReturnDate.name);
      await migrator.dropColumn(books, books.isLent.name);
      await migrator.dropColumn(books, books.borrowerName.name);
      await migrator.dropColumn(books, books.borrowerContact.name);
      await migrator.dropColumn(books, books.lendDate.name);
      await migrator.dropColumn(books, books.expectedLendReturnDate.name);
    },
    onUpgrade: (migrator, from, to) async {
      // v3 doesn't need special upgrade logic since it's the base for our test
      if (from < 2) {
        await migrator.addColumn(books, books.summary);
      }
      if (from < 3) {
        await migrator.addColumn(books, books.isInWishlist);
      }
      // Note: v3->v4 upgrades are handled by the main AppDatabase migration
    },
  );
}
