//
//  Generated code. Do not modify.
//  source: assets/profile_details/gender.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Gender extends $pb.ProtobufEnum {
  static const Gender MALE = Gender._(0, _omitEnumNames ? '' : 'MALE');
  static const Gender FEMALE = Gender._(1, _omitEnumNames ? '' : 'FEMALE');

  static const $core.List<Gender> values = <Gender> [
    MALE,
    FEMALE,
  ];

  static final $core.List<Gender?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Gender? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Gender._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
