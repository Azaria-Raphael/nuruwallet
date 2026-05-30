// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionEntriesTable extends TransactionEntries
    with TableInfo<$TransactionEntriesTable, TransactionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionEntriesTable.$convertertype);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptImagePathMeta = const VerificationMeta(
    'receiptImagePath',
  );
  @override
  late final GeneratedColumn<String> receiptImagePath = GeneratedColumn<String>(
    'receipt_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceIntervalMeta =
      const VerificationMeta('recurrenceInterval');
  @override
  late final GeneratedColumn<String> recurrenceInterval =
      GeneratedColumn<String>(
        'recurrence_interval',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TZS'),
  );
  static const VerificationMeta _originalAmountMeta = const VerificationMeta(
    'originalAmount',
  );
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
    'original_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    type,
    categoryId,
    accountId,
    date,
    note,
    receiptImagePath,
    isRecurring,
    recurrenceInterval,
    currencyCode,
    originalAmount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('receipt_image_path')) {
      context.handle(
        _receiptImagePathMeta,
        receiptImagePath.isAcceptableOrUnknown(
          data['receipt_image_path']!,
          _receiptImagePathMeta,
        ),
      );
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_interval')) {
      context.handle(
        _recurrenceIntervalMeta,
        recurrenceInterval.isAcceptableOrUnknown(
          data['recurrence_interval']!,
          _recurrenceIntervalMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('original_amount')) {
      context.handle(
        _originalAmountMeta,
        originalAmount.isAcceptableOrUnknown(
          data['original_amount']!,
          _originalAmountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: $TransactionEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      receiptImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_image_path'],
      ),
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      recurrenceInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_interval'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      originalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_amount'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionEntriesTable createAlias(String alias) {
    return $TransactionEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final DateTime date;
  final String? note;
  final String? receiptImagePath;
  final bool isRecurring;
  final String? recurrenceInterval;
  final String currencyCode;
  final double? originalAmount;
  final DateTime createdAt;
  const TransactionEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.note,
    this.receiptImagePath,
    required this.isRecurring,
    this.recurrenceInterval,
    required this.currencyCode,
    this.originalAmount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    {
      map['type'] = Variable<int>(
        $TransactionEntriesTable.$convertertype.toSql(type),
      );
    }
    map['category_id'] = Variable<String>(categoryId);
    map['account_id'] = Variable<String>(accountId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || receiptImagePath != null) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceInterval != null) {
      map['recurrence_interval'] = Variable<String>(recurrenceInterval);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || originalAmount != null) {
      map['original_amount'] = Variable<double>(originalAmount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionEntriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionEntriesCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      receiptImagePath: receiptImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptImagePath),
      isRecurring: Value(isRecurring),
      recurrenceInterval: recurrenceInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceInterval),
      currencyCode: Value(currencyCode),
      originalAmount: originalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmount),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: $TransactionEntriesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      receiptImagePath: serializer.fromJson<String?>(json['receiptImagePath']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceInterval: serializer.fromJson<String?>(
        json['recurrenceInterval'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      originalAmount: serializer.fromJson<double?>(json['originalAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<int>(
        $TransactionEntriesTable.$convertertype.toJson(type),
      ),
      'categoryId': serializer.toJson<String>(categoryId),
      'accountId': serializer.toJson<String>(accountId),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'receiptImagePath': serializer.toJson<String?>(receiptImagePath),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceInterval': serializer.toJson<String?>(recurrenceInterval),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'originalAmount': serializer.toJson<double?>(originalAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionEntry copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    DateTime? date,
    Value<String?> note = const Value.absent(),
    Value<String?> receiptImagePath = const Value.absent(),
    bool? isRecurring,
    Value<String?> recurrenceInterval = const Value.absent(),
    String? currencyCode,
    Value<double?> originalAmount = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionEntry(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId ?? this.accountId,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    receiptImagePath: receiptImagePath.present
        ? receiptImagePath.value
        : this.receiptImagePath,
    isRecurring: isRecurring ?? this.isRecurring,
    recurrenceInterval: recurrenceInterval.present
        ? recurrenceInterval.value
        : this.recurrenceInterval,
    currencyCode: currencyCode ?? this.currencyCode,
    originalAmount: originalAmount.present
        ? originalAmount.value
        : this.originalAmount,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionEntry copyWithCompanion(TransactionEntriesCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      receiptImagePath: data.receiptImagePath.present
          ? data.receiptImagePath.value
          : this.receiptImagePath,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      recurrenceInterval: data.recurrenceInterval.present
          ? data.recurrenceInterval.value
          : this.recurrenceInterval,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    type,
    categoryId,
    accountId,
    date,
    note,
    receiptImagePath,
    isRecurring,
    recurrenceInterval,
    currencyCode,
    originalAmount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.date == this.date &&
          other.note == this.note &&
          other.receiptImagePath == this.receiptImagePath &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceInterval == this.recurrenceInterval &&
          other.currencyCode == this.currencyCode &&
          other.originalAmount == this.originalAmount &&
          other.createdAt == this.createdAt);
}

class TransactionEntriesCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<double> amount;
  final Value<TransactionType> type;
  final Value<String> categoryId;
  final Value<String> accountId;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<String?> receiptImagePath;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceInterval;
  final Value<String> currencyCode;
  final Value<double?> originalAmount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionEntriesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionEntriesCompanion.insert({
    required String id,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String accountId,
    required DateTime date,
    this.note = const Value.absent(),
    this.receiptImagePath = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceInterval = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.originalAmount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       type = Value(type),
       categoryId = Value(categoryId),
       accountId = Value(accountId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<int>? type,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? receiptImagePath,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceInterval,
    Expression<String>? currencyCode,
    Expression<double>? originalAmount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (receiptImagePath != null) 'receipt_image_path': receiptImagePath,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionEntriesCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<TransactionType>? type,
    Value<String>? categoryId,
    Value<String>? accountId,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<String?>? receiptImagePath,
    Value<bool>? isRecurring,
    Value<String?>? recurrenceInterval,
    Value<String>? currencyCode,
    Value<double?>? originalAmount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionEntriesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      currencyCode: currencyCode ?? this.currencyCode,
      originalAmount: originalAmount ?? this.originalAmount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $TransactionEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (receiptImagePath.present) {
      map['receipt_image_path'] = Variable<String>(receiptImagePath.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceInterval.present) {
      map['recurrence_interval'] = Variable<String>(recurrenceInterval.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('receiptImagePath: $receiptImagePath, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceInterval: $recurrenceInterval, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryEntriesTable extends CategoryEntries
    with TableInfo<$CategoryEntriesTable, CategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<double> monthlyLimit = GeneratedColumn<double>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _categoryTypeMeta = const VerificationMeta(
    'categoryType',
  );
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expense'),
  );
  static const VerificationMeta _parentCategoryIdMeta = const VerificationMeta(
    'parentCategoryId',
  );
  @override
  late final GeneratedColumn<String> parentCategoryId = GeneratedColumn<String>(
    'parent_category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rolloverEnabledMeta = const VerificationMeta(
    'rolloverEnabled',
  );
  @override
  late final GeneratedColumn<bool> rolloverEnabled = GeneratedColumn<bool>(
    'rollover_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    colorValue,
    monthlyLimit,
    categoryType,
    parentCategoryId,
    isDefault,
    rolloverEnabled,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    }
    if (data.containsKey('category_type')) {
      context.handle(
        _categoryTypeMeta,
        categoryType.isAcceptableOrUnknown(
          data['category_type']!,
          _categoryTypeMeta,
        ),
      );
    }
    if (data.containsKey('parent_category_id')) {
      context.handle(
        _parentCategoryIdMeta,
        parentCategoryId.isAcceptableOrUnknown(
          data['parent_category_id']!,
          _parentCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('rollover_enabled')) {
      context.handle(
        _rolloverEnabledMeta,
        rolloverEnabled.isAcceptableOrUnknown(
          data['rollover_enabled']!,
          _rolloverEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      monthlyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_limit'],
      )!,
      categoryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_type'],
      )!,
      parentCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_category_id'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      rolloverEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover_enabled'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoryEntriesTable createAlias(String alias) {
    return $CategoryEntriesTable(attachedDatabase, alias);
  }
}

class CategoryEntry extends DataClass implements Insertable<CategoryEntry> {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final double monthlyLimit;
  final String categoryType;
  final String? parentCategoryId;
  final bool isDefault;
  final bool rolloverEnabled;
  final int sortOrder;
  const CategoryEntry({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.monthlyLimit,
    required this.categoryType,
    this.parentCategoryId,
    required this.isDefault,
    required this.rolloverEnabled,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color_value'] = Variable<int>(colorValue);
    map['monthly_limit'] = Variable<double>(monthlyLimit);
    map['category_type'] = Variable<String>(categoryType);
    if (!nullToAbsent || parentCategoryId != null) {
      map['parent_category_id'] = Variable<String>(parentCategoryId);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['rollover_enabled'] = Variable<bool>(rolloverEnabled);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return CategoryEntriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      colorValue: Value(colorValue),
      monthlyLimit: Value(monthlyLimit),
      categoryType: Value(categoryType),
      parentCategoryId: parentCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCategoryId),
      isDefault: Value(isDefault),
      rolloverEnabled: Value(rolloverEnabled),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      monthlyLimit: serializer.fromJson<double>(json['monthlyLimit']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      parentCategoryId: serializer.fromJson<String?>(json['parentCategoryId']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      rolloverEnabled: serializer.fromJson<bool>(json['rolloverEnabled']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'colorValue': serializer.toJson<int>(colorValue),
      'monthlyLimit': serializer.toJson<double>(monthlyLimit),
      'categoryType': serializer.toJson<String>(categoryType),
      'parentCategoryId': serializer.toJson<String?>(parentCategoryId),
      'isDefault': serializer.toJson<bool>(isDefault),
      'rolloverEnabled': serializer.toJson<bool>(rolloverEnabled),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryEntry copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    double? monthlyLimit,
    String? categoryType,
    Value<String?> parentCategoryId = const Value.absent(),
    bool? isDefault,
    bool? rolloverEnabled,
    int? sortOrder,
  }) => CategoryEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorValue: colorValue ?? this.colorValue,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    categoryType: categoryType ?? this.categoryType,
    parentCategoryId: parentCategoryId.present
        ? parentCategoryId.value
        : this.parentCategoryId,
    isDefault: isDefault ?? this.isDefault,
    rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryEntry copyWithCompanion(CategoryEntriesCompanion data) {
    return CategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      monthlyLimit: data.monthlyLimit.present
          ? data.monthlyLimit.value
          : this.monthlyLimit,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      rolloverEnabled: data.rolloverEnabled.present
          ? data.rolloverEnabled.value
          : this.rolloverEnabled,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('categoryType: $categoryType, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('isDefault: $isDefault, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconName,
    colorValue,
    monthlyLimit,
    categoryType,
    parentCategoryId,
    isDefault,
    rolloverEnabled,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.colorValue == this.colorValue &&
          other.monthlyLimit == this.monthlyLimit &&
          other.categoryType == this.categoryType &&
          other.parentCategoryId == this.parentCategoryId &&
          other.isDefault == this.isDefault &&
          other.rolloverEnabled == this.rolloverEnabled &&
          other.sortOrder == this.sortOrder);
}

class CategoryEntriesCompanion extends UpdateCompanion<CategoryEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> colorValue;
  final Value<double> monthlyLimit;
  final Value<String> categoryType;
  final Value<String?> parentCategoryId;
  final Value<bool> isDefault;
  final Value<bool> rolloverEnabled;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoryEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rolloverEnabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryEntriesCompanion.insert({
    required String id,
    required String name,
    required String iconName,
    required int colorValue,
    this.monthlyLimit = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rolloverEnabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconName = Value(iconName),
       colorValue = Value(colorValue);
  static Insertable<CategoryEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? colorValue,
    Expression<double>? monthlyLimit,
    Expression<String>? categoryType,
    Expression<String>? parentCategoryId,
    Expression<bool>? isDefault,
    Expression<bool>? rolloverEnabled,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (colorValue != null) 'color_value': colorValue,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (categoryType != null) 'category_type': categoryType,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (isDefault != null) 'is_default': isDefault,
      if (rolloverEnabled != null) 'rollover_enabled': rolloverEnabled,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<int>? colorValue,
    Value<double>? monthlyLimit,
    Value<String>? categoryType,
    Value<String?>? parentCategoryId,
    Value<bool>? isDefault,
    Value<bool>? rolloverEnabled,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoryEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      categoryType: categoryType ?? this.categoryType,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      isDefault: isDefault ?? this.isDefault,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<double>(monthlyLimit.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<String>(parentCategoryId.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rolloverEnabled.present) {
      map['rollover_enabled'] = Variable<bool>(rolloverEnabled.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('categoryType: $categoryType, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('isDefault: $isDefault, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountEntriesTable extends AccountEntries
    with TableInfo<$AccountEntriesTable, AccountEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountEntriesTable.$convertertype);
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    balance,
    colorValue,
    isDefault,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AccountEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountEntriesTable createAlias(String alias) {
    return $AccountEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, int, int> $convertertype =
      const EnumIndexConverter<AccountType>(AccountType.values);
}

class AccountEntry extends DataClass implements Insertable<AccountEntry> {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final int colorValue;
  final bool isDefault;
  final DateTime createdAt;
  const AccountEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.colorValue,
    required this.isDefault,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<int>(
        $AccountEntriesTable.$convertertype.toSql(type),
      );
    }
    map['balance'] = Variable<double>(balance);
    map['color_value'] = Variable<int>(colorValue);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountEntriesCompanion toCompanion(bool nullToAbsent) {
    return AccountEntriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      colorValue: Value(colorValue),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory AccountEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $AccountEntriesTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      balance: serializer.fromJson<double>(json['balance']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(
        $AccountEntriesTable.$convertertype.toJson(type),
      ),
      'balance': serializer.toJson<double>(balance),
      'colorValue': serializer.toJson<int>(colorValue),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AccountEntry copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    int? colorValue,
    bool? isDefault,
    DateTime? createdAt,
  }) => AccountEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    colorValue: colorValue ?? this.colorValue,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountEntry copyWithCompanion(AccountEntriesCompanion data) {
    return AccountEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, balance, colorValue, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.colorValue == this.colorValue &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class AccountEntriesCompanion extends UpdateCompanion<AccountEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<double> balance;
  final Value<int> colorValue;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountEntriesCompanion.insert({
    required String id,
    required String name,
    required AccountType type,
    this.balance = const Value.absent(),
    required int colorValue,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       colorValue = Value(colorValue),
       createdAt = Value(createdAt);
  static Insertable<AccountEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<double>? balance,
    Expression<int>? colorValue,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (colorValue != null) 'color_value': colorValue,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<AccountType>? type,
    Value<double>? balance,
    Value<int>? colorValue,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $AccountEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalEntriesTable extends SavingsGoalEntries
    with TableInfo<$SavingsGoalEntriesTable, SavingsGoalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentAmountMeta = const VerificationMeta(
    'currentAmount',
  );
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
    'current_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    targetAmount,
    currentAmount,
    deadline,
    note,
    isPaused,
    isCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
        _currentAmountMeta,
        currentAmount.isAcceptableOrUnknown(
          data['current_amount']!,
          _currentAmountMeta,
        ),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      currentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_amount'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavingsGoalEntriesTable createAlias(String alias) {
    return $SavingsGoalEntriesTable(attachedDatabase, alias);
  }
}

class SavingsGoalEntry extends DataClass
    implements Insertable<SavingsGoalEntry> {
  final String id;
  final String name;
  final String iconName;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? note;
  final bool isPaused;
  final bool isCompleted;
  final DateTime createdAt;
  const SavingsGoalEntry({
    required this.id,
    required this.name,
    required this.iconName,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.note,
    required this.isPaused,
    required this.isCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    map['deadline'] = Variable<DateTime>(deadline);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingsGoalEntriesCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalEntriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      deadline: Value(deadline),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isPaused: Value(isPaused),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory SavingsGoalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      deadline: serializer.fromJson<DateTime>(json['deadline']),
      note: serializer.fromJson<String?>(json['note']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'deadline': serializer.toJson<DateTime>(deadline),
      'note': serializer.toJson<String?>(note),
      'isPaused': serializer.toJson<bool>(isPaused),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingsGoalEntry copyWith({
    String? id,
    String? name,
    String? iconName,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    Value<String?> note = const Value.absent(),
    bool? isPaused,
    bool? isCompleted,
    DateTime? createdAt,
  }) => SavingsGoalEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    targetAmount: targetAmount ?? this.targetAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    deadline: deadline ?? this.deadline,
    note: note.present ? note.value : this.note,
    isPaused: isPaused ?? this.isPaused,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  SavingsGoalEntry copyWithCompanion(SavingsGoalEntriesCompanion data) {
    return SavingsGoalEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      note: data.note.present ? data.note.value : this.note,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('note: $note, ')
          ..write('isPaused: $isPaused, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconName,
    targetAmount,
    currentAmount,
    deadline,
    note,
    isPaused,
    isCompleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.deadline == this.deadline &&
          other.note == this.note &&
          other.isPaused == this.isPaused &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class SavingsGoalEntriesCompanion extends UpdateCompanion<SavingsGoalEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<DateTime> deadline;
  final Value<String?> note;
  final Value<bool> isPaused;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavingsGoalEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.note = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalEntriesCompanion.insert({
    required String id,
    required String name,
    required String iconName,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    required DateTime deadline,
    this.note = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconName = Value(iconName),
       targetAmount = Value(targetAmount),
       deadline = Value(deadline),
       createdAt = Value(createdAt);
  static Insertable<SavingsGoalEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<DateTime>? deadline,
    Expression<String>? note,
    Expression<bool>? isPaused,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline,
      if (note != null) 'note': note,
      if (isPaused != null) 'is_paused': isPaused,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<double>? targetAmount,
    Value<double>? currentAmount,
    Value<DateTime>? deadline,
    Value<String?>? note,
    Value<bool>? isPaused,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('note: $note, ')
          ..write('isPaused: $isPaused, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRateCacheEntriesTable extends ExchangeRateCacheEntries
    with TableInfo<$ExchangeRateCacheEntriesTable, ExchangeRateCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRateCacheEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratesJsonMeta = const VerificationMeta(
    'ratesJson',
  );
  @override
  late final GeneratedColumn<String> ratesJson = GeneratedColumn<String>(
    'rates_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseCurrency,
    ratesJson,
    fetchedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rate_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('rates_json')) {
      context.handle(
        _ratesJsonMeta,
        ratesJson.isAcceptableOrUnknown(data['rates_json']!, _ratesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_ratesJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRateCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      ratesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rates_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $ExchangeRateCacheEntriesTable createAlias(String alias) {
    return $ExchangeRateCacheEntriesTable(attachedDatabase, alias);
  }
}

class ExchangeRateCacheEntry extends DataClass
    implements Insertable<ExchangeRateCacheEntry> {
  final int id;
  final String baseCurrency;
  final String ratesJson;
  final DateTime fetchedAt;
  final String source;
  const ExchangeRateCacheEntry({
    required this.id,
    required this.baseCurrency,
    required this.ratesJson,
    required this.fetchedAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['rates_json'] = Variable<String>(ratesJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  ExchangeRateCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRateCacheEntriesCompanion(
      id: Value(id),
      baseCurrency: Value(baseCurrency),
      ratesJson: Value(ratesJson),
      fetchedAt: Value(fetchedAt),
      source: Value(source),
    );
  }

  factory ExchangeRateCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateCacheEntry(
      id: serializer.fromJson<int>(json['id']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      ratesJson: serializer.fromJson<String>(json['ratesJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'ratesJson': serializer.toJson<String>(ratesJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'source': serializer.toJson<String>(source),
    };
  }

  ExchangeRateCacheEntry copyWith({
    int? id,
    String? baseCurrency,
    String? ratesJson,
    DateTime? fetchedAt,
    String? source,
  }) => ExchangeRateCacheEntry(
    id: id ?? this.id,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    ratesJson: ratesJson ?? this.ratesJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    source: source ?? this.source,
  );
  ExchangeRateCacheEntry copyWithCompanion(
    ExchangeRateCacheEntriesCompanion data,
  ) {
    return ExchangeRateCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      ratesJson: data.ratesJson.present ? data.ratesJson.value : this.ratesJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateCacheEntry(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('ratesJson: $ratesJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, baseCurrency, ratesJson, fetchedAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateCacheEntry &&
          other.id == this.id &&
          other.baseCurrency == this.baseCurrency &&
          other.ratesJson == this.ratesJson &&
          other.fetchedAt == this.fetchedAt &&
          other.source == this.source);
}

class ExchangeRateCacheEntriesCompanion
    extends UpdateCompanion<ExchangeRateCacheEntry> {
  final Value<int> id;
  final Value<String> baseCurrency;
  final Value<String> ratesJson;
  final Value<DateTime> fetchedAt;
  final Value<String> source;
  const ExchangeRateCacheEntriesCompanion({
    this.id = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.ratesJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.source = const Value.absent(),
  });
  ExchangeRateCacheEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String baseCurrency,
    required String ratesJson,
    required DateTime fetchedAt,
    required String source,
  }) : baseCurrency = Value(baseCurrency),
       ratesJson = Value(ratesJson),
       fetchedAt = Value(fetchedAt),
       source = Value(source);
  static Insertable<ExchangeRateCacheEntry> custom({
    Expression<int>? id,
    Expression<String>? baseCurrency,
    Expression<String>? ratesJson,
    Expression<DateTime>? fetchedAt,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (ratesJson != null) 'rates_json': ratesJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (source != null) 'source': source,
    });
  }

  ExchangeRateCacheEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? baseCurrency,
    Value<String>? ratesJson,
    Value<DateTime>? fetchedAt,
    Value<String>? source,
  }) {
    return ExchangeRateCacheEntriesCompanion(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      ratesJson: ratesJson ?? this.ratesJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (ratesJson.present) {
      map['rates_json'] = Variable<String>(ratesJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateCacheEntriesCompanion(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('ratesJson: $ratesJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionEntriesTable transactionEntries =
      $TransactionEntriesTable(this);
  late final $CategoryEntriesTable categoryEntries = $CategoryEntriesTable(
    this,
  );
  late final $AccountEntriesTable accountEntries = $AccountEntriesTable(this);
  late final $SavingsGoalEntriesTable savingsGoalEntries =
      $SavingsGoalEntriesTable(this);
  late final $ExchangeRateCacheEntriesTable exchangeRateCacheEntries =
      $ExchangeRateCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionEntries,
    categoryEntries,
    accountEntries,
    savingsGoalEntries,
    exchangeRateCacheEntries,
  ];
}

typedef $$TransactionEntriesTableCreateCompanionBuilder =
    TransactionEntriesCompanion Function({
      required String id,
      required double amount,
      required TransactionType type,
      required String categoryId,
      required String accountId,
      required DateTime date,
      Value<String?> note,
      Value<String?> receiptImagePath,
      Value<bool> isRecurring,
      Value<String?> recurrenceInterval,
      Value<String> currencyCode,
      Value<double?> originalAmount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TransactionEntriesTableUpdateCompanionBuilder =
    TransactionEntriesCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<TransactionType> type,
      Value<String> categoryId,
      Value<String> accountId,
      Value<DateTime> date,
      Value<String?> note,
      Value<String?> receiptImagePath,
      Value<bool> isRecurring,
      Value<String?> recurrenceInterval,
      Value<String> currencyCode,
      Value<double?> originalAmount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TransactionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get receiptImagePath => $composableBuilder(
    column: $table.receiptImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceInterval => $composableBuilder(
    column: $table.recurrenceInterval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry,
          $$TransactionEntriesTableFilterComposer,
          $$TransactionEntriesTableOrderingComposer,
          $$TransactionEntriesTableAnnotationComposer,
          $$TransactionEntriesTableCreateCompanionBuilder,
          $$TransactionEntriesTableUpdateCompanionBuilder,
          (
            TransactionEntry,
            BaseReferences<
              _$AppDatabase,
              $TransactionEntriesTable,
              TransactionEntry
            >,
          ),
          TransactionEntry,
          PrefetchHooks Function()
        > {
  $$TransactionEntriesTableTableManager(
    _$AppDatabase db,
    $TransactionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceInterval = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<double?> originalAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion(
                id: id,
                amount: amount,
                type: type,
                categoryId: categoryId,
                accountId: accountId,
                date: date,
                note: note,
                receiptImagePath: receiptImagePath,
                isRecurring: isRecurring,
                recurrenceInterval: recurrenceInterval,
                currencyCode: currencyCode,
                originalAmount: originalAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                required TransactionType type,
                required String categoryId,
                required String accountId,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<String?> receiptImagePath = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<String?> recurrenceInterval = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<double?> originalAmount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion.insert(
                id: id,
                amount: amount,
                type: type,
                categoryId: categoryId,
                accountId: accountId,
                date: date,
                note: note,
                receiptImagePath: receiptImagePath,
                isRecurring: isRecurring,
                recurrenceInterval: recurrenceInterval,
                currencyCode: currencyCode,
                originalAmount: originalAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionEntriesTable,
      TransactionEntry,
      $$TransactionEntriesTableFilterComposer,
      $$TransactionEntriesTableOrderingComposer,
      $$TransactionEntriesTableAnnotationComposer,
      $$TransactionEntriesTableCreateCompanionBuilder,
      $$TransactionEntriesTableUpdateCompanionBuilder,
      (
        TransactionEntry,
        BaseReferences<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry
        >,
      ),
      TransactionEntry,
      PrefetchHooks Function()
    >;
typedef $$CategoryEntriesTableCreateCompanionBuilder =
    CategoryEntriesCompanion Function({
      required String id,
      required String name,
      required String iconName,
      required int colorValue,
      Value<double> monthlyLimit,
      Value<String> categoryType,
      Value<String?> parentCategoryId,
      Value<bool> isDefault,
      Value<bool> rolloverEnabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoryEntriesTableUpdateCompanionBuilder =
    CategoryEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconName,
      Value<int> colorValue,
      Value<double> monthlyLimit,
      Value<String> categoryType,
      Value<String?> parentCategoryId,
      Value<bool> isDefault,
      Value<bool> rolloverEnabled,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CategoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryEntriesTable> {
  $$CategoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentCategoryId => $composableBuilder(
    column: $table.parentCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryEntriesTable,
          CategoryEntry,
          $$CategoryEntriesTableFilterComposer,
          $$CategoryEntriesTableOrderingComposer,
          $$CategoryEntriesTableAnnotationComposer,
          $$CategoryEntriesTableCreateCompanionBuilder,
          $$CategoryEntriesTableUpdateCompanionBuilder,
          (
            CategoryEntry,
            BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
          ),
          CategoryEntry,
          PrefetchHooks Function()
        > {
  $$CategoryEntriesTableTableManager(
    _$AppDatabase db,
    $CategoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<String?> parentCategoryId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> rolloverEnabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                monthlyLimit: monthlyLimit,
                categoryType: categoryType,
                parentCategoryId: parentCategoryId,
                isDefault: isDefault,
                rolloverEnabled: rolloverEnabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconName,
                required int colorValue,
                Value<double> monthlyLimit = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<String?> parentCategoryId = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> rolloverEnabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryEntriesCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                monthlyLimit: monthlyLimit,
                categoryType: categoryType,
                parentCategoryId: parentCategoryId,
                isDefault: isDefault,
                rolloverEnabled: rolloverEnabled,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryEntriesTable,
      CategoryEntry,
      $$CategoryEntriesTableFilterComposer,
      $$CategoryEntriesTableOrderingComposer,
      $$CategoryEntriesTableAnnotationComposer,
      $$CategoryEntriesTableCreateCompanionBuilder,
      $$CategoryEntriesTableUpdateCompanionBuilder,
      (
        CategoryEntry,
        BaseReferences<_$AppDatabase, $CategoryEntriesTable, CategoryEntry>,
      ),
      CategoryEntry,
      PrefetchHooks Function()
    >;
typedef $$AccountEntriesTableCreateCompanionBuilder =
    AccountEntriesCompanion Function({
      required String id,
      required String name,
      required AccountType type,
      Value<double> balance,
      required int colorValue,
      Value<bool> isDefault,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AccountEntriesTableUpdateCompanionBuilder =
    AccountEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<AccountType> type,
      Value<double> balance,
      Value<int> colorValue,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AccountEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountEntriesTable> {
  $$AccountEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountEntriesTable,
          AccountEntry,
          $$AccountEntriesTableFilterComposer,
          $$AccountEntriesTableOrderingComposer,
          $$AccountEntriesTableAnnotationComposer,
          $$AccountEntriesTableCreateCompanionBuilder,
          $$AccountEntriesTableUpdateCompanionBuilder,
          (
            AccountEntry,
            BaseReferences<_$AppDatabase, $AccountEntriesTable, AccountEntry>,
          ),
          AccountEntry,
          PrefetchHooks Function()
        > {
  $$AccountEntriesTableTableManager(
    _$AppDatabase db,
    $AccountEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountType> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion(
                id: id,
                name: name,
                type: type,
                balance: balance,
                colorValue: colorValue,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required AccountType type,
                Value<double> balance = const Value.absent(),
                required int colorValue,
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountEntriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                balance: balance,
                colorValue: colorValue,
                isDefault: isDefault,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountEntriesTable,
      AccountEntry,
      $$AccountEntriesTableFilterComposer,
      $$AccountEntriesTableOrderingComposer,
      $$AccountEntriesTableAnnotationComposer,
      $$AccountEntriesTableCreateCompanionBuilder,
      $$AccountEntriesTableUpdateCompanionBuilder,
      (
        AccountEntry,
        BaseReferences<_$AppDatabase, $AccountEntriesTable, AccountEntry>,
      ),
      AccountEntry,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalEntriesTableCreateCompanionBuilder =
    SavingsGoalEntriesCompanion Function({
      required String id,
      required String name,
      required String iconName,
      required double targetAmount,
      Value<double> currentAmount,
      required DateTime deadline,
      Value<String?> note,
      Value<bool> isPaused,
      Value<bool> isCompleted,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavingsGoalEntriesTableUpdateCompanionBuilder =
    SavingsGoalEntriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconName,
      Value<double> targetAmount,
      Value<double> currentAmount,
      Value<DateTime> deadline,
      Value<String?> note,
      Value<bool> isPaused,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavingsGoalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalEntriesTable> {
  $$SavingsGoalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalEntriesTable> {
  $$SavingsGoalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalEntriesTable> {
  $$SavingsGoalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentAmount => $composableBuilder(
    column: $table.currentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavingsGoalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalEntriesTable,
          SavingsGoalEntry,
          $$SavingsGoalEntriesTableFilterComposer,
          $$SavingsGoalEntriesTableOrderingComposer,
          $$SavingsGoalEntriesTableAnnotationComposer,
          $$SavingsGoalEntriesTableCreateCompanionBuilder,
          $$SavingsGoalEntriesTableUpdateCompanionBuilder,
          (
            SavingsGoalEntry,
            BaseReferences<
              _$AppDatabase,
              $SavingsGoalEntriesTable,
              SavingsGoalEntry
            >,
          ),
          SavingsGoalEntry,
          PrefetchHooks Function()
        > {
  $$SavingsGoalEntriesTableTableManager(
    _$AppDatabase db,
    $SavingsGoalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<double> currentAmount = const Value.absent(),
                Value<DateTime> deadline = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalEntriesCompanion(
                id: id,
                name: name,
                iconName: iconName,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                deadline: deadline,
                note: note,
                isPaused: isPaused,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconName,
                required double targetAmount,
                Value<double> currentAmount = const Value.absent(),
                required DateTime deadline,
                Value<String?> note = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalEntriesCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                deadline: deadline,
                note: note,
                isPaused: isPaused,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalEntriesTable,
      SavingsGoalEntry,
      $$SavingsGoalEntriesTableFilterComposer,
      $$SavingsGoalEntriesTableOrderingComposer,
      $$SavingsGoalEntriesTableAnnotationComposer,
      $$SavingsGoalEntriesTableCreateCompanionBuilder,
      $$SavingsGoalEntriesTableUpdateCompanionBuilder,
      (
        SavingsGoalEntry,
        BaseReferences<
          _$AppDatabase,
          $SavingsGoalEntriesTable,
          SavingsGoalEntry
        >,
      ),
      SavingsGoalEntry,
      PrefetchHooks Function()
    >;
typedef $$ExchangeRateCacheEntriesTableCreateCompanionBuilder =
    ExchangeRateCacheEntriesCompanion Function({
      Value<int> id,
      required String baseCurrency,
      required String ratesJson,
      required DateTime fetchedAt,
      required String source,
    });
typedef $$ExchangeRateCacheEntriesTableUpdateCompanionBuilder =
    ExchangeRateCacheEntriesCompanion Function({
      Value<int> id,
      Value<String> baseCurrency,
      Value<String> ratesJson,
      Value<DateTime> fetchedAt,
      Value<String> source,
    });

class $$ExchangeRateCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRateCacheEntriesTable> {
  $$ExchangeRateCacheEntriesTableFilterComposer({
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

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratesJson => $composableBuilder(
    column: $table.ratesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRateCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRateCacheEntriesTable> {
  $$ExchangeRateCacheEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratesJson => $composableBuilder(
    column: $table.ratesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRateCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRateCacheEntriesTable> {
  $$ExchangeRateCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratesJson =>
      $composableBuilder(column: $table.ratesJson, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ExchangeRateCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRateCacheEntriesTable,
          ExchangeRateCacheEntry,
          $$ExchangeRateCacheEntriesTableFilterComposer,
          $$ExchangeRateCacheEntriesTableOrderingComposer,
          $$ExchangeRateCacheEntriesTableAnnotationComposer,
          $$ExchangeRateCacheEntriesTableCreateCompanionBuilder,
          $$ExchangeRateCacheEntriesTableUpdateCompanionBuilder,
          (
            ExchangeRateCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $ExchangeRateCacheEntriesTable,
              ExchangeRateCacheEntry
            >,
          ),
          ExchangeRateCacheEntry,
          PrefetchHooks Function()
        > {
  $$ExchangeRateCacheEntriesTableTableManager(
    _$AppDatabase db,
    $ExchangeRateCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRateCacheEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExchangeRateCacheEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExchangeRateCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> ratesJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => ExchangeRateCacheEntriesCompanion(
                id: id,
                baseCurrency: baseCurrency,
                ratesJson: ratesJson,
                fetchedAt: fetchedAt,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String baseCurrency,
                required String ratesJson,
                required DateTime fetchedAt,
                required String source,
              }) => ExchangeRateCacheEntriesCompanion.insert(
                id: id,
                baseCurrency: baseCurrency,
                ratesJson: ratesJson,
                fetchedAt: fetchedAt,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRateCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRateCacheEntriesTable,
      ExchangeRateCacheEntry,
      $$ExchangeRateCacheEntriesTableFilterComposer,
      $$ExchangeRateCacheEntriesTableOrderingComposer,
      $$ExchangeRateCacheEntriesTableAnnotationComposer,
      $$ExchangeRateCacheEntriesTableCreateCompanionBuilder,
      $$ExchangeRateCacheEntriesTableUpdateCompanionBuilder,
      (
        ExchangeRateCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $ExchangeRateCacheEntriesTable,
          ExchangeRateCacheEntry
        >,
      ),
      ExchangeRateCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionEntriesTableTableManager get transactionEntries =>
      $$TransactionEntriesTableTableManager(_db, _db.transactionEntries);
  $$CategoryEntriesTableTableManager get categoryEntries =>
      $$CategoryEntriesTableTableManager(_db, _db.categoryEntries);
  $$AccountEntriesTableTableManager get accountEntries =>
      $$AccountEntriesTableTableManager(_db, _db.accountEntries);
  $$SavingsGoalEntriesTableTableManager get savingsGoalEntries =>
      $$SavingsGoalEntriesTableTableManager(_db, _db.savingsGoalEntries);
  $$ExchangeRateCacheEntriesTableTableManager get exchangeRateCacheEntries =>
      $$ExchangeRateCacheEntriesTableTableManager(
        _db,
        _db.exchangeRateCacheEntries,
      );
}
