//
//  Generated code. Do not modify.
//  source: assets/diet_preferences_enums/diet_intensity.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class DietIntensity extends $pb.ProtobufEnum {
  static const DietIntensity SLOW = DietIntensity._(0, _omitEnumNames ? '' : 'SLOW');
  static const DietIntensity MEDIUM = DietIntensity._(1, _omitEnumNames ? '' : 'MEDIUM');
  static const DietIntensity FAST = DietIntensity._(2, _omitEnumNames ? '' : 'FAST');

  static const $core.List<DietIntensity> values = <DietIntensity> [
    SLOW,
    MEDIUM,
    FAST,
  ];

  static final $core.List<DietIntensity?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DietIntensity? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DietIntensity._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
