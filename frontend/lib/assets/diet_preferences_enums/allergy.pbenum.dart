//
//  Generated code. Do not modify.
//  source: assets/diet_preferences_enums/allergy.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Allergy extends $pb.ProtobufEnum {
  static const Allergy GLUTEN = Allergy._(0, _omitEnumNames ? '' : 'GLUTEN');
  static const Allergy PEANUTS = Allergy._(1, _omitEnumNames ? '' : 'PEANUTS');
  static const Allergy LACTOSE = Allergy._(2, _omitEnumNames ? '' : 'LACTOSE');
  static const Allergy FISH = Allergy._(3, _omitEnumNames ? '' : 'FISH');
  static const Allergy SOY = Allergy._(4, _omitEnumNames ? '' : 'SOY');
  static const Allergy WHEAT = Allergy._(5, _omitEnumNames ? '' : 'WHEAT');
  static const Allergy CELERY = Allergy._(6, _omitEnumNames ? '' : 'CELERY');
  static const Allergy SULPHITES = Allergy._(7, _omitEnumNames ? '' : 'SULPHITES');
  static const Allergy LUPIN = Allergy._(8, _omitEnumNames ? '' : 'LUPIN');

  static const $core.List<Allergy> values = <Allergy> [
    GLUTEN,
    PEANUTS,
    LACTOSE,
    FISH,
    SOY,
    WHEAT,
    CELERY,
    SULPHITES,
    LUPIN,
  ];

  static final $core.List<Allergy?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 8);
  static Allergy? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Allergy._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
