//
//  Generated code. Do not modify.
//  source: assets/stress_level.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class StressLevel extends $pb.ProtobufEnum {
  static const StressLevel LOW = StressLevel._(0, _omitEnumNames ? '' : 'LOW');
  static const StressLevel MEDIUM = StressLevel._(1, _omitEnumNames ? '' : 'MEDIUM');
  static const StressLevel HIGH = StressLevel._(2, _omitEnumNames ? '' : 'HIGH');
  static const StressLevel EXTREME = StressLevel._(3, _omitEnumNames ? '' : 'EXTREME');

  static const $core.List<StressLevel> values = <StressLevel> [
    LOW,
    MEDIUM,
    HIGH,
    EXTREME,
  ];

  static final $core.List<StressLevel?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static StressLevel? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StressLevel._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
