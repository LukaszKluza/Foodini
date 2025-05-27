//
//  Generated code. Do not modify.
//  source: assets/calories_prediction_enums/sleep_quality.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sleepQualityDescriptor instead')
const SleepQuality$json = {
  '1': 'SleepQuality',
  '2': [
    {'1': 'POOR', '2': 0},
    {'1': 'FAIR', '2': 1},
    {'1': 'GOOD', '2': 2},
    {'1': 'EXCELLENT', '2': 3},
  ],
};

/// Descriptor for `SleepQuality`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sleepQualityDescriptor = $convert.base64Decode(
    'CgxTbGVlcFF1YWxpdHkSCAoEUE9PUhAAEggKBEZBSVIQARIICgRHT09EEAISDQoJRVhDRUxMRU'
    '5UEAM=');

