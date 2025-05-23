//
//  Generated code. Do not modify.
//  source: assets/calories_prediction_enums/sleep_quality.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SleepQuality extends $pb.ProtobufEnum {
  static const SleepQuality POOR = SleepQuality._(0, _omitEnumNames ? '' : 'POOR');
  static const SleepQuality FAIR = SleepQuality._(1, _omitEnumNames ? '' : 'FAIR');
  static const SleepQuality GOOD = SleepQuality._(2, _omitEnumNames ? '' : 'GOOD');
  static const SleepQuality EXCELLENT = SleepQuality._(3, _omitEnumNames ? '' : 'EXCELLENT');

  static const $core.List<SleepQuality> values = <SleepQuality> [
    POOR,
    FAIR,
    GOOD,
    EXCELLENT,
  ];

  static final $core.List<SleepQuality?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SleepQuality? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SleepQuality._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
