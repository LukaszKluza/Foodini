//
//  Generated code. Do not modify.
//  source: assets/stress_level.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use stressLevelDescriptor instead')
const StressLevel$json = {
  '1': 'StressLevel',
  '2': [
    {'1': 'LOW', '2': 0},
    {'1': 'MEDIUM', '2': 1},
    {'1': 'HIGH', '2': 2},
    {'1': 'EXTREME', '2': 3},
  ],
};

/// Descriptor for `StressLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List stressLevelDescriptor = $convert.base64Decode(
    'CgtTdHJlc3NMZXZlbBIHCgNMT1cQABIKCgZNRURJVU0QARIICgRISUdIEAISCwoHRVhUUkVNRR'
    'AD');

