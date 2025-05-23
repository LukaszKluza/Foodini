//
//  Generated code. Do not modify.
//  source: assets/diet_preferences_enums/diet_type.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DietType extends $pb.ProtobufEnum {
  static const DietType FAT_LOSS = DietType._(0, _omitEnumNames ? '' : 'FAT_LOSS');
  static const DietType MUSCLE_GAIN = DietType._(1, _omitEnumNames ? '' : 'MUSCLE_GAIN');
  static const DietType WEIGHT_MAINTENANCE = DietType._(2, _omitEnumNames ? '' : 'WEIGHT_MAINTENANCE');
  static const DietType VEGETARIAN = DietType._(3, _omitEnumNames ? '' : 'VEGETARIAN');
  static const DietType VEGAN = DietType._(4, _omitEnumNames ? '' : 'VEGAN');
  static const DietType KETO = DietType._(5, _omitEnumNames ? '' : 'KETO');

  static const $core.List<DietType> values = <DietType> [
    FAT_LOSS,
    MUSCLE_GAIN,
    WEIGHT_MAINTENANCE,
    VEGETARIAN,
    VEGAN,
    KETO,
  ];

  static final $core.List<DietType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DietType? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DietType._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
