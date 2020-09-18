// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

STT _$STTFromJson(Map<String, dynamic> json) {
  return STT(
    (json['Words'] as List)
        ?.map((e) =>
            e == null ? null : WordData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$STTToJson(STT instance) => <String, dynamic>{
      'Words': instance.words,
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
