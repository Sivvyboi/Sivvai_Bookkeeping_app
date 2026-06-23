// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_customer.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalCustomerCollection on Isar {
  IsarCollection<LocalCustomer> get localCustomers => this.collection();
}

const LocalCustomerSchema = CollectionSchema(
  name: r'LocalCustomer',
  id: 5387002492249476239,
  properties: {
    r'fullName': PropertySchema(
      id: 0,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'lastUsed': PropertySchema(
      id: 1,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'phoneNumber': PropertySchema(
      id: 2,
      name: r'phoneNumber',
      type: IsarType.string,
    ),
    r'relationType': PropertySchema(
      id: 3,
      name: r'relationType',
      type: IsarType.string,
    ),
    r'totalDebtAmount': PropertySchema(
      id: 4,
      name: r'totalDebtAmount',
      type: IsarType.double,
    )
  },
  estimateSize: _localCustomerEstimateSize,
  serialize: _localCustomerSerialize,
  deserialize: _localCustomerDeserialize,
  deserializeProp: _localCustomerDeserializeProp,
  idName: r'id',
  indexes: {
    r'fullName': IndexSchema(
      id: 8863244454116476334,
      name: r'fullName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fullName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localCustomerGetId,
  getLinks: _localCustomerGetLinks,
  attach: _localCustomerAttach,
  version: '3.1.0+1',
);

int _localCustomerEstimateSize(
  LocalCustomer object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fullName.length * 3;
  {
    final value = object.phoneNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.relationType.length * 3;
  return bytesCount;
}

void _localCustomerSerialize(
  LocalCustomer object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fullName);
  writer.writeDateTime(offsets[1], object.lastUsed);
  writer.writeString(offsets[2], object.phoneNumber);
  writer.writeString(offsets[3], object.relationType);
  writer.writeDouble(offsets[4], object.totalDebtAmount);
}

LocalCustomer _localCustomerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalCustomer();
  object.fullName = reader.readString(offsets[0]);
  object.id = id;
  object.lastUsed = reader.readDateTimeOrNull(offsets[1]);
  object.phoneNumber = reader.readStringOrNull(offsets[2]);
  object.relationType = reader.readString(offsets[3]);
  object.totalDebtAmount = reader.readDouble(offsets[4]);
  return object;
}

P _localCustomerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localCustomerGetId(LocalCustomer object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localCustomerGetLinks(LocalCustomer object) {
  return [];
}

void _localCustomerAttach(
    IsarCollection<dynamic> col, Id id, LocalCustomer object) {
  object.id = id;
}

extension LocalCustomerByIndex on IsarCollection<LocalCustomer> {
  Future<LocalCustomer?> getByFullName(String fullName) {
    return getByIndex(r'fullName', [fullName]);
  }

  LocalCustomer? getByFullNameSync(String fullName) {
    return getByIndexSync(r'fullName', [fullName]);
  }

  Future<bool> deleteByFullName(String fullName) {
    return deleteByIndex(r'fullName', [fullName]);
  }

  bool deleteByFullNameSync(String fullName) {
    return deleteByIndexSync(r'fullName', [fullName]);
  }

  Future<List<LocalCustomer?>> getAllByFullName(List<String> fullNameValues) {
    final values = fullNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'fullName', values);
  }

  List<LocalCustomer?> getAllByFullNameSync(List<String> fullNameValues) {
    final values = fullNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'fullName', values);
  }

  Future<int> deleteAllByFullName(List<String> fullNameValues) {
    final values = fullNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'fullName', values);
  }

  int deleteAllByFullNameSync(List<String> fullNameValues) {
    final values = fullNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'fullName', values);
  }

  Future<Id> putByFullName(LocalCustomer object) {
    return putByIndex(r'fullName', object);
  }

  Id putByFullNameSync(LocalCustomer object, {bool saveLinks = true}) {
    return putByIndexSync(r'fullName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFullName(List<LocalCustomer> objects) {
    return putAllByIndex(r'fullName', objects);
  }

  List<Id> putAllByFullNameSync(List<LocalCustomer> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'fullName', objects, saveLinks: saveLinks);
  }
}

extension LocalCustomerQueryWhereSort
    on QueryBuilder<LocalCustomer, LocalCustomer, QWhere> {
  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalCustomerQueryWhere
    on QueryBuilder<LocalCustomer, LocalCustomer, QWhereClause> {
  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause> fullNameEqualTo(
      String fullName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fullName',
        value: [fullName],
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterWhereClause>
      fullNameNotEqualTo(String fullName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fullName',
              lower: [],
              upper: [fullName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fullName',
              lower: [fullName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fullName',
              lower: [fullName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fullName',
              lower: [],
              upper: [fullName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalCustomerQueryFilter
    on QueryBuilder<LocalCustomer, LocalCustomer, QFilterCondition> {
  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsed',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsed',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      lastUsedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phoneNumber',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phoneNumber',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phoneNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phoneNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phoneNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      phoneNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phoneNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      relationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      totalDebtAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      totalDebtAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      totalDebtAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDebtAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterFilterCondition>
      totalDebtAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDebtAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension LocalCustomerQueryObject
    on QueryBuilder<LocalCustomer, LocalCustomer, QFilterCondition> {}

extension LocalCustomerQueryLinks
    on QueryBuilder<LocalCustomer, LocalCustomer, QFilterCondition> {}

extension LocalCustomerQuerySortBy
    on QueryBuilder<LocalCustomer, LocalCustomer, QSortBy> {
  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> sortByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByTotalDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebtAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      sortByTotalDebtAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebtAmount', Sort.desc);
    });
  }
}

extension LocalCustomerQuerySortThenBy
    on QueryBuilder<LocalCustomer, LocalCustomer, QSortThenBy> {
  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy> thenByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByRelationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByRelationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationType', Sort.desc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByTotalDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebtAmount', Sort.asc);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QAfterSortBy>
      thenByTotalDebtAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDebtAmount', Sort.desc);
    });
  }
}

extension LocalCustomerQueryWhereDistinct
    on QueryBuilder<LocalCustomer, LocalCustomer, QDistinct> {
  QueryBuilder<LocalCustomer, LocalCustomer, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QDistinct> distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QDistinct> distinctByPhoneNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QDistinct> distinctByRelationType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalCustomer, LocalCustomer, QDistinct>
      distinctByTotalDebtAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDebtAmount');
    });
  }
}

extension LocalCustomerQueryProperty
    on QueryBuilder<LocalCustomer, LocalCustomer, QQueryProperty> {
  QueryBuilder<LocalCustomer, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalCustomer, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<LocalCustomer, DateTime?, QQueryOperations> lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<LocalCustomer, String?, QQueryOperations> phoneNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNumber');
    });
  }

  QueryBuilder<LocalCustomer, String, QQueryOperations> relationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationType');
    });
  }

  QueryBuilder<LocalCustomer, double, QQueryOperations>
      totalDebtAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDebtAmount');
    });
  }
}
