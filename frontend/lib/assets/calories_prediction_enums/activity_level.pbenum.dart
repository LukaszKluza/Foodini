//
//  Generated code. Do not modify.
//  source: assets/calories_prediction_enums/activity_level.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ActivityLevel extends $pb.ProtobufEnum {
  static const ActivityLevel VERY_LOW = ActivityLevel._(0, _omitEnumNames ? '' : 'VERY_LOW');
  static const ActivityLevel LIGHT = ActivityLevel._(1, _omitEnumNames ? '' : 'LIGHT');
  static const ActivityLevel MODERATE = ActivityLevel._(2, _omitEnumNames ? '' : 'MODERATE');
  static const ActivityLevel ACTIVE = ActivityLevel._(3, _omitEnumNames ? '' : 'ACTIVE');
  static const ActivityLevel VERY_ACTIVE = ActivityLevel._(4, _omitEnumNames ? '' : 'VERY_ACTIVE');

  static const $core.List<ActivityLevel> values = <ActivityLevel> [
    VERY_LOW,
    LIGHT,
    MODERATE,
    ACTIVE,
    VERY_ACTIVE,
  ];

  static final $core.List<ActivityLevel?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ActivityLevel? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ActivityLevel._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
