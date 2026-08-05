// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types, experimental_member_use

extension GetAppProfileCollection on Isar {
  IsarCollection<AppProfile> get appProfiles => this.collection();
}

const AppProfileSchema = CollectionSchema(
  name: r'AppProfile',
  id: -6052215541457583506,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isDefault': PropertySchema(
      id: 1,
      name: r'isDefault',
      type: IsarType.bool,
    ),
    r'isarName': PropertySchema(
      id: 2,
      name: r'isarName',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _appProfileEstimateSize,
  serialize: _appProfileSerialize,
  deserialize: _appProfileDeserialize,
  deserializeProp: _appProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'isarName': IndexSchema(
      id: -6565581585911335111,
      name: r'isarName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isarName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _appProfileGetId,
  getLinks: _appProfileGetLinks,
  attach: _appProfileAttach,
  version: '3.1.0+1',
);

int _appProfileEstimateSize(
  AppProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.isarName.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _appProfileSerialize(
  AppProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isDefault);
  writer.writeString(offsets[2], object.isarName);
  writer.writeString(offsets[3], object.name);
}

AppProfile _appProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppProfile();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.isDefault = reader.readBool(offsets[1]);
  object.isarName = reader.readString(offsets[2]);
  object.name = reader.readString(offsets[3]);
  return object;
}

P _appProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appProfileGetId(AppProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appProfileGetLinks(AppProfile object) {
  return [];
}

void _appProfileAttach(IsarCollection<dynamic> col, Id id, AppProfile object) {
  object.id = id;
}

extension AppProfileByIndex on IsarCollection<AppProfile> {
  Future<AppProfile?> getByIsarName(String isarName) {
    return getByIndex(r'isarName', [isarName]);
  }

  AppProfile? getByIsarNameSync(String isarName) {
    return getByIndexSync(r'isarName', [isarName]);
  }

  Future<bool> deleteByIsarName(String isarName) {
    return deleteByIndex(r'isarName', [isarName]);
  }

  bool deleteByIsarNameSync(String isarName) {
    return deleteByIndexSync(r'isarName', [isarName]);
  }

  Future<List<AppProfile?>> getAllByIsarName(List<String> isarNameValues) {
    final values = isarNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'isarName', values);
  }

  List<AppProfile?> getAllByIsarNameSync(List<String> isarNameValues) {
    final values = isarNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'isarName', values);
  }

  Future<int> deleteAllByIsarName(List<String> isarNameValues) {
    final values = isarNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'isarName', values);
  }

  int deleteAllByIsarNameSync(List<String> isarNameValues) {
    final values = isarNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'isarName', values);
  }

  Future<Id> putByIsarName(AppProfile object) {
    return putByIndex(r'isarName', object);
  }

  Id putByIsarNameSync(AppProfile object, {bool saveLinks = true}) {
    return putByIndexSync(r'isarName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIsarName(List<AppProfile> objects) {
    return putAllByIndex(r'isarName', objects);
  }

  List<Id> putAllByIsarNameSync(List<AppProfile> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'isarName', objects, saveLinks: saveLinks);
  }
}

extension AppProfileQueryWhereSort
    on QueryBuilder<AppProfile, AppProfile, QWhere> {
  QueryBuilder<AppProfile, AppProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppProfileQueryWhere
    on QueryBuilder<AppProfile, AppProfile, QWhereClause> {
  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> idBetween(
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

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> isarNameEqualTo(
      String isarName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isarName',
        value: [isarName],
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterWhereClause> isarNameNotEqualTo(
      String isarName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isarName',
              lower: [],
              upper: [isarName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isarName',
              lower: [isarName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isarName',
              lower: [isarName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isarName',
              lower: [],
              upper: [isarName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AppProfileQueryFilter
    on QueryBuilder<AppProfile, AppProfile, QFilterCondition> {
  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isDefaultEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDefault',
        value: value,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition>
      isarNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition>
      isarNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'isarName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> isarNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'isarName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition>
      isarNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition>
      isarNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'isarName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension AppProfileQueryObject
    on QueryBuilder<AppProfile, AppProfile, QFilterCondition> {}

extension AppProfileQueryLinks
    on QueryBuilder<AppProfile, AppProfile, QFilterCondition> {}

extension AppProfileQuerySortBy
    on QueryBuilder<AppProfile, AppProfile, QSortBy> {
  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByIsarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarName', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByIsarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarName', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AppProfileQuerySortThenBy
    on QueryBuilder<AppProfile, AppProfile, QSortThenBy> {
  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByIsarName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarName', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByIsarNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarName', Sort.desc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension AppProfileQueryWhereDistinct
    on QueryBuilder<AppProfile, AppProfile, QDistinct> {
  QueryBuilder<AppProfile, AppProfile, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AppProfile, AppProfile, QDistinct> distinctByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDefault');
    });
  }

  QueryBuilder<AppProfile, AppProfile, QDistinct> distinctByIsarName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isarName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppProfile, AppProfile, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension AppProfileQueryProperty
    on QueryBuilder<AppProfile, AppProfile, QQueryProperty> {
  QueryBuilder<AppProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppProfile, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AppProfile, bool, QQueryOperations> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDefault');
    });
  }

  QueryBuilder<AppProfile, String, QQueryOperations> isarNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarName');
    });
  }

  QueryBuilder<AppProfile, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
