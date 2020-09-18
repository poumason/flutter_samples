import 'package:json_annotation/json_annotation.dart';

part 'stt.g.dart';

@JsonSerializable()
class STT {
  @JsonKey(name: 'SegmentResults')
  List<SegmentResult> segmentResults;

  @JsonKey(name: 'Words')
  List<WordData> words;

  STT(this.segmentResults, this.words);

  factory STT.fromJson(Map<String, dynamic> json) => _$STTFromJson(json);

  Map<String, dynamic> toJson() => _$STTToJson(this);
}

@JsonSerializable()
class SegmentResult {
  @JsonKey(name: 'OffsetInSeconds')
  double offsetInSeconds;

  @JsonKey(name: 'DurationInSeconds')
  double durationInSeconds;

  @JsonKey(name: 'NBest')
  List<NBest> nBest;

  SegmentResult(this.offsetInSeconds, this.durationInSeconds, this.nBest);

  factory SegmentResult.fromJson(Map<String, dynamic> json) =>
      _$SegmentResultFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentResultToJson(this);
}

@JsonSerializable()
class NBest {
  @JsonKey(name: 'Words')
  List<WordData> words;

  @JsonKey(name: 'Display')
  String display;

  NBest(this.words, this.display);

  factory NBest.fromJson(Map<String, dynamic> json) => _$NBestFromJson(json);

  Map<String, dynamic> toJson() => _$NBestToJson(this);
}

@JsonSerializable()
class WordData {
  @JsonKey(name: 'Word')
  String word;

  @JsonKey(name: 'Offset')
  double offset;

  @JsonKey(name: 'Duration')
  double duration;

  @JsonKey(name: 'OffsetInSeconds')
  double offsetInSeconds;

  @JsonKey(name: 'DurationInSeconds')
  double durationInSeconds;

  @JsonKey(name: 'Confidence')
  double confidence;

  WordData(this.word, this.offset, this.duration, this.offsetInSeconds,
      this.durationInSeconds, this.confidence);

  factory WordData.fromJson(Map<String, dynamic> json) =>
      _$WordDataFromJson(json);

  Map<String, dynamic> toJson() => _$WordDataToJson(this);
}
