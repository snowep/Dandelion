// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 512,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> authors =
      GeneratedColumn<String>(
        'authors',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($BooksTable.$converterauthorsn);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedIsbnMeta = const VerificationMeta(
    'normalizedIsbn',
  );
  @override
  late final GeneratedColumn<String> normalizedIsbn = GeneratedColumn<String>(
    'normalized_isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicationDateMeta = const VerificationMeta(
    'publicationDate',
  );
  @override
  late final GeneratedColumn<DateTime> publicationDate =
      GeneratedColumn<DateTime>(
        'publication_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _publishedYearMeta = const VerificationMeta(
    'publishedYear',
  );
  @override
  late final GeneratedColumn<int> publishedYear = GeneratedColumn<int>(
    'published_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverAssetKeyMeta = const VerificationMeta(
    'coverAssetKey',
  );
  @override
  late final GeneratedColumn<String> coverAssetKey = GeneratedColumn<String>(
    'cover_asset_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalCatalogIdMeta = const VerificationMeta(
    'externalCatalogId',
  );
  @override
  late final GeneratedColumn<String> externalCatalogId =
      GeneratedColumn<String>(
        'external_catalog_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _externalSourceUrlMeta = const VerificationMeta(
    'externalSourceUrl',
  );
  @override
  late final GeneratedColumn<String> externalSourceUrl =
      GeneratedColumn<String>(
        'external_source_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isInWishlistMeta = const VerificationMeta(
    'isInWishlist',
  );
  @override
  late final GeneratedColumn<bool> isInWishlist = GeneratedColumn<bool>(
    'is_in_wishlist',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_in_wishlist" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    authors,
    author,
    description,
    summary,
    genres,
    isbn,
    normalizedIsbn,
    publisher,
    publicationDate,
    publishedYear,
    pageCount,
    coverAssetKey,
    coverUrl,
    externalCatalogId,
    externalSourceUrl,
    isInWishlist,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('normalized_isbn')) {
      context.handle(
        _normalizedIsbnMeta,
        normalizedIsbn.isAcceptableOrUnknown(
          data['normalized_isbn']!,
          _normalizedIsbnMeta,
        ),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('publication_date')) {
      context.handle(
        _publicationDateMeta,
        publicationDate.isAcceptableOrUnknown(
          data['publication_date']!,
          _publicationDateMeta,
        ),
      );
    }
    if (data.containsKey('published_year')) {
      context.handle(
        _publishedYearMeta,
        publishedYear.isAcceptableOrUnknown(
          data['published_year']!,
          _publishedYearMeta,
        ),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('cover_asset_key')) {
      context.handle(
        _coverAssetKeyMeta,
        coverAssetKey.isAcceptableOrUnknown(
          data['cover_asset_key']!,
          _coverAssetKeyMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('external_catalog_id')) {
      context.handle(
        _externalCatalogIdMeta,
        externalCatalogId.isAcceptableOrUnknown(
          data['external_catalog_id']!,
          _externalCatalogIdMeta,
        ),
      );
    }
    if (data.containsKey('external_source_url')) {
      context.handle(
        _externalSourceUrlMeta,
        externalSourceUrl.isAcceptableOrUnknown(
          data['external_source_url']!,
          _externalSourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('is_in_wishlist')) {
      context.handle(
        _isInWishlistMeta,
        isInWishlist.isAcceptableOrUnknown(
          data['is_in_wishlist']!,
          _isInWishlistMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      authors: $BooksTable.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      normalizedIsbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_isbn'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publicationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}publication_date'],
      ),
      publishedYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}published_year'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      coverAssetKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_asset_key'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      externalCatalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_catalog_id'],
      ),
      externalSourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_source_url'],
      ),
      isInWishlist: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_in_wishlist'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterauthors =
      const JsonListStringConverter();
  static TypeConverter<List<String>?, String?> $converterauthorsn =
      NullAwareTypeConverter.wrap($converterauthors);
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final int id;
  final String title;
  final List<String>? authors;
  final String? author;
  final String? description;
  final String? summary;
  final String? genres;
  final String? isbn;
  final String? normalizedIsbn;
  final String? publisher;
  final DateTime? publicationDate;
  final int? publishedYear;
  final int? pageCount;
  final String? coverAssetKey;
  final String? coverUrl;
  final String? externalCatalogId;
  final String? externalSourceUrl;
  final bool isInWishlist;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const BookRow({
    required this.id,
    required this.title,
    this.authors,
    this.author,
    this.description,
    this.summary,
    this.genres,
    this.isbn,
    this.normalizedIsbn,
    this.publisher,
    this.publicationDate,
    this.publishedYear,
    this.pageCount,
    this.coverAssetKey,
    this.coverUrl,
    this.externalCatalogId,
    this.externalSourceUrl,
    required this.isInWishlist,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || authors != null) {
      map['authors'] = Variable<String>(
        $BooksTable.$converterauthorsn.toSql(authors),
      );
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || normalizedIsbn != null) {
      map['normalized_isbn'] = Variable<String>(normalizedIsbn);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publicationDate != null) {
      map['publication_date'] = Variable<DateTime>(publicationDate);
    }
    if (!nullToAbsent || publishedYear != null) {
      map['published_year'] = Variable<int>(publishedYear);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || coverAssetKey != null) {
      map['cover_asset_key'] = Variable<String>(coverAssetKey);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || externalCatalogId != null) {
      map['external_catalog_id'] = Variable<String>(externalCatalogId);
    }
    if (!nullToAbsent || externalSourceUrl != null) {
      map['external_source_url'] = Variable<String>(externalSourceUrl);
    }
    map['is_in_wishlist'] = Variable<bool>(isInWishlist);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      authors: authors == null && nullToAbsent
          ? const Value.absent()
          : Value(authors),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      normalizedIsbn: normalizedIsbn == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedIsbn),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publicationDate: publicationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationDate),
      publishedYear: publishedYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedYear),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      coverAssetKey: coverAssetKey == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAssetKey),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      externalCatalogId: externalCatalogId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalCatalogId),
      externalSourceUrl: externalSourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(externalSourceUrl),
      isInWishlist: Value(isInWishlist),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      authors: serializer.fromJson<List<String>?>(json['authors']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      summary: serializer.fromJson<String?>(json['summary']),
      genres: serializer.fromJson<String?>(json['genres']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      normalizedIsbn: serializer.fromJson<String?>(json['normalizedIsbn']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publicationDate: serializer.fromJson<DateTime?>(json['publicationDate']),
      publishedYear: serializer.fromJson<int?>(json['publishedYear']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      coverAssetKey: serializer.fromJson<String?>(json['coverAssetKey']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      externalCatalogId: serializer.fromJson<String?>(
        json['externalCatalogId'],
      ),
      externalSourceUrl: serializer.fromJson<String?>(
        json['externalSourceUrl'],
      ),
      isInWishlist: serializer.fromJson<bool>(json['isInWishlist']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'authors': serializer.toJson<List<String>?>(authors),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'summary': serializer.toJson<String?>(summary),
      'genres': serializer.toJson<String?>(genres),
      'isbn': serializer.toJson<String?>(isbn),
      'normalizedIsbn': serializer.toJson<String?>(normalizedIsbn),
      'publisher': serializer.toJson<String?>(publisher),
      'publicationDate': serializer.toJson<DateTime?>(publicationDate),
      'publishedYear': serializer.toJson<int?>(publishedYear),
      'pageCount': serializer.toJson<int?>(pageCount),
      'coverAssetKey': serializer.toJson<String?>(coverAssetKey),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'externalCatalogId': serializer.toJson<String?>(externalCatalogId),
      'externalSourceUrl': serializer.toJson<String?>(externalSourceUrl),
      'isInWishlist': serializer.toJson<bool>(isInWishlist),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  BookRow copyWith({
    int? id,
    String? title,
    Value<List<String>?> authors = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> isbn = const Value.absent(),
    Value<String?> normalizedIsbn = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<DateTime?> publicationDate = const Value.absent(),
    Value<int?> publishedYear = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> coverAssetKey = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> externalCatalogId = const Value.absent(),
    Value<String?> externalSourceUrl = const Value.absent(),
    bool? isInWishlist,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => BookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    authors: authors.present ? authors.value : this.authors,
    author: author.present ? author.value : this.author,
    description: description.present ? description.value : this.description,
    summary: summary.present ? summary.value : this.summary,
    genres: genres.present ? genres.value : this.genres,
    isbn: isbn.present ? isbn.value : this.isbn,
    normalizedIsbn: normalizedIsbn.present
        ? normalizedIsbn.value
        : this.normalizedIsbn,
    publisher: publisher.present ? publisher.value : this.publisher,
    publicationDate: publicationDate.present
        ? publicationDate.value
        : this.publicationDate,
    publishedYear: publishedYear.present
        ? publishedYear.value
        : this.publishedYear,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    coverAssetKey: coverAssetKey.present
        ? coverAssetKey.value
        : this.coverAssetKey,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    externalCatalogId: externalCatalogId.present
        ? externalCatalogId.value
        : this.externalCatalogId,
    externalSourceUrl: externalSourceUrl.present
        ? externalSourceUrl.value
        : this.externalSourceUrl,
    isInWishlist: isInWishlist ?? this.isInWishlist,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      authors: data.authors.present ? data.authors.value : this.authors,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
      summary: data.summary.present ? data.summary.value : this.summary,
      genres: data.genres.present ? data.genres.value : this.genres,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      normalizedIsbn: data.normalizedIsbn.present
          ? data.normalizedIsbn.value
          : this.normalizedIsbn,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      publishedYear: data.publishedYear.present
          ? data.publishedYear.value
          : this.publishedYear,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      coverAssetKey: data.coverAssetKey.present
          ? data.coverAssetKey.value
          : this.coverAssetKey,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      externalCatalogId: data.externalCatalogId.present
          ? data.externalCatalogId.value
          : this.externalCatalogId,
      externalSourceUrl: data.externalSourceUrl.present
          ? data.externalSourceUrl.value
          : this.externalSourceUrl,
      isInWishlist: data.isInWishlist.present
          ? data.isInWishlist.value
          : this.isInWishlist,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('summary: $summary, ')
          ..write('genres: $genres, ')
          ..write('isbn: $isbn, ')
          ..write('normalizedIsbn: $normalizedIsbn, ')
          ..write('publisher: $publisher, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('publishedYear: $publishedYear, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverAssetKey: $coverAssetKey, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('externalCatalogId: $externalCatalogId, ')
          ..write('externalSourceUrl: $externalSourceUrl, ')
          ..write('isInWishlist: $isInWishlist, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    authors,
    author,
    description,
    summary,
    genres,
    isbn,
    normalizedIsbn,
    publisher,
    publicationDate,
    publishedYear,
    pageCount,
    coverAssetKey,
    coverUrl,
    externalCatalogId,
    externalSourceUrl,
    isInWishlist,
    createdAt,
    updatedAt,
    archivedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.authors == this.authors &&
          other.author == this.author &&
          other.description == this.description &&
          other.summary == this.summary &&
          other.genres == this.genres &&
          other.isbn == this.isbn &&
          other.normalizedIsbn == this.normalizedIsbn &&
          other.publisher == this.publisher &&
          other.publicationDate == this.publicationDate &&
          other.publishedYear == this.publishedYear &&
          other.pageCount == this.pageCount &&
          other.coverAssetKey == this.coverAssetKey &&
          other.coverUrl == this.coverUrl &&
          other.externalCatalogId == this.externalCatalogId &&
          other.externalSourceUrl == this.externalSourceUrl &&
          other.isInWishlist == this.isInWishlist &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<List<String>?> authors;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> summary;
  final Value<String?> genres;
  final Value<String?> isbn;
  final Value<String?> normalizedIsbn;
  final Value<String?> publisher;
  final Value<DateTime?> publicationDate;
  final Value<int?> publishedYear;
  final Value<int?> pageCount;
  final Value<String?> coverAssetKey;
  final Value<String?> coverUrl;
  final Value<String?> externalCatalogId;
  final Value<String?> externalSourceUrl;
  final Value<bool> isInWishlist;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.summary = const Value.absent(),
    this.genres = const Value.absent(),
    this.isbn = const Value.absent(),
    this.normalizedIsbn = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.publishedYear = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverAssetKey = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.externalCatalogId = const Value.absent(),
    this.externalSourceUrl = const Value.absent(),
    this.isInWishlist = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.authors = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.summary = const Value.absent(),
    this.genres = const Value.absent(),
    this.isbn = const Value.absent(),
    this.normalizedIsbn = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.publishedYear = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.coverAssetKey = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.externalCatalogId = const Value.absent(),
    this.externalSourceUrl = const Value.absent(),
    this.isInWishlist = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<BookRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? summary,
    Expression<String>? genres,
    Expression<String>? isbn,
    Expression<String>? normalizedIsbn,
    Expression<String>? publisher,
    Expression<DateTime>? publicationDate,
    Expression<int>? publishedYear,
    Expression<int>? pageCount,
    Expression<String>? coverAssetKey,
    Expression<String>? coverUrl,
    Expression<String>? externalCatalogId,
    Expression<String>? externalSourceUrl,
    Expression<bool>? isInWishlist,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (summary != null) 'summary': summary,
      if (genres != null) 'genres': genres,
      if (isbn != null) 'isbn': isbn,
      if (normalizedIsbn != null) 'normalized_isbn': normalizedIsbn,
      if (publisher != null) 'publisher': publisher,
      if (publicationDate != null) 'publication_date': publicationDate,
      if (publishedYear != null) 'published_year': publishedYear,
      if (pageCount != null) 'page_count': pageCount,
      if (coverAssetKey != null) 'cover_asset_key': coverAssetKey,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (externalCatalogId != null) 'external_catalog_id': externalCatalogId,
      if (externalSourceUrl != null) 'external_source_url': externalSourceUrl,
      if (isInWishlist != null) 'is_in_wishlist': isInWishlist,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<List<String>?>? authors,
    Value<String?>? author,
    Value<String?>? description,
    Value<String?>? summary,
    Value<String?>? genres,
    Value<String?>? isbn,
    Value<String?>? normalizedIsbn,
    Value<String?>? publisher,
    Value<DateTime?>? publicationDate,
    Value<int?>? publishedYear,
    Value<int?>? pageCount,
    Value<String?>? coverAssetKey,
    Value<String?>? coverUrl,
    Value<String?>? externalCatalogId,
    Value<String?>? externalSourceUrl,
    Value<bool>? isInWishlist,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      author: author ?? this.author,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      genres: genres ?? this.genres,
      isbn: isbn ?? this.isbn,
      normalizedIsbn: normalizedIsbn ?? this.normalizedIsbn,
      publisher: publisher ?? this.publisher,
      publicationDate: publicationDate ?? this.publicationDate,
      publishedYear: publishedYear ?? this.publishedYear,
      pageCount: pageCount ?? this.pageCount,
      coverAssetKey: coverAssetKey ?? this.coverAssetKey,
      coverUrl: coverUrl ?? this.coverUrl,
      externalCatalogId: externalCatalogId ?? this.externalCatalogId,
      externalSourceUrl: externalSourceUrl ?? this.externalSourceUrl,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(
        $BooksTable.$converterauthorsn.toSql(authors.value),
      );
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (normalizedIsbn.present) {
      map['normalized_isbn'] = Variable<String>(normalizedIsbn.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publicationDate.present) {
      map['publication_date'] = Variable<DateTime>(publicationDate.value);
    }
    if (publishedYear.present) {
      map['published_year'] = Variable<int>(publishedYear.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (coverAssetKey.present) {
      map['cover_asset_key'] = Variable<String>(coverAssetKey.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (externalCatalogId.present) {
      map['external_catalog_id'] = Variable<String>(externalCatalogId.value);
    }
    if (externalSourceUrl.present) {
      map['external_source_url'] = Variable<String>(externalSourceUrl.value);
    }
    if (isInWishlist.present) {
      map['is_in_wishlist'] = Variable<bool>(isInWishlist.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('summary: $summary, ')
          ..write('genres: $genres, ')
          ..write('isbn: $isbn, ')
          ..write('normalizedIsbn: $normalizedIsbn, ')
          ..write('publisher: $publisher, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('publishedYear: $publishedYear, ')
          ..write('pageCount: $pageCount, ')
          ..write('coverAssetKey: $coverAssetKey, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('externalCatalogId: $externalCatalogId, ')
          ..write('externalSourceUrl: $externalSourceUrl, ')
          ..write('isInWishlist: $isInWishlist, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingRecordsTable extends ReadingRecords
    with TableInfo<$ReadingRecordsTable, ReadingRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wantToRead'),
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressPercentMeta = const VerificationMeta(
    'progressPercent',
  );
  @override
  late final GeneratedColumn<int> progressPercent = GeneratedColumn<int>(
    'progress_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishDateMeta = const VerificationMeta(
    'finishDate',
  );
  @override
  late final GeneratedColumn<DateTime> finishDate = GeneratedColumn<DateTime>(
    'finish_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadDateMeta = const VerificationMeta(
    'lastReadDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadDate = GeneratedColumn<DateTime>(
    'last_read_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _personalRatingMeta = const VerificationMeta(
    'personalRating',
  );
  @override
  late final GeneratedColumn<double> personalRating = GeneratedColumn<double>(
    'personal_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    status,
    currentPage,
    progressPercent,
    startDate,
    finishDate,
    lastReadDate,
    personalRating,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
        _progressPercentMeta,
        progressPercent.isAcceptableOrUnknown(
          data['progress_percent']!,
          _progressPercentMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('finish_date')) {
      context.handle(
        _finishDateMeta,
        finishDate.isAcceptableOrUnknown(data['finish_date']!, _finishDateMeta),
      );
    }
    if (data.containsKey('last_read_date')) {
      context.handle(
        _lastReadDateMeta,
        lastReadDate.isAcceptableOrUnknown(
          data['last_read_date']!,
          _lastReadDateMeta,
        ),
      );
    }
    if (data.containsKey('personal_rating')) {
      context.handle(
        _personalRatingMeta,
        personalRating.isAcceptableOrUnknown(
          data['personal_rating']!,
          _personalRatingMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      ),
      progressPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_percent'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      finishDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finish_date'],
      ),
      lastReadDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_date'],
      )!,
      personalRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}personal_rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ReadingRecordsTable createAlias(String alias) {
    return $ReadingRecordsTable(attachedDatabase, alias);
  }
}

class ReadingRecordRow extends DataClass
    implements Insertable<ReadingRecordRow> {
  final int id;
  final int bookId;
  final String status;
  final int? currentPage;
  final int? progressPercent;
  final DateTime? startDate;
  final DateTime? finishDate;
  final DateTime lastReadDate;
  final double? personalRating;
  final String? notes;
  const ReadingRecordRow({
    required this.id,
    required this.bookId,
    required this.status,
    this.currentPage,
    this.progressPercent,
    this.startDate,
    this.finishDate,
    required this.lastReadDate,
    this.personalRating,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || currentPage != null) {
      map['current_page'] = Variable<int>(currentPage);
    }
    if (!nullToAbsent || progressPercent != null) {
      map['progress_percent'] = Variable<int>(progressPercent);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || finishDate != null) {
      map['finish_date'] = Variable<DateTime>(finishDate);
    }
    map['last_read_date'] = Variable<DateTime>(lastReadDate);
    if (!nullToAbsent || personalRating != null) {
      map['personal_rating'] = Variable<double>(personalRating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ReadingRecordsCompanion toCompanion(bool nullToAbsent) {
    return ReadingRecordsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      status: Value(status),
      currentPage: currentPage == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPage),
      progressPercent: progressPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(progressPercent),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      finishDate: finishDate == null && nullToAbsent
          ? const Value.absent()
          : Value(finishDate),
      lastReadDate: Value(lastReadDate),
      personalRating: personalRating == null && nullToAbsent
          ? const Value.absent()
          : Value(personalRating),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ReadingRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingRecordRow(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      status: serializer.fromJson<String>(json['status']),
      currentPage: serializer.fromJson<int?>(json['currentPage']),
      progressPercent: serializer.fromJson<int?>(json['progressPercent']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      finishDate: serializer.fromJson<DateTime?>(json['finishDate']),
      lastReadDate: serializer.fromJson<DateTime>(json['lastReadDate']),
      personalRating: serializer.fromJson<double?>(json['personalRating']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'status': serializer.toJson<String>(status),
      'currentPage': serializer.toJson<int?>(currentPage),
      'progressPercent': serializer.toJson<int?>(progressPercent),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'finishDate': serializer.toJson<DateTime?>(finishDate),
      'lastReadDate': serializer.toJson<DateTime>(lastReadDate),
      'personalRating': serializer.toJson<double?>(personalRating),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ReadingRecordRow copyWith({
    int? id,
    int? bookId,
    String? status,
    Value<int?> currentPage = const Value.absent(),
    Value<int?> progressPercent = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> finishDate = const Value.absent(),
    DateTime? lastReadDate,
    Value<double?> personalRating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ReadingRecordRow(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    status: status ?? this.status,
    currentPage: currentPage.present ? currentPage.value : this.currentPage,
    progressPercent: progressPercent.present
        ? progressPercent.value
        : this.progressPercent,
    startDate: startDate.present ? startDate.value : this.startDate,
    finishDate: finishDate.present ? finishDate.value : this.finishDate,
    lastReadDate: lastReadDate ?? this.lastReadDate,
    personalRating: personalRating.present
        ? personalRating.value
        : this.personalRating,
    notes: notes.present ? notes.value : this.notes,
  );
  ReadingRecordRow copyWithCompanion(ReadingRecordsCompanion data) {
    return ReadingRecordRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      status: data.status.present ? data.status.value : this.status,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      progressPercent: data.progressPercent.present
          ? data.progressPercent.value
          : this.progressPercent,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      finishDate: data.finishDate.present
          ? data.finishDate.value
          : this.finishDate,
      lastReadDate: data.lastReadDate.present
          ? data.lastReadDate.value
          : this.lastReadDate,
      personalRating: data.personalRating.present
          ? data.personalRating.value
          : this.personalRating,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingRecordRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('startDate: $startDate, ')
          ..write('finishDate: $finishDate, ')
          ..write('lastReadDate: $lastReadDate, ')
          ..write('personalRating: $personalRating, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    status,
    currentPage,
    progressPercent,
    startDate,
    finishDate,
    lastReadDate,
    personalRating,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingRecordRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.status == this.status &&
          other.currentPage == this.currentPage &&
          other.progressPercent == this.progressPercent &&
          other.startDate == this.startDate &&
          other.finishDate == this.finishDate &&
          other.lastReadDate == this.lastReadDate &&
          other.personalRating == this.personalRating &&
          other.notes == this.notes);
}

class ReadingRecordsCompanion extends UpdateCompanion<ReadingRecordRow> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> status;
  final Value<int?> currentPage;
  final Value<int?> progressPercent;
  final Value<DateTime?> startDate;
  final Value<DateTime?> finishDate;
  final Value<DateTime> lastReadDate;
  final Value<double?> personalRating;
  final Value<String?> notes;
  const ReadingRecordsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.startDate = const Value.absent(),
    this.finishDate = const Value.absent(),
    this.lastReadDate = const Value.absent(),
    this.personalRating = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ReadingRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.startDate = const Value.absent(),
    this.finishDate = const Value.absent(),
    this.lastReadDate = const Value.absent(),
    this.personalRating = const Value.absent(),
    this.notes = const Value.absent(),
  }) : bookId = Value(bookId);
  static Insertable<ReadingRecordRow> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? status,
    Expression<int>? currentPage,
    Expression<int>? progressPercent,
    Expression<DateTime>? startDate,
    Expression<DateTime>? finishDate,
    Expression<DateTime>? lastReadDate,
    Expression<double>? personalRating,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (status != null) 'status': status,
      if (currentPage != null) 'current_page': currentPage,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (startDate != null) 'start_date': startDate,
      if (finishDate != null) 'finish_date': finishDate,
      if (lastReadDate != null) 'last_read_date': lastReadDate,
      if (personalRating != null) 'personal_rating': personalRating,
      if (notes != null) 'notes': notes,
    });
  }

  ReadingRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? status,
    Value<int?>? currentPage,
    Value<int?>? progressPercent,
    Value<DateTime?>? startDate,
    Value<DateTime?>? finishDate,
    Value<DateTime>? lastReadDate,
    Value<double?>? personalRating,
    Value<String?>? notes,
  }) {
    return ReadingRecordsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      progressPercent: progressPercent ?? this.progressPercent,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      personalRating: personalRating ?? this.personalRating,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<int>(progressPercent.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (finishDate.present) {
      map['finish_date'] = Variable<DateTime>(finishDate.value);
    }
    if (lastReadDate.present) {
      map['last_read_date'] = Variable<DateTime>(lastReadDate.value);
    }
    if (personalRating.present) {
      map['personal_rating'] = Variable<double>(personalRating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('startDate: $startDate, ')
          ..write('finishDate: $finishDate, ')
          ..write('lastReadDate: $lastReadDate, ')
          ..write('personalRating: $personalRating, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadingRecordsTable readingRecords = $ReadingRecordsTable(this);
  late final Index booksNormalizedIsbnIdx = Index(
    'books_normalized_isbn_idx',
    'CREATE UNIQUE INDEX books_normalized_isbn_idx ON books (normalized_isbn)',
  );
  late final Index readingRecordsBookIdx = Index(
    'reading_records_book_idx',
    'CREATE UNIQUE INDEX reading_records_book_idx ON reading_records (book_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    readingRecords,
    booksNormalizedIsbnIdx,
    readingRecordsBookIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  Value<List<String>?> authors,
  Value<String?> author,
  Value<String?> description,
  Value<String?> summary,
  Value<String?> genres,
  Value<String?> isbn,
  Value<String?> normalizedIsbn,
  Value<String?> publisher,
  Value<DateTime?> publicationDate,
  Value<int?> publishedYear,
  Value<int?> pageCount,
  Value<String?> coverAssetKey,
  Value<String?> coverUrl,
  Value<String?> externalCatalogId,
  Value<String?> externalSourceUrl,
  Value<bool> isInWishlist,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<List<String>?> authors,
  Value<String?> author,
  Value<String?> description,
  Value<String?> summary,
  Value<String?> genres,
  Value<String?> isbn,
  Value<String?> normalizedIsbn,
  Value<String?> publisher,
  Value<DateTime?> publicationDate,
  Value<int?> publishedYear,
  Value<int?> pageCount,
  Value<String?> coverAssetKey,
  Value<String?> coverUrl,
  Value<String?> externalCatalogId,
  Value<String?> externalSourceUrl,
  Value<bool> isInWishlist,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReadingRecordsTable, List<ReadingRecordRow>>
  _readingRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingRecords,
    aliasName: 'books__id__reading_records__book_id',
  );

  $$ReadingRecordsTableProcessedTableManager get readingRecordsRefs {
    final manager = $$ReadingRecordsTableTableManager(
      $_db,
      $_db.readingRecords,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedIsbn => $composableBuilder(
    column: $table.normalizedIsbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishedYear => $composableBuilder(
    column: $table.publishedYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverAssetKey => $composableBuilder(
    column: $table.coverAssetKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalCatalogId => $composableBuilder(
    column: $table.externalCatalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalSourceUrl => $composableBuilder(
    column: $table.externalSourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInWishlist => $composableBuilder(
    column: $table.isInWishlist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readingRecordsRefs(
    Expression<bool> Function($$ReadingRecordsTableFilterComposer f) f,
  ) {
    final $$ReadingRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingRecords,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingRecordsTableFilterComposer(
            $db: $db,
            $table: $db.readingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedIsbn => $composableBuilder(
    column: $table.normalizedIsbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishedYear => $composableBuilder(
    column: $table.publishedYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverAssetKey => $composableBuilder(
    column: $table.coverAssetKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalCatalogId => $composableBuilder(
    column: $table.externalCatalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalSourceUrl => $composableBuilder(
    column: $table.externalSourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInWishlist => $composableBuilder(
    column: $table.isInWishlist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get normalizedIsbn => $composableBuilder(
    column: $table.normalizedIsbn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<DateTime> get publicationDate => $composableBuilder(
    column: $table.publicationDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get publishedYear => $composableBuilder(
    column: $table.publishedYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get coverAssetKey => $composableBuilder(
    column: $table.coverAssetKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get externalCatalogId => $composableBuilder(
    column: $table.externalCatalogId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get externalSourceUrl => $composableBuilder(
    column: $table.externalSourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInWishlist => $composableBuilder(
    column: $table.isInWishlist,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> readingRecordsRefs<T extends Object>(
    Expression<T> Function($$ReadingRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReadingRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingRecords,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, $$BooksTableReferences),
          BookRow,
          PrefetchHooks Function({bool readingRecordsRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<List<String>?> authors = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> normalizedIsbn = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<DateTime?> publicationDate = const Value.absent(),
                Value<int?> publishedYear = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> coverAssetKey = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> externalCatalogId = const Value.absent(),
                Value<String?> externalSourceUrl = const Value.absent(),
                Value<bool> isInWishlist = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                authors: authors,
                author: author,
                description: description,
                summary: summary,
                genres: genres,
                isbn: isbn,
                normalizedIsbn: normalizedIsbn,
                publisher: publisher,
                publicationDate: publicationDate,
                publishedYear: publishedYear,
                pageCount: pageCount,
                coverAssetKey: coverAssetKey,
                coverUrl: coverUrl,
                externalCatalogId: externalCatalogId,
                externalSourceUrl: externalSourceUrl,
                isInWishlist: isInWishlist,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<List<String>?> authors = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> normalizedIsbn = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<DateTime?> publicationDate = const Value.absent(),
                Value<int?> publishedYear = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> coverAssetKey = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> externalCatalogId = const Value.absent(),
                Value<String?> externalSourceUrl = const Value.absent(),
                Value<bool> isInWishlist = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                authors: authors,
                author: author,
                description: description,
                summary: summary,
                genres: genres,
                isbn: isbn,
                normalizedIsbn: normalizedIsbn,
                publisher: publisher,
                publicationDate: publicationDate,
                publishedYear: publishedYear,
                pageCount: pageCount,
                coverAssetKey: coverAssetKey,
                coverUrl: coverUrl,
                externalCatalogId: externalCatalogId,
                externalSourceUrl: externalSourceUrl,
                isInWishlist: isInWishlist,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, BookRow>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({readingRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (readingRecordsRefs) db.readingRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingRecordsRefs)
                    await $_getPrefetchedData<
                      BookRow,
                      $BooksTable,
                      ReadingRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences
                          ._readingRecordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$BooksTableReferences(
                        db,
                        table,
                        p0,
                      ).readingRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, $$BooksTableReferences),
      BookRow,
      PrefetchHooks Function({bool readingRecordsRefs})
    >;
typedef $$ReadingRecordsTableCreateCompanionBuilder =
    ReadingRecordsCompanion Function({
      Value<int> id,
      required int bookId,
      Value<String> status,
      Value<int?> currentPage,
      Value<int?> progressPercent,
      Value<DateTime?> startDate,
      Value<DateTime?> finishDate,
      Value<DateTime> lastReadDate,
      Value<double?> personalRating,
      Value<String?> notes,
    });
typedef $$ReadingRecordsTableUpdateCompanionBuilder =
    ReadingRecordsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<String> status,
      Value<int?> currentPage,
      Value<int?> progressPercent,
      Value<DateTime?> startDate,
      Value<DateTime?> finishDate,
      Value<DateTime> lastReadDate,
      Value<double?> personalRating,
      Value<String?> notes,
    });

final class $$ReadingRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReadingRecordsTable, ReadingRecordRow> {
  $$ReadingRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_records__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingRecordsTable> {
  $$ReadingRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingRecordsTable> {
  $$ReadingRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingRecordsTable> {
  $$ReadingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get finishDate => $composableBuilder(
    column: $table.finishDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get personalRating => $composableBuilder(
    column: $table.personalRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingRecordsTable,
          ReadingRecordRow,
          $$ReadingRecordsTableFilterComposer,
          $$ReadingRecordsTableOrderingComposer,
          $$ReadingRecordsTableAnnotationComposer,
          $$ReadingRecordsTableCreateCompanionBuilder,
          $$ReadingRecordsTableUpdateCompanionBuilder,
          (ReadingRecordRow, $$ReadingRecordsTableReferences),
          ReadingRecordRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingRecordsTableTableManager(
    _$AppDatabase db,
    $ReadingRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<int?> progressPercent = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> finishDate = const Value.absent(),
                Value<DateTime> lastReadDate = const Value.absent(),
                Value<double?> personalRating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ReadingRecordsCompanion(
                id: id,
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                progressPercent: progressPercent,
                startDate: startDate,
                finishDate: finishDate,
                lastReadDate: lastReadDate,
                personalRating: personalRating,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                Value<String> status = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<int?> progressPercent = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> finishDate = const Value.absent(),
                Value<DateTime> lastReadDate = const Value.absent(),
                Value<double?> personalRating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ReadingRecordsCompanion.insert(
                id: id,
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                progressPercent: progressPercent,
                startDate: startDate,
                finishDate: finishDate,
                lastReadDate: lastReadDate,
                personalRating: personalRating,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingRecordsTable, ReadingRecordRow>(table),
                  $$ReadingRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingRecordsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingRecordsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingRecordsTable,
      ReadingRecordRow,
      $$ReadingRecordsTableFilterComposer,
      $$ReadingRecordsTableOrderingComposer,
      $$ReadingRecordsTableAnnotationComposer,
      $$ReadingRecordsTableCreateCompanionBuilder,
      $$ReadingRecordsTableUpdateCompanionBuilder,
      (ReadingRecordRow, $$ReadingRecordsTableReferences),
      ReadingRecordRow,
      PrefetchHooks Function({bool bookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadingRecordsTableTableManager get readingRecords =>
      $$ReadingRecordsTableTableManager(_db, _db.readingRecords);
}
