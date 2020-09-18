// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

STT _$STTFromJson(Map<String, dynamic> json) {
  return STT(
    (json['SegmentResults'] as List)
        ?.map((e) => e == null
            ? null
            : SegmentResult.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['Words'] as List)
        ?.map((e) =>
            e == null ? null : WordData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$STTToJson(STT instance) => <String, dynamic>{
      'SegmentResults': instance.segmentResults,
      'Words': instance.words,
    };

SegmentResult _$SegmentResultFromJson(Map<String, dynamic> json) {
  return SegmentResult(
    (json['OffsetInSeconds'] as num)?.toDouble(),
    (json['DurationInSeconds'] as num)?.toDouble(),
    (json['NBest'] as List)
        ?.map(
            (e) => e == null ? null : NBest.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SegmentResultToJson(SegmentResult instance) =>
    <String, dynamic>{
      'OffsetInSeconds': instance.offsetInSeconds,
      'DurationInSeconds': instance.durationInSeconds,
      'NBest': instance.nBest,
    };

NBest _$NBestFromJson(Map<String, dynamic> json) {
  return NBest(
    (json['Words'] as List)
        ?.map((e) =>
            e == null ? null : WordData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['Display'] as String,
  );
}

Map<String, dynamic> _$NBestToJson(NBest instance) => <String, dynamic>{
      'Words': instance.words,
      'Display': instance.display,
    };

WordData _$WordDataFromJson(Map<String, dynamic> json) {
  return WordData(
    json['Word'] as String,
    (json['Offset'] as num)?.toDouble(),
    (json['Duration'] as num)?.toDouble(),
    (json['OffsetInSeconds'] as num)?.toDouble(),
    (json['DurationInSeconds'] as num)?.toDouble(),
    (json['Confidence'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$WordDataToJson(WordData instance) => <String, dynamic>{
      'Word': instance.word,
      'Offset': instance.offset,
      'Duration': instance.duration,
      'OffsetInSeconds': instance.offsetInSeconds,
      'DurationInSeconds': instance.durationInSeconds,
      'Confidence': instance.confidence,
    };
