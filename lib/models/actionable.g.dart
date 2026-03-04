// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actionable.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActionableCollection on Isar {
  IsarCollection<Actionable> get actionables => this.collection();
}

const ActionableSchema = CollectionSchema(
  name: r'Actionable',
  id: -1774719983432608373,
  properties: {
    r'assignedAt': PropertySchema(
      id: 0,
      name: r'assignedAt',
      type: IsarType.dateTime,
    ),
    r'assignedBy': PropertySchema(
      id: 1,
      name: r'assignedBy',
      type: IsarType.string,
    ),
    r'assignee': PropertySchema(
      id: 2,
      name: r'assignee',
      type: IsarType.string,
    ),
    r'audioNoteUrl': PropertySchema(
      id: 3,
      name: r'audioNoteUrl',
      type: IsarType.string,
    ),
    r'conversationId': PropertySchema(
      id: 4,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'customFieldsData': PropertySchema(
      id: 6,
      name: r'customFieldsData',
      type: IsarType.string,
    ),
    r'dueDate': PropertySchema(
      id: 7,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'isCompleted': PropertySchema(
      id: 8,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'title': PropertySchema(
      id: 9,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'uuid': PropertySchema(
      id: 11,
      name: r'uuid',
      type: IsarType.string,
    )
  },
  estimateSize: _actionableEstimateSize,
  serialize: _actionableSerialize,
  deserialize: _actionableDeserialize,
  deserializeProp: _actionableDeserializeProp,
  idName: r'id',
  indexes: {
    r'uuid': IndexSchema(
      id: 2134397340427724972,
      name: r'uuid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _actionableGetId,
  getLinks: _actionableGetLinks,
  attach: _actionableAttach,
  version: '3.1.0+1',
);

int _actionableEstimateSize(
  Actionable object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.assignedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.assignee;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.audioNoteUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.conversationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.customFieldsData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.uuid.length * 3;
  return bytesCount;
}

void _actionableSerialize(
  Actionable object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.assignedAt);
  writer.writeString(offsets[1], object.assignedBy);
  writer.writeString(offsets[2], object.assignee);
  writer.writeString(offsets[3], object.audioNoteUrl);
  writer.writeString(offsets[4], object.conversationId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.customFieldsData);
  writer.writeDateTime(offsets[7], object.dueDate);
  writer.writeBool(offsets[8], object.isCompleted);
  writer.writeString(offsets[9], object.title);
  writer.writeDateTime(offsets[10], object.updatedAt);
  writer.writeString(offsets[11], object.uuid);
}

Actionable _actionableDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Actionable();
  object.assignedAt = reader.readDateTimeOrNull(offsets[0]);
  object.assignedBy = reader.readStringOrNull(offsets[1]);
  object.assignee = reader.readStringOrNull(offsets[2]);
  object.audioNoteUrl = reader.readStringOrNull(offsets[3]);
  object.conversationId = reader.readStringOrNull(offsets[4]);
  object.createdAt = reader.readDateTimeOrNull(offsets[5]);
  object.customFieldsData = reader.readStringOrNull(offsets[6]);
  object.dueDate = reader.readDateTimeOrNull(offsets[7]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[8]);
  object.title = reader.readString(offsets[9]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[10]);
  object.uuid = reader.readString(offsets[11]);
  return object;
}

P _actionableDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _actionableGetId(Actionable object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _actionableGetLinks(Actionable object) {
  return [];
}

void _actionableAttach(IsarCollection<dynamic> col, Id id, Actionable object) {
  object.id = id;
}

extension ActionableByIndex on IsarCollection<Actionable> {
  Future<Actionable?> getByUuid(String uuid) {
    return getByIndex(r'uuid', [uuid]);
  }

  Actionable? getByUuidSync(String uuid) {
    return getByIndexSync(r'uuid', [uuid]);
  }

  Future<bool> deleteByUuid(String uuid) {
    return deleteByIndex(r'uuid', [uuid]);
  }

  bool deleteByUuidSync(String uuid) {
    return deleteByIndexSync(r'uuid', [uuid]);
  }

  Future<List<Actionable?>> getAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uuid', values);
  }

  List<Actionable?> getAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uuid', values);
  }

  Future<int> deleteAllByUuid(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uuid', values);
  }

  int deleteAllByUuidSync(List<String> uuidValues) {
    final values = uuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uuid', values);
  }

  Future<Id> putByUuid(Actionable object) {
    return putByIndex(r'uuid', object);
  }

  Id putByUuidSync(Actionable object, {bool saveLinks = true}) {
    return putByIndexSync(r'uuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUuid(List<Actionable> objects) {
    return putAllByIndex(r'uuid', objects);
  }

  List<Id> putAllByUuidSync(List<Actionable> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uuid', objects, saveLinks: saveLinks);
  }
}

extension ActionableQueryWhereSort
    on QueryBuilder<Actionable, Actionable, QWhere> {
  QueryBuilder<Actionable, Actionable, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ActionableQueryWhere
    on QueryBuilder<Actionable, Actionable, QWhereClause> {
  QueryBuilder<Actionable, Actionable, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> uuidEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uuid',
        value: [uuid],
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterWhereClause> uuidNotEqualTo(
      String uuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [uuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uuid',
              lower: [],
              upper: [uuid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ActionableQueryFilter
    on QueryBuilder<Actionable, Actionable, QFilterCondition> {
  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assignedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assignedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignedBy',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignedBy',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assignedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assignedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assignedByMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assignedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assignee',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assigneeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assignee',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assigneeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assigneeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignee',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> assigneeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignee',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assigneeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignee',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      assigneeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignee',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioNoteUrl',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioNoteUrl',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioNoteUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioNoteUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioNoteUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioNoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      audioNoteUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioNoteUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'conversationId',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'conversationId',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> createdAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'customFieldsData',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'customFieldsData',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customFieldsData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customFieldsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customFieldsData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customFieldsData',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      customFieldsDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customFieldsData',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> dueDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uuid',
        value: '',
      ));
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterFilterCondition> uuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uuid',
        value: '',
      ));
    });
  }
}

extension ActionableQueryObject
    on QueryBuilder<Actionable, Actionable, QFilterCondition> {}

extension ActionableQueryLinks
    on QueryBuilder<Actionable, Actionable, QFilterCondition> {}

extension ActionableQuerySortBy
    on QueryBuilder<Actionable, Actionable, QSortBy> {
  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssignee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignee', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAssigneeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignee', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAudioNoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioNoteUrl', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByAudioNoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioNoteUrl', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByCustomFieldsData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsData', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy>
      sortByCustomFieldsDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsData', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> sortByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ActionableQuerySortThenBy
    on QueryBuilder<Actionable, Actionable, QSortThenBy> {
  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssignee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignee', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAssigneeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignee', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAudioNoteUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioNoteUrl', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByAudioNoteUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioNoteUrl', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByCustomFieldsData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsData', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy>
      thenByCustomFieldsDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customFieldsData', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.asc);
    });
  }

  QueryBuilder<Actionable, Actionable, QAfterSortBy> thenByUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uuid', Sort.desc);
    });
  }
}

extension ActionableQueryWhereDistinct
    on QueryBuilder<Actionable, Actionable, QDistinct> {
  QueryBuilder<Actionable, Actionable, QDistinct> distinctByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedAt');
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByAssignedBy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByAssignee(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignee', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByAudioNoteUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioNoteUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByConversationId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByCustomFieldsData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customFieldsData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<Actionable, Actionable, QDistinct> distinctByUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uuid', caseSensitive: caseSensitive);
    });
  }
}

extension ActionableQueryProperty
    on QueryBuilder<Actionable, Actionable, QQueryProperty> {
  QueryBuilder<Actionable, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Actionable, DateTime?, QQueryOperations> assignedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedAt');
    });
  }

  QueryBuilder<Actionable, String?, QQueryOperations> assignedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBy');
    });
  }

  QueryBuilder<Actionable, String?, QQueryOperations> assigneeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignee');
    });
  }

  QueryBuilder<Actionable, String?, QQueryOperations> audioNoteUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioNoteUrl');
    });
  }

  QueryBuilder<Actionable, String?, QQueryOperations> conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<Actionable, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Actionable, String?, QQueryOperations>
      customFieldsDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customFieldsData');
    });
  }

  QueryBuilder<Actionable, DateTime?, QQueryOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<Actionable, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Actionable, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Actionable, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<Actionable, String, QQueryOperations> uuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uuid');
    });
  }
}
