// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Agent.Info`
final class AgentInfo {
  const AgentInfo({
    required this.id,
    required this.name,
    this.model,
    required this.request,
    this.system,
    this.description,
    required this.mode,
    required this.hidden,
    this.color,
    this.steps,
    required this.permissions,
  });

  factory AgentInfo.fromJson(Map<String, Object?> json) => AgentInfo(
        id: AgentID.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        request: ProviderRequest.fromJson(asJsonMap(json['request'])),
        system: decodeOptionalString(json, 'system'),
        description: decodeOptionalString(json, 'description'),
        mode: AgentInfoMode.fromJson(json['mode']),
        hidden: decodeBool(json, 'hidden'),
        color: json['color'] == null
            ? null
            : AgentColor.fromJson(asJsonString(json['color'])),
        steps: decodeOptionalInt(json, 'steps'),
        permissions: jsonList(json['permissions'],
            (item) => PermissionRule.fromJson(asJsonMap(item))),
      );

  final AgentID id;
  final String name;
  final ModelRef? model;
  final ProviderRequest request;
  final String? system;
  final String? description;
  final AgentInfoMode mode;
  final bool hidden;
  final AgentColor? color;
  final int? steps;
  final List<PermissionRule> permissions;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (model != null) 'model': model!.toJson(),
        'request': request.toJson(),
        if (system != null) 'system': system!,
        if (description != null) 'description': description!,
        'mode': mode.wire,
        'hidden': hidden,
        if (color != null) 'color': color!,
        if (steps != null) 'steps': steps!,
        'permissions': [for (final item in permissions) item.toJson()],
      };
}

/// `Artifact.Content`
final class ArtifactContent {
  const ArtifactContent({
    required this.info,
    required this.files,
  });

  factory ArtifactContent.fromJson(Map<String, Object?> json) =>
      ArtifactContent(
        info: ArtifactInfo.fromJson(asJsonMap(json['info'])),
        files: asJsonMap(json['files']),
      );

  final ArtifactInfo info;
  final Map<String, Object?> files;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
        'files': files,
      };
}

/// `Artifact.Info`
final class ArtifactInfo {
  const ArtifactInfo({
    required this.id,
    required this.provider,
    this.sessionID,
    required this.title,
    required this.entry,
    required this.url,
    required this.time,
  });

  factory ArtifactInfo.fromJson(Map<String, Object?> json) => ArtifactInfo(
        id: ArtifactID.fromJson(asJsonString(json['id'])),
        provider:
            ArtifactProviderIDEncoded.fromJson(asJsonString(json['provider'])),
        sessionID: json['sessionID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['sessionID'])),
        title: decodeString(json, 'title'),
        entry: decodeString(json, 'entry'),
        url: decodeString(json, 'url'),
        time: ArtifactTime.fromJson(asJsonMap(json['time'])),
      );

  final ArtifactID id;
  final ArtifactProviderIDEncoded provider;
  final SessionID? sessionID;
  final String title;
  final String entry;
  final String url;
  final ArtifactTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'provider': provider,
        if (sessionID != null) 'sessionID': sessionID!,
        'title': title,
        'entry': entry,
        'url': url,
        'time': time.toJson(),
      };
}

/// `Artifact.Time`
final class ArtifactTime {
  const ArtifactTime({
    required this.created,
    required this.updated,
  });

  factory ArtifactTime.fromJson(Map<String, Object?> json) => ArtifactTime(
        created: decodeNumber(json, 'created'),
        updated: decodeNumber(json, 'updated'),
      );

  final double created;
  final double updated;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
      };
}

/// `Artifact.CreateInput`
final class ArtifactCreateInput {
  const ArtifactCreateInput({
    required this.title,
    required this.files,
    this.entry,
    this.provider,
    this.sessionID,
  });

  factory ArtifactCreateInput.fromJson(Map<String, Object?> json) =>
      ArtifactCreateInput(
        title: decodeString(json, 'title'),
        files: asJsonMap(json['files']),
        entry: decodeOptionalString(json, 'entry'),
        provider: decodeOptionalString(json, 'provider'),
        sessionID: json['sessionID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final String title;
  final Map<String, Object?> files;
  final String? entry;
  final String? provider;
  final SessionID? sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'title': title,
        'files': files,
        if (entry != null) 'entry': entry!,
        if (provider != null) 'provider': provider!,
        if (sessionID != null) 'sessionID': sessionID!,
      };
}

/// `Artifact.Provider`
final class ArtifactProvider {
  const ArtifactProvider({
    required this.id,
    required this.name,
    required this.capabilities,
    required this.defaultValue,
  });

  factory ArtifactProvider.fromJson(Map<String, Object?> json) =>
      ArtifactProvider(
        id: ArtifactProviderIDEncoded.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
        capabilities: jsonList(
            json['capabilities'], (item) => ArtifactCapability.fromJson(item)),
        defaultValue: decodeBool(json, 'default'),
      );

  final ArtifactProviderIDEncoded id;
  final String name;
  final List<ArtifactCapability> capabilities;

  /// Wire field: `default`.
  final bool defaultValue;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'capabilities': [for (final item in capabilities) item.wire],
        'default': defaultValue,
      };
}

/// `Artifact.UpdateInput`
final class ArtifactUpdateInput {
  const ArtifactUpdateInput({
    this.title,
    required this.files,
    this.entry,
    this.sessionID,
  });

  factory ArtifactUpdateInput.fromJson(Map<String, Object?> json) =>
      ArtifactUpdateInput(
        title: decodeOptionalString(json, 'title'),
        files: asJsonMap(json['files']),
        entry: decodeOptionalString(json, 'entry'),
        sessionID: json['sessionID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final String? title;
  final Map<String, Object?> files;
  final String? entry;
  final SessionID? sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        if (title != null) 'title': title!,
        'files': files,
        if (entry != null) 'entry': entry!,
        if (sessionID != null) 'sessionID': sessionID!,
      };
}

/// `Command.Info`
final class CommandInfo {
  const CommandInfo({
    required this.name,
    this.description,
  });

  factory CommandInfo.fromJson(Map<String, Object?> json) => CommandInfo(
        name: decodeString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
      );

  final String name;
  final String? description;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        if (description != null) 'description': description!,
      };
}

/// `EventLog.Synced`
final class EventLogSynced {
  const EventLogSynced({
    required this.aggregateID,
    this.seq,
  });

  factory EventLogSynced.fromJson(Map<String, Object?> json) => EventLogSynced(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: json['seq'] == null
            ? null
            : EventSeq.fromJson(asJsonInt(json['seq'])),
      );

  final String aggregateID;
  final EventSeq? seq;

  /// Always `log.synced`.
  String get type => 'log.synced';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'log.synced',
        'aggregateID': aggregateID,
        if (seq != null) 'seq': seq!,
      };
}

/// `FileSystem.Entry`
final class FileSystemEntry {
  const FileSystemEntry({
    required this.path,
    required this.type,
  });

  factory FileSystemEntry.fromJson(Map<String, Object?> json) =>
      FileSystemEntry(
        path: RelativePath.fromJson(asJsonString(json['path'])),
        type: FileSystemEntryType.fromJson(json['type']),
      );

  final RelativePath path;
  final FileSystemEntryType type;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        'type': type.wire,
      };
}

/// `FileSystem.Write`
final class FileSystemWrite {
  const FileSystemWrite({
    required this.path,
  });

  factory FileSystemWrite.fromJson(Map<String, Object?> json) =>
      FileSystemWrite(
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
      );

  final AbsolutePath path;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
      };
}

/// `Generate.ChoiceAnswer`
final class GenerateChoiceAnswer extends GenerateDecisionAnswer {
  const GenerateChoiceAnswer({
    required this.name,
    required this.choice,
    required this.probabilities,
    required this.confidence,
  });

  factory GenerateChoiceAnswer.fromJson(Map<String, Object?> json) =>
      GenerateChoiceAnswer(
        name: decodeString(json, 'name'),
        choice: json['choice'],
        probabilities: jsonList(
            json['probabilities'],
            (item) =>
                GenerateChoiceAnswerProbabilities.fromJson(asJsonMap(item))),
        confidence: decodeNumber(json, 'confidence'),
      );

  @override
  final String name;
  final Object? choice;
  final List<GenerateChoiceAnswerProbabilities> probabilities;
  final double confidence;

  /// Always `choice`.
  @override
  String get type => 'choice';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'choice',
        'name': name,
        'choice': choice,
        'probabilities': [for (final item in probabilities) item.toJson()],
        'confidence': confidence,
      };
}

/// `Generate.ChoiceQuestion`
final class GenerateChoiceQuestion extends GenerateDecisionQuestion {
  const GenerateChoiceQuestion({
    required this.name,
    required this.instructions,
    required this.choices,
  });

  factory GenerateChoiceQuestion.fromJson(Map<String, Object?> json) =>
      GenerateChoiceQuestion(
        name: decodeString(json, 'name'),
        instructions: decodeString(json, 'instructions'),
        choices: jsonList(json['choices'],
            (item) => GenerateChoiceQuestionChoices.fromJson(asJsonMap(item))),
      );

  @override
  final String name;
  @override
  final String instructions;
  final List<GenerateChoiceQuestionChoices> choices;

  /// Always `choice`.
  @override
  String get type => 'choice';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'choice',
        'name': name,
        'instructions': instructions,
        'choices': [for (final item in choices) item.toJson()],
      };
}

/// `Generate.DecisionAnswer`
sealed class GenerateDecisionAnswer {
  const GenerateDecisionAnswer();

  /// Decodes a payload into the matching variant.
  factory GenerateDecisionAnswer.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'predicate' => GeneratePredicateAnswer.fromJson(json),
      'choice' => GenerateChoiceAnswer.fromJson(json),
      'score' => GenerateScoreAnswer.fromJson(json),
      'error' => GenerateErrorAnswer.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Generate.DecisionAnswer discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`name`).
  String get name;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Generate.PredicateAnswer`
final class GeneratePredicateAnswer extends GenerateDecisionAnswer {
  const GeneratePredicateAnswer({
    required this.name,
    required this.probability,
  });

  factory GeneratePredicateAnswer.fromJson(Map<String, Object?> json) =>
      GeneratePredicateAnswer(
        name: decodeString(json, 'name'),
        probability: decodeNumber(json, 'probability'),
      );

  @override
  final String name;
  final double probability;

  /// Always `predicate`.
  @override
  String get type => 'predicate';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'predicate',
        'name': name,
        'probability': probability,
      };
}

/// `Generate.ScoreAnswer`
final class GenerateScoreAnswer extends GenerateDecisionAnswer {
  const GenerateScoreAnswer({
    required this.name,
    required this.score,
    required this.probabilities,
    required this.confidence,
  });

  factory GenerateScoreAnswer.fromJson(Map<String, Object?> json) =>
      GenerateScoreAnswer(
        name: decodeString(json, 'name'),
        score: decodeNumber(json, 'score'),
        probabilities: jsonList(
            json['probabilities'],
            (item) =>
                GenerateScoreAnswerProbabilities.fromJson(asJsonMap(item))),
        confidence: decodeNumber(json, 'confidence'),
      );

  @override
  final String name;
  final double score;
  final List<GenerateScoreAnswerProbabilities> probabilities;
  final double confidence;

  /// Always `score`.
  @override
  String get type => 'score';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'score',
        'name': name,
        'score': score,
        'probabilities': [for (final item in probabilities) item.toJson()],
        'confidence': confidence,
      };
}

/// `Generate.ErrorAnswer`
final class GenerateErrorAnswer extends GenerateDecisionAnswer {
  const GenerateErrorAnswer({
    required this.name,
    required this.reason,
    this.message,
  });

  factory GenerateErrorAnswer.fromJson(Map<String, Object?> json) =>
      GenerateErrorAnswer(
        name: decodeString(json, 'name'),
        reason: decodeString(json, 'reason'),
        message: decodeOptionalString(json, 'message'),
      );

  @override
  final String name;
  final String reason;
  final String? message;

  /// Always `error`.
  @override
  String get type => 'error';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'error',
        'name': name,
        'reason': reason,
        if (message != null) 'message': message!,
      };
}

/// `Generate.DecisionFilePart`
final class GenerateDecisionFilePart extends GenerateDecisionPart {
  const GenerateDecisionFilePart({
    required this.data,
    required this.mime,
    this.name,
  });

  factory GenerateDecisionFilePart.fromJson(Map<String, Object?> json) =>
      GenerateDecisionFilePart(
        data: PromptBase64.fromJson(asJsonString(json['data'])),
        mime: decodeString(json, 'mime'),
        name: decodeOptionalString(json, 'name'),
      );

  final PromptBase64 data;
  final String mime;
  final String? name;

  /// Always `file`.
  @override
  String get type => 'file';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'file',
        'data': data,
        'mime': mime,
        if (name != null) 'name': name!,
      };
}

/// `Generate.DecisionJsonPart`
final class GenerateDecisionJsonPart extends GenerateDecisionPart {
  const GenerateDecisionJsonPart({
    required this.value,
  });

  factory GenerateDecisionJsonPart.fromJson(Map<String, Object?> json) =>
      GenerateDecisionJsonPart(
        value: json['value'],
      );

  final Object? value;

  /// Always `json`.
  @override
  String get type => 'json';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'json',
        'value': value,
      };
}

/// `Generate.DecisionPart`
sealed class GenerateDecisionPart {
  const GenerateDecisionPart();

  /// Decodes a payload into the matching variant.
  factory GenerateDecisionPart.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'text' => GenerateDecisionTextPart.fromJson(json),
      'json' => GenerateDecisionJsonPart.fromJson(json),
      'file' => GenerateDecisionFilePart.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Generate.DecisionPart discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Generate.DecisionTextPart`
final class GenerateDecisionTextPart extends GenerateDecisionPart {
  const GenerateDecisionTextPart({
    required this.text,
  });

  factory GenerateDecisionTextPart.fromJson(Map<String, Object?> json) =>
      GenerateDecisionTextPart(
        text: decodeString(json, 'text'),
      );

  final String text;

  /// Always `text`.
  @override
  String get type => 'text';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'text',
        'text': text,
      };
}

/// `Generate.DecisionQuestion`
sealed class GenerateDecisionQuestion {
  const GenerateDecisionQuestion();

  /// Decodes a payload into the matching variant.
  factory GenerateDecisionQuestion.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'predicate' => GeneratePredicateQuestion.fromJson(json),
      'choice' => GenerateChoiceQuestion.fromJson(json),
      'score' => GenerateScoreQuestion.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Generate.DecisionQuestion discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`name`).
  String get name;

  /// Present on every variant (`instructions`).
  String get instructions;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Generate.PredicateQuestion`
final class GeneratePredicateQuestion extends GenerateDecisionQuestion {
  const GeneratePredicateQuestion({
    required this.name,
    required this.instructions,
    this.criteria,
  });

  factory GeneratePredicateQuestion.fromJson(Map<String, Object?> json) =>
      GeneratePredicateQuestion(
        name: decodeString(json, 'name'),
        instructions: decodeString(json, 'instructions'),
        criteria: json['criteria'] == null
            ? null
            : GeneratePredicateQuestionCriteria.fromJson(
                asJsonMap(json['criteria'])),
      );

  @override
  final String name;
  @override
  final String instructions;
  final GeneratePredicateQuestionCriteria? criteria;

  /// Always `predicate`.
  @override
  String get type => 'predicate';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'predicate',
        'name': name,
        'instructions': instructions,
        if (criteria != null) 'criteria': criteria!.toJson(),
      };
}

/// `Generate.ScoreQuestion`
final class GenerateScoreQuestion extends GenerateDecisionQuestion {
  const GenerateScoreQuestion({
    required this.name,
    required this.instructions,
    required this.levels,
  });

  factory GenerateScoreQuestion.fromJson(Map<String, Object?> json) =>
      GenerateScoreQuestion(
        name: decodeString(json, 'name'),
        instructions: decodeString(json, 'instructions'),
        levels: jsonList(json['levels'],
            (item) => GenerateScoreQuestionLevels.fromJson(asJsonMap(item))),
      );

  @override
  final String name;
  @override
  final String instructions;
  final List<GenerateScoreQuestionLevels> levels;

  /// Always `score`.
  @override
  String get type => 'score';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'score',
        'name': name,
        'instructions': instructions,
        'levels': [for (final item in levels) item.toJson()],
      };
}

/// `Generate.DecisionRequest`
final class GenerateDecisionRequest {
  const GenerateDecisionRequest({
    required this.model,
    required this.input,
    required this.questions,
  });

  factory GenerateDecisionRequest.fromJson(Map<String, Object?> json) =>
      GenerateDecisionRequest(
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        input: jsonList(json['input'],
            (item) => GenerateDecisionPart.fromJson(asJsonMap(item))),
        questions: jsonList(json['questions'],
            (item) => GenerateDecisionQuestion.fromJson(asJsonMap(item))),
      );

  final ModelRef model;
  final List<GenerateDecisionPart> input;
  final List<GenerateDecisionQuestion> questions;

  Map<String, Object?> toJson() => <String, Object?>{
        'model': model.toJson(),
        'input': [for (final item in input) item.toJson()],
        'questions': [for (final item in questions) item.toJson()],
      };
}

/// `Generate.DecisionResult`
final class GenerateDecisionResult {
  const GenerateDecisionResult({
    required this.answers,
    this.cost,
    this.tokens,
    this.native,
  });

  factory GenerateDecisionResult.fromJson(Map<String, Object?> json) =>
      GenerateDecisionResult(
        answers: jsonList(json['answers'],
            (item) => GenerateDecisionAnswer.fromJson(asJsonMap(item))),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : GenerateUsage.fromJson(asJsonMap(json['tokens'])),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final List<GenerateDecisionAnswer> answers;
  final MoneyUSD? cost;
  final GenerateUsage? tokens;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'answers': [for (final item in answers) item.toJson()],
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
        if (native != null) 'native': native!,
      };
}

/// `Generate.Usage`
final class GenerateUsage {
  const GenerateUsage({
    this.input,
    this.output,
  });

  factory GenerateUsage.fromJson(Map<String, Object?> json) => GenerateUsage(
        input: decodeOptionalNumber(json, 'input'),
        output: decodeOptionalNumber(json, 'output'),
      );

  final double? input;
  final double? output;

  Map<String, Object?> toJson() => <String, Object?>{
        if (input != null) 'input': input!,
        if (output != null) 'output': output!,
      };
}

/// `Generate.File`
final class GenerateFile {
  const GenerateFile({
    required this.data,
    required this.mime,
    this.name,
  });

  factory GenerateFile.fromJson(Map<String, Object?> json) => GenerateFile(
        data: PromptBase64.fromJson(asJsonString(json['data'])),
        mime: decodeString(json, 'mime'),
        name: decodeOptionalString(json, 'name'),
      );

  final PromptBase64 data;
  final String mime;
  final String? name;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data,
        'mime': mime,
        if (name != null) 'name': name!,
      };
}

/// `Generate.ImageOutput`
final class GenerateImageOutput {
  const GenerateImageOutput({
    required this.data,
    required this.mime,
    this.name,
  });

  factory GenerateImageOutput.fromJson(Map<String, Object?> json) =>
      GenerateImageOutput(
        data: PromptBase64.fromJson(asJsonString(json['data'])),
        mime: decodeString(json, 'mime'),
        name: decodeOptionalString(json, 'name'),
      );

  final PromptBase64 data;
  final String mime;
  final String? name;

  /// Always `image`.
  String get type => 'image';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'image',
        'data': data,
        'mime': mime,
        if (name != null) 'name': name!,
      };
}

/// `Generate.ImageRequest`
final class GenerateImageRequest {
  const GenerateImageRequest({
    required this.model,
    required this.prompt,
    this.images,
    this.n,
    this.aspect,
    this.resolution,
  });

  factory GenerateImageRequest.fromJson(Map<String, Object?> json) =>
      GenerateImageRequest(
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        prompt: decodeString(json, 'prompt'),
        images: json['images'] == null
            ? null
            : jsonList(json['images'],
                (item) => GenerateFile.fromJson(asJsonMap(item))),
        n: decodeOptionalInt(json, 'n'),
        aspect: json['aspect'] == null
            ? null
            : GenerateImageAspect.fromJson(asJsonString(json['aspect'])),
        resolution: decodeOptionalString(json, 'resolution'),
      );

  final ModelRef model;
  final String prompt;
  final List<GenerateFile>? images;
  final int? n;
  final GenerateImageAspect? aspect;
  final String? resolution;

  Map<String, Object?> toJson() => <String, Object?>{
        'model': model.toJson(),
        'prompt': prompt,
        if (images != null)
          'images': [for (final item in images!) item.toJson()],
        if (n != null) 'n': n!,
        if (aspect != null) 'aspect': aspect!,
        if (resolution != null) 'resolution': resolution!,
      };
}

/// `Generate.ImageResult`
final class GenerateImageResult {
  const GenerateImageResult({
    required this.images,
    this.cost,
    this.tokens,
    this.native,
  });

  factory GenerateImageResult.fromJson(Map<String, Object?> json) =>
      GenerateImageResult(
        images: jsonList(json['images'],
            (item) => GenerateImageOutput.fromJson(asJsonMap(item))),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : GenerateUsage.fromJson(asJsonMap(json['tokens'])),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final List<GenerateImageOutput> images;
  final MoneyUSD? cost;
  final GenerateUsage? tokens;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'images': [for (final item in images) item.toJson()],
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
        if (native != null) 'native': native!,
      };
}

/// `GenerateDecisionsResponse`
final class GenerateDecisionsResponse {
  const GenerateDecisionsResponse({
    required this.data,
  });

  factory GenerateDecisionsResponse.fromJson(Map<String, Object?> json) =>
      GenerateDecisionsResponse(
        data: GenerateDecisionResult.fromJson(asJsonMap(json['data'])),
      );

  final GenerateDecisionResult data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `GenerateImageResponse`
final class GenerateImageResponse {
  const GenerateImageResponse({
    required this.data,
  });

  factory GenerateImageResponse.fromJson(Map<String, Object?> json) =>
      GenerateImageResponse(
        data: GenerateImageResult.fromJson(asJsonMap(json['data'])),
      );

  final GenerateImageResult data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `GenerateTextResponse`
final class GenerateTextResponse {
  const GenerateTextResponse({
    required this.data,
  });

  factory GenerateTextResponse.fromJson(Map<String, Object?> json) =>
      GenerateTextResponse(
        data: GenerateTextResponseData.fromJson(asJsonMap(json['data'])),
      );

  final GenerateTextResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `InstructionEntry.Info`
final class InstructionEntryInfo {
  const InstructionEntryInfo({
    required this.key,
    required this.value,
  });

  factory InstructionEntryInfo.fromJson(Map<String, Object?> json) =>
      InstructionEntryInfo(
        key: InstructionEntryKey.fromJson(asJsonString(json['key'])),
        value: json['value'],
      );

  final InstructionEntryKey key;
  final Object? value;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'value': value,
      };
}

/// `Job.Image`
final class JobImage extends JobInfo {
  const JobImage({
    required this.id,
    required this.sessionID,
    required this.status,
    this.title,
    required this.time,
    required this.path,
    required this.model,
  });

  factory JobImage.fromJson(Map<String, Object?> json) => JobImage(
        id: decodeString(json, 'id'),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        status: JobStatus.fromJson(json['status']),
        title: decodeOptionalString(json, 'title'),
        time: JobTime.fromJson(asJsonMap(json['time'])),
        path: decodeString(json, 'path'),
        model: decodeString(json, 'model'),
      );

  @override
  final String id;
  @override
  final SessionID sessionID;
  @override
  final JobStatus status;
  @override
  final String? title;
  @override
  final JobTime time;
  final String path;
  final String model;

  /// Always `image`.
  @override
  String get kind => 'image';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'kind': 'image',
        'id': id,
        'sessionID': sessionID,
        'status': status.wire,
        if (title != null) 'title': title!,
        'time': time.toJson(),
        'path': path,
        'model': model,
      };
}

/// `Job.Time`
final class JobTime {
  const JobTime({
    required this.started,
    this.completed,
  });

  factory JobTime.fromJson(Map<String, Object?> json) => JobTime(
        started: decodeNumber(json, 'started'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double started;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'started': started,
        if (completed != null) 'completed': completed!,
      };
}

/// `Job.Info`
sealed class JobInfo {
  const JobInfo();

  /// Decodes a payload into the matching variant.
  factory JobInfo.fromJson(Map<String, Object?> json) {
    final value = json['kind'];
    return switch (value) {
      'shell' => JobShell.fromJson(json),
      'subagent' => JobSubagent.fromJson(json),
      'image' => JobImage.fromJson(json),
      _ =>
        throw OpenCodeDecodeException('Unknown Job.Info discriminator: $value'),
    };
  }

  /// Present on every variant (`kind`).
  String get kind;

  /// Present on every variant (`id`).
  String get id;

  /// Present on every variant (`sessionID`).
  SessionID get sessionID;

  /// Present on every variant (`status`).
  JobStatus get status;

  /// Present on every variant (`title`).
  String? get title;

  /// Present on every variant (`time`).
  JobTime get time;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Job.Shell`
final class JobShell extends JobInfo {
  const JobShell({
    required this.id,
    required this.sessionID,
    required this.status,
    this.title,
    required this.time,
    required this.shellID,
    required this.command,
  });

  factory JobShell.fromJson(Map<String, Object?> json) => JobShell(
        id: decodeString(json, 'id'),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        status: JobStatus.fromJson(json['status']),
        title: decodeOptionalString(json, 'title'),
        time: JobTime.fromJson(asJsonMap(json['time'])),
        shellID: decodeString(json, 'shellID'),
        command: decodeString(json, 'command'),
      );

  @override
  final String id;
  @override
  final SessionID sessionID;
  @override
  final JobStatus status;
  @override
  final String? title;
  @override
  final JobTime time;
  final String shellID;
  final String command;

  /// Always `shell`.
  @override
  String get kind => 'shell';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'kind': 'shell',
        'id': id,
        'sessionID': sessionID,
        'status': status.wire,
        if (title != null) 'title': title!,
        'time': time.toJson(),
        'shellID': shellID,
        'command': command,
      };
}

/// `Job.Subagent`
final class JobSubagent extends JobInfo {
  const JobSubagent({
    required this.id,
    required this.sessionID,
    required this.status,
    this.title,
    required this.time,
    required this.childSessionID,
    required this.agent,
    required this.description,
  });

  factory JobSubagent.fromJson(Map<String, Object?> json) => JobSubagent(
        id: decodeString(json, 'id'),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        status: JobStatus.fromJson(json['status']),
        title: decodeOptionalString(json, 'title'),
        time: JobTime.fromJson(asJsonMap(json['time'])),
        childSessionID:
            SessionID.fromJson(asJsonString(json['childSessionID'])),
        agent: decodeString(json, 'agent'),
        description: decodeString(json, 'description'),
      );

  @override
  final String id;
  @override
  final SessionID sessionID;
  @override
  final JobStatus status;
  @override
  final String? title;
  @override
  final JobTime time;
  final SessionID childSessionID;
  final String agent;
  final String description;

  /// Always `subagent`.
  @override
  String get kind => 'subagent';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'kind': 'subagent',
        'id': id,
        'sessionID': sessionID,
        'status': status.wire,
        if (title != null) 'title': title!,
        'time': time.toJson(),
        'childSessionID': childSessionID,
        'agent': agent,
        'description': description,
      };
}

/// `Location.PublicInfo`
final class LocationPublicInfo {
  const LocationPublicInfo({
    required this.directory,
    required this.project,
  });

  factory LocationPublicInfo.fromJson(Map<String, Object?> json) =>
      LocationPublicInfo(
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        project: LocationPublicInfoProject.fromJson(asJsonMap(json['project'])),
      );

  final AbsolutePath directory;
  final LocationPublicInfoProject project;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
        'project': project.toJson(),
      };
}

/// `PairingCode`
final class PairingCode {
  const PairingCode({
    required this.code,
    required this.expiresIn,
  });

  factory PairingCode.fromJson(Map<String, Object?> json) => PairingCode(
        code: decodeString(json, 'code'),
        expiresIn: decodeInt(json, 'expires_in'),
      );

  final String code;

  /// Wire field: `expires_in`.
  final int expiresIn;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'expires_in': expiresIn,
      };
}

/// `PairingSession`
final class PairingSession {
  const PairingSession({
    required this.token,
  });

  factory PairingSession.fromJson(Map<String, Object?> json) => PairingSession(
        token: decodeString(json, 'token'),
      );

  final String token;

  Map<String, Object?> toJson() => <String, Object?>{
        'token': token,
      };
}

/// `Project`
final class Project {
  const Project({
    required this.id,
    required this.canonical,
    this.vcs,
    this.name,
    this.icon,
    this.commands,
    required this.time,
    required this.sandboxes,
  });

  factory Project.fromJson(Map<String, Object?> json) => Project(
        id: ProjectID.fromJson(asJsonString(json['id'])),
        canonical: AbsolutePath.fromJson(asJsonString(json['canonical'])),
        vcs: json['vcs'] == null
            ? null
            : ProjectVcs.fromJson(asJsonString(json['vcs'])),
        name: decodeOptionalString(json, 'name'),
        icon: json['icon'] == null
            ? null
            : ProjectIcon.fromJson(asJsonMap(json['icon'])),
        commands: json['commands'] == null
            ? null
            : ProjectCommands.fromJson(asJsonMap(json['commands'])),
        time: ProjectTime.fromJson(asJsonMap(json['time'])),
        sandboxes: jsonList(json['sandboxes'], (item) => asJsonString(item)),
      );

  final ProjectID id;
  final AbsolutePath canonical;
  final ProjectVcs? vcs;
  final String? name;
  final ProjectIcon? icon;
  final ProjectCommands? commands;
  final ProjectTime time;
  final List<String> sandboxes;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'canonical': canonical,
        if (vcs != null) 'vcs': vcs!,
        if (name != null) 'name': name!,
        if (icon != null) 'icon': icon!.toJson(),
        if (commands != null) 'commands': commands!.toJson(),
        'time': time.toJson(),
        'sandboxes': sandboxes,
      };
}

/// `Project.Icon`
final class ProjectIcon {
  const ProjectIcon({
    this.url,
    this.override,
    this.color,
  });

  factory ProjectIcon.fromJson(Map<String, Object?> json) => ProjectIcon(
        url: decodeOptionalString(json, 'url'),
        override: decodeOptionalString(json, 'override'),
        color: decodeOptionalString(json, 'color'),
      );

  final String? url;
  final String? override;
  final String? color;

  Map<String, Object?> toJson() => <String, Object?>{
        if (url != null) 'url': url!,
        if (override != null) 'override': override!,
        if (color != null) 'color': color!,
      };
}

/// `Project.Commands`
final class ProjectCommands {
  const ProjectCommands({
    this.start,
  });

  factory ProjectCommands.fromJson(Map<String, Object?> json) =>
      ProjectCommands(
        start: decodeOptionalString(json, 'start'),
      );

  final String? start;

  Map<String, Object?> toJson() => <String, Object?>{
        if (start != null) 'start': start!,
      };
}

/// `Project.Time`
final class ProjectTime {
  const ProjectTime({
    required this.created,
    required this.updated,
    required this.active,
    this.archived,
  });

  factory ProjectTime.fromJson(Map<String, Object?> json) => ProjectTime(
        created: decodeInt(json, 'created'),
        updated: decodeInt(json, 'updated'),
        active: decodeInt(json, 'active'),
        archived: decodeOptionalInt(json, 'archived'),
      );

  final int created;
  final int updated;
  final int active;
  final int? archived;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
        'active': active,
        if (archived != null) 'archived': archived!,
      };
}

/// `Prompt.AgentAttachment`
final class PromptAgentAttachment {
  const PromptAgentAttachment({
    required this.name,
    this.mention,
  });

  factory PromptAgentAttachment.fromJson(Map<String, Object?> json) =>
      PromptAgentAttachment(
        name: decodeString(json, 'name'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final String name;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `Prompt.Mention`
final class PromptMention {
  const PromptMention({
    required this.start,
    required this.end,
    required this.text,
  });

  factory PromptMention.fromJson(Map<String, Object?> json) => PromptMention(
        start: decodeNumber(json, 'start'),
        end: decodeNumber(json, 'end'),
        text: decodeString(json, 'text'),
      );

  final double start;
  final double end;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'start': start,
        'end': end,
        'text': text,
      };
}

/// `Prompt.FileAttachment`
final class PromptFileAttachment {
  const PromptFileAttachment({
    required this.data,
    required this.mime,
    required this.source,
    this.name,
    this.description,
    this.mention,
  });

  factory PromptFileAttachment.fromJson(Map<String, Object?> json) =>
      PromptFileAttachment(
        data: PromptBase64.fromJson(asJsonString(json['data'])),
        mime: decodeString(json, 'mime'),
        source: PromptFileSource.fromJson(asJsonMap(json['source'])),
        name: decodeOptionalString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final PromptBase64 data;
  final String mime;
  final PromptFileSource source;
  final String? name;
  final String? description;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data,
        'mime': mime,
        'source': source.toJson(),
        if (name != null) 'name': name!,
        if (description != null) 'description': description!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `Prompt.FileSource`
sealed class PromptFileSource {
  const PromptFileSource();

  /// Decodes a payload into the matching variant.
  factory PromptFileSource.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'inline' => PromptFileSourceInline.fromJson(json),
      'uri' => PromptFileSourceUri.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Prompt.FileSource discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `PromptFileSourceInline`
final class PromptFileSourceInline extends PromptFileSource {
  const PromptFileSourceInline();

  factory PromptFileSourceInline.fromJson(Map<String, Object?> json) =>
      PromptFileSourceInline();

  /// Always `inline`.
  @override
  String get type => 'inline';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'inline',
      };
}

/// `PromptFileSourceUri`
final class PromptFileSourceUri extends PromptFileSource {
  const PromptFileSourceUri({
    required this.uri,
  });

  factory PromptFileSourceUri.fromJson(Map<String, Object?> json) =>
      PromptFileSourceUri(
        uri: decodeString(json, 'uri'),
      );

  final String uri;

  /// Always `uri`.
  @override
  String get type => 'uri';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'uri',
        'uri': uri,
      };
}

/// `Prompt.SkillAttachment`
final class PromptSkillAttachment {
  const PromptSkillAttachment({
    required this.id,
    required this.name,
    this.text,
    this.mention,
  });

  factory PromptSkillAttachment.fromJson(Map<String, Object?> json) =>
      PromptSkillAttachment(
        id: SkillID.fromJson(asJsonString(json['id'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        text: decodeOptionalString(json, 'text'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final SkillID id;
  final SkillName name;
  final String? text;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (text != null) 'text': text!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PromptInput.FileAttachment`
final class PromptInputFileAttachment {
  const PromptInputFileAttachment({
    required this.uri,
    this.source,
    this.name,
    this.description,
    this.mention,
  });

  factory PromptInputFileAttachment.fromJson(Map<String, Object?> json) =>
      PromptInputFileAttachment(
        uri: decodeString(json, 'uri'),
        source: json['source'] == null
            ? null
            : PromptFileSource.fromJson(asJsonMap(json['source'])),
        name: decodeOptionalString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final String uri;
  final PromptFileSource? source;
  final String? name;
  final String? description;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'uri': uri,
        if (source != null) 'source': source!.toJson(),
        if (name != null) 'name': name!,
        if (description != null) 'description': description!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PromptInput.SkillAttachment`
final class PromptInputSkillAttachment {
  const PromptInputSkillAttachment({
    required this.id,
    this.mention,
  });

  factory PromptInputSkillAttachment.fromJson(Map<String, Object?> json) =>
      PromptInputSkillAttachment(
        id: SkillID.fromJson(asJsonString(json['id'])),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final SkillID id;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PtyTicket.ConnectToken`
final class PtyTicketConnectToken {
  const PtyTicketConnectToken({
    required this.ticket,
    required this.expiresIn,
  });

  factory PtyTicketConnectToken.fromJson(Map<String, Object?> json) =>
      PtyTicketConnectToken(
        ticket: decodeString(json, 'ticket'),
        expiresIn: decodeInt(json, 'expires_in'),
      );

  final String ticket;

  /// Wire field: `expires_in`.
  final int expiresIn;

  Map<String, Object?> toJson() => <String, Object?>{
        'ticket': ticket,
        'expires_in': expiresIn,
      };
}

/// `Reference.GitSource`
final class ReferenceGitSource extends ReferenceSource {
  const ReferenceGitSource({
    required this.repository,
    this.branch,
  });

  factory ReferenceGitSource.fromJson(Map<String, Object?> json) =>
      ReferenceGitSource(
        repository: decodeString(json, 'repository'),
        branch: decodeOptionalString(json, 'branch'),
      );

  final String repository;
  final String? branch;

  /// Always `git`.
  @override
  String get type => 'git';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'git',
        'repository': repository,
        if (branch != null) 'branch': branch!,
      };
}

/// `Reference.Info`
final class ReferenceInfo {
  const ReferenceInfo({
    required this.name,
    required this.path,
    this.description,
    this.hidden,
    required this.source,
  });

  factory ReferenceInfo.fromJson(Map<String, Object?> json) => ReferenceInfo(
        name: decodeString(json, 'name'),
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
        description: decodeOptionalString(json, 'description'),
        hidden: decodeOptionalBool(json, 'hidden'),
        source: ReferenceSource.fromJson(asJsonMap(json['source'])),
      );

  final String name;
  final AbsolutePath path;
  final String? description;
  final bool? hidden;
  final ReferenceSource source;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'path': path,
        if (description != null) 'description': description!,
        if (hidden != null) 'hidden': hidden!,
        'source': source.toJson(),
      };
}

/// `Reference.Source`
sealed class ReferenceSource {
  const ReferenceSource();

  /// Decodes a payload into the matching variant.
  factory ReferenceSource.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'local' => ReferenceLocalSource.fromJson(json),
      'git' => ReferenceGitSource.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Reference.Source discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Reference.LocalSource`
final class ReferenceLocalSource extends ReferenceSource {
  const ReferenceLocalSource({
    required this.path,
  });

  factory ReferenceLocalSource.fromJson(Map<String, Object?> json) =>
      ReferenceLocalSource(
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
      );

  final AbsolutePath path;

  /// Always `local`.
  @override
  String get type => 'local';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'local',
        'path': path,
      };
}

/// `Rpc.Input`
final class RpcInput {
  const RpcInput({
    this.input,
  });

  factory RpcInput.fromJson(Map<String, Object?> json) => RpcInput(
        input: json['input'],
      );

  final Object? input;

  Map<String, Object?> toJson() => <String, Object?>{
        if (input != null) 'input': input!,
      };
}

/// `Rpc.Output`
final class RpcOutput {
  const RpcOutput({
    this.output,
  });

  factory RpcOutput.fromJson(Map<String, Object?> json) => RpcOutput(
        output: json['output'],
      );

  final Object? output;

  Map<String, Object?> toJson() => <String, Object?>{
        if (output != null) 'output': output!,
      };
}

/// `Schedule.Action.Prompt`
final class ScheduleActionPrompt {
  const ScheduleActionPrompt({
    required this.prompt,
  });

  factory ScheduleActionPrompt.fromJson(Map<String, Object?> json) =>
      ScheduleActionPrompt(
        prompt: decodeString(json, 'prompt'),
      );

  final String prompt;

  /// Always `prompt`.
  String get type => 'prompt';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'prompt',
        'prompt': prompt,
      };
}

/// `Schedule.Condition`
sealed class ScheduleCondition {
  const ScheduleCondition();

  /// Decodes a payload into the matching variant.
  factory ScheduleCondition.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'shell' => ScheduleConditionShell.fromJson(json),
      'code' => ScheduleConditionCode.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Schedule.Condition discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Schedule.Condition.Shell`
final class ScheduleConditionShell extends ScheduleCondition {
  const ScheduleConditionShell({
    required this.run,
    this.isValue,
    this.matches,
    this.changes,
  });

  factory ScheduleConditionShell.fromJson(Map<String, Object?> json) =>
      ScheduleConditionShell(
        run: decodeString(json, 'run'),
        isValue: decodeOptionalString(json, 'is'),
        matches: decodeOptionalString(json, 'matches'),
        changes: decodeOptionalBool(json, 'changes'),
      );

  final String run;

  /// Wire field: `is`.
  final String? isValue;
  final String? matches;
  final bool? changes;

  /// Always `shell`.
  @override
  String get type => 'shell';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'shell',
        'run': run,
        if (isValue != null) 'is': isValue!,
        if (matches != null) 'matches': matches!,
        if (changes != null) 'changes': changes!,
      };
}

/// `Schedule.Condition.Code`
final class ScheduleConditionCode extends ScheduleCondition {
  const ScheduleConditionCode({
    required this.code,
  });

  factory ScheduleConditionCode.fromJson(Map<String, Object?> json) =>
      ScheduleConditionCode(
        code: decodeString(json, 'code'),
      );

  final String code;

  /// Always `code`.
  @override
  String get type => 'code';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'code',
        'code': code,
      };
}

/// `Schedule.CreatePayload`
final class ScheduleCreatePayload {
  const ScheduleCreatePayload({
    required this.sessionID,
    this.name,
    this.when,
    this.ifValue,
    this.until,
    this.ends,
    required this.prompt,
  });

  factory ScheduleCreatePayload.fromJson(Map<String, Object?> json) =>
      ScheduleCreatePayload(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        name: decodeOptionalString(json, 'name'),
        when: json['when'] == null
            ? null
            : ScheduleWhen.fromJson(asJsonMap(json['when'])),
        ifValue: json['if'] == null
            ? null
            : ScheduleCondition.fromJson(asJsonMap(json['if'])),
        until: json['until'] == null
            ? null
            : ScheduleCondition.fromJson(asJsonMap(json['until'])),
        ends: json['ends'] == null
            ? null
            : ScheduleEnds.fromJson(asJsonMap(json['ends'])),
        prompt: decodeString(json, 'prompt'),
      );

  final SessionID sessionID;
  final String? name;
  final ScheduleWhen? when;

  /// Wire field: `if`.
  final ScheduleCondition? ifValue;
  final ScheduleCondition? until;
  final ScheduleEnds? ends;
  final String prompt;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        if (name != null) 'name': name!,
        if (when != null) 'when': when!.toJson(),
        if (ifValue != null) 'if': ifValue!.toJson(),
        if (until != null) 'until': until!.toJson(),
        if (ends != null) 'ends': ends!.toJson(),
        'prompt': prompt,
      };
}

/// `Schedule.When`
sealed class ScheduleWhen {
  const ScheduleWhen();

  /// Decodes a payload into the matching variant.
  factory ScheduleWhen.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'in' => ScheduleWhenIn.fromJson(json),
      'at' => ScheduleWhenAt.fromJson(json),
      'every' => ScheduleWhenEvery.fromJson(json),
      'cron' => ScheduleWhenCron.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Schedule.When discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`tz`).
  String? get tz;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Schedule.When.In`
final class ScheduleWhenIn extends ScheduleWhen {
  const ScheduleWhenIn({
    required this.inValue,
    this.tz,
  });

  factory ScheduleWhenIn.fromJson(Map<String, Object?> json) => ScheduleWhenIn(
        inValue: ScheduleDuration.fromJson(asJsonString(json['in'])),
        tz: decodeOptionalString(json, 'tz'),
      );

  /// Wire field: `in`.
  final ScheduleDuration inValue;
  @override
  final String? tz;

  /// Always `in`.
  @override
  String get type => 'in';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'in',
        'in': inValue,
        if (tz != null) 'tz': tz!,
      };
}

/// `Schedule.When.At`
final class ScheduleWhenAt extends ScheduleWhen {
  const ScheduleWhenAt({
    required this.at,
    this.tz,
  });

  factory ScheduleWhenAt.fromJson(Map<String, Object?> json) => ScheduleWhenAt(
        at: decodeString(json, 'at'),
        tz: decodeOptionalString(json, 'tz'),
      );

  final String at;
  @override
  final String? tz;

  /// Always `at`.
  @override
  String get type => 'at';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'at',
        'at': at,
        if (tz != null) 'tz': tz!,
      };
}

/// `Schedule.When.Every`
final class ScheduleWhenEvery extends ScheduleWhen {
  const ScheduleWhenEvery({
    required this.every,
    this.tz,
  });

  factory ScheduleWhenEvery.fromJson(Map<String, Object?> json) =>
      ScheduleWhenEvery(
        every: ScheduleDuration.fromJson(asJsonString(json['every'])),
        tz: decodeOptionalString(json, 'tz'),
      );

  final ScheduleDuration every;
  @override
  final String? tz;

  /// Always `every`.
  @override
  String get type => 'every';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'every',
        'every': every,
        if (tz != null) 'tz': tz!,
      };
}

/// `Schedule.When.Cron`
final class ScheduleWhenCron extends ScheduleWhen {
  const ScheduleWhenCron({
    required this.cron,
    this.tz,
  });

  factory ScheduleWhenCron.fromJson(Map<String, Object?> json) =>
      ScheduleWhenCron(
        cron: decodeString(json, 'cron'),
        tz: decodeOptionalString(json, 'tz'),
      );

  final String cron;
  @override
  final String? tz;

  /// Always `cron`.
  @override
  String get type => 'cron';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'cron',
        'cron': cron,
        if (tz != null) 'tz': tz!,
      };
}

/// `Schedule.Ends`
final class ScheduleEnds {
  const ScheduleEnds({
    this.after,
    this.at,
    this.times,
  });

  factory ScheduleEnds.fromJson(Map<String, Object?> json) => ScheduleEnds(
        after: json['after'] == null
            ? null
            : ScheduleDuration.fromJson(asJsonString(json['after'])),
        at: decodeOptionalString(json, 'at'),
        times: decodeOptionalInt(json, 'times'),
      );

  final ScheduleDuration? after;
  final String? at;
  final int? times;

  Map<String, Object?> toJson() => <String, Object?>{
        if (after != null) 'after': after!,
        if (at != null) 'at': at!,
        if (times != null) 'times': times!,
      };
}

/// `Schedule.Info`
final class ScheduleInfo {
  const ScheduleInfo({
    required this.id,
    this.sessionID,
    this.name,
    required this.when,
    required this.tz,
    this.ifValue,
    this.until,
    required this.action,
    required this.status,
    this.nextDueAt,
    this.endsAt,
    this.remainingRuns,
    required this.runCount,
    this.lastFiredAt,
    this.lastOutcome,
    this.lastOutput,
    required this.time,
  });

  factory ScheduleInfo.fromJson(Map<String, Object?> json) => ScheduleInfo(
        id: ScheduleID.fromJson(asJsonString(json['id'])),
        sessionID: json['sessionID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['sessionID'])),
        name: decodeOptionalString(json, 'name'),
        when: ScheduleWhen.fromJson(asJsonMap(json['when'])),
        tz: decodeString(json, 'tz'),
        ifValue: json['if'] == null
            ? null
            : ScheduleCondition.fromJson(asJsonMap(json['if'])),
        until: json['until'] == null
            ? null
            : ScheduleCondition.fromJson(asJsonMap(json['until'])),
        action: ScheduleActionPrompt.fromJson(asJsonMap(json['action'])),
        status: ScheduleStatus.fromJson(json['status']),
        nextDueAt: decodeOptionalNumber(json, 'nextDueAt'),
        endsAt: decodeOptionalNumber(json, 'endsAt'),
        remainingRuns: decodeOptionalInt(json, 'remainingRuns'),
        runCount: decodeInt(json, 'runCount'),
        lastFiredAt: decodeOptionalNumber(json, 'lastFiredAt'),
        lastOutcome: json['lastOutcome'] == null
            ? null
            : ScheduleOutcome.fromJson(json['lastOutcome']),
        lastOutput: decodeOptionalString(json, 'lastOutput'),
        time: ScheduleInfoTime.fromJson(asJsonMap(json['time'])),
      );

  final ScheduleID id;
  final SessionID? sessionID;
  final String? name;
  final ScheduleWhen when;
  final String tz;

  /// Wire field: `if`.
  final ScheduleCondition? ifValue;
  final ScheduleCondition? until;
  final ScheduleActionPrompt action;
  final ScheduleStatus status;
  final double? nextDueAt;
  final double? endsAt;
  final int? remainingRuns;
  final int runCount;
  final double? lastFiredAt;
  final ScheduleOutcome? lastOutcome;
  final String? lastOutput;
  final ScheduleInfoTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (sessionID != null) 'sessionID': sessionID!,
        if (name != null) 'name': name!,
        'when': when.toJson(),
        'tz': tz,
        if (ifValue != null) 'if': ifValue!.toJson(),
        if (until != null) 'until': until!.toJson(),
        'action': action.toJson(),
        'status': status.wire,
        if (nextDueAt != null) 'nextDueAt': nextDueAt!,
        if (endsAt != null) 'endsAt': endsAt!,
        if (remainingRuns != null) 'remainingRuns': remainingRuns!,
        'runCount': runCount,
        if (lastFiredAt != null) 'lastFiredAt': lastFiredAt!,
        if (lastOutcome != null) 'lastOutcome': lastOutcome!.wire,
        if (lastOutput != null) 'lastOutput': lastOutput!,
        'time': time.toJson(),
      };
}

/// `ServerInfo`
final class ServerInfo {
  const ServerInfo({
    required this.version,
    required this.pid,
    this.hostname,
    required this.urls,
    required this.paths,
    this.capabilities,
  });

  factory ServerInfo.fromJson(Map<String, Object?> json) => ServerInfo(
        version: decodeString(json, 'version'),
        pid: decodeInt(json, 'pid'),
        hostname: decodeOptionalString(json, 'hostname'),
        urls: jsonList(json['urls'], (item) => asJsonString(item)),
        paths: ServerInfoPaths.fromJson(asJsonMap(json['paths'])),
        capabilities: json['capabilities'] == null
            ? null
            : ServerInfoCapabilities.fromJson(asJsonMap(json['capabilities'])),
      );

  final String version;
  final int pid;
  final String? hostname;
  final List<String> urls;
  final ServerInfoPaths paths;
  final ServerInfoCapabilities? capabilities;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
        'pid': pid,
        if (hostname != null) 'hostname': hostname!,
        'urls': urls,
        'paths': paths.toJson(),
        if (capabilities != null) 'capabilities': capabilities!.toJson(),
      };
}

/// `session.created`
final class SessionCreated extends SessionEventDurable {
  const SessionCreated({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionCreated.fromJson(Map<String, Object?> json) => SessionCreated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionCreatedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionCreatedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionCreatedDurable durable;
  @override
  final LocationRef? location;
  final SessionCreatedData data;

  /// Always `session.created`.
  @override
  String get type => 'session.created';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.created',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.agent.selected`
final class SessionAgentSelected extends SessionEventDurable {
  const SessionAgentSelected({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionAgentSelected.fromJson(Map<String, Object?> json) =>
      SessionAgentSelected(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionAgentSelectedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionAgentSelectedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionAgentSelectedDurable durable;
  @override
  final LocationRef? location;
  final SessionAgentSelectedData data;

  /// Always `session.agent.selected`.
  @override
  String get type => 'session.agent.selected';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.agent.selected',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.model.selected`
final class SessionModelSelected extends SessionEventDurable {
  const SessionModelSelected({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionModelSelected.fromJson(Map<String, Object?> json) =>
      SessionModelSelected(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionModelSelectedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionModelSelectedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionModelSelectedDurable durable;
  @override
  final LocationRef? location;
  final SessionModelSelectedData data;

  /// Always `session.model.selected`.
  @override
  String get type => 'session.model.selected';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.model.selected',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.moved`
final class SessionMoved extends SessionEventDurable {
  const SessionMoved({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionMoved.fromJson(Map<String, Object?> json) => SessionMoved(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionMovedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionMovedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionMovedDurable durable;
  @override
  final LocationRef? location;
  final SessionMovedData data;

  /// Always `session.moved`.
  @override
  String get type => 'session.moved';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.moved',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.renamed`
final class SessionRenamed extends SessionEventDurable {
  const SessionRenamed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionRenamed.fromJson(Map<String, Object?> json) => SessionRenamed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionRenamedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionRenamedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionRenamedDurable durable;
  @override
  final LocationRef? location;
  final SessionRenamedData data;

  /// Always `session.renamed`.
  @override
  String get type => 'session.renamed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.renamed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.metadata.updated`
final class SessionMetadataUpdated extends SessionEventDurable {
  const SessionMetadataUpdated({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionMetadataUpdated.fromJson(Map<String, Object?> json) =>
      SessionMetadataUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionMetadataUpdatedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionMetadataUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionMetadataUpdatedDurable durable;
  @override
  final LocationRef? location;
  final SessionMetadataUpdatedData data;

  /// Always `session.metadata.updated`.
  @override
  String get type => 'session.metadata.updated';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.metadata.updated',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.permissions`
final class SessionPermissions extends SessionEventDurable {
  const SessionPermissions({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionPermissions.fromJson(Map<String, Object?> json) =>
      SessionPermissions(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionPermissionsDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionPermissionsData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionPermissionsDurable durable;
  @override
  final LocationRef? location;
  final SessionPermissionsData data;

  /// Always `session.permissions`.
  @override
  String get type => 'session.permissions';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.permissions',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.viewed`
final class SessionViewed extends SessionEventDurable {
  const SessionViewed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionViewed.fromJson(Map<String, Object?> json) => SessionViewed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionViewedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionViewedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionViewedDurable durable;
  @override
  final LocationRef? location;
  final SessionViewedData data;

  /// Always `session.viewed`.
  @override
  String get type => 'session.viewed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.viewed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.archived`
final class SessionArchived extends SessionEventDurable {
  const SessionArchived({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionArchived.fromJson(Map<String, Object?> json) =>
      SessionArchived(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionArchivedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionArchivedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionArchivedDurable durable;
  @override
  final LocationRef? location;
  final SessionArchivedData data;

  /// Always `session.archived`.
  @override
  String get type => 'session.archived';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.archived',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.unarchived`
final class SessionUnarchived extends SessionEventDurable {
  const SessionUnarchived({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionUnarchived.fromJson(Map<String, Object?> json) =>
      SessionUnarchived(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionUnarchivedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionUnarchivedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionUnarchivedDurable durable;
  @override
  final LocationRef? location;
  final SessionUnarchivedData data;

  /// Always `session.unarchived`.
  @override
  String get type => 'session.unarchived';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.unarchived',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.deleted`
final class SessionDeleted extends SessionEventDurable {
  const SessionDeleted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionDeleted.fromJson(Map<String, Object?> json) => SessionDeleted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionDeletedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionDeletedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionDeletedDurable durable;
  @override
  final LocationRef? location;
  final SessionDeletedData data;

  /// Always `session.deleted`.
  @override
  String get type => 'session.deleted';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.deleted',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.forked`
final class SessionForked extends SessionEventDurable {
  const SessionForked({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionForked.fromJson(Map<String, Object?> json) => SessionForked(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionForkedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionForkedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionForkedDurable durable;
  @override
  final LocationRef? location;
  final SessionForkedData data;

  /// Always `session.forked`.
  @override
  String get type => 'session.forked';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.forked',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.inbox.delivered`
final class SessionInboxDelivered extends SessionEventDurable {
  const SessionInboxDelivered({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionInboxDelivered.fromJson(Map<String, Object?> json) =>
      SessionInboxDelivered(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionInboxDeliveredDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionInboxDeliveredData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionInboxDeliveredDurable durable;
  @override
  final LocationRef? location;
  final SessionInboxDeliveredData data;

  /// Always `session.inbox.delivered`.
  @override
  String get type => 'session.inbox.delivered';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.inbox.delivered',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.inbox.enqueued`
final class SessionInboxEnqueued extends SessionEventDurable {
  const SessionInboxEnqueued({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionInboxEnqueued.fromJson(Map<String, Object?> json) =>
      SessionInboxEnqueued(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionInboxEnqueuedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionInboxEnqueuedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionInboxEnqueuedDurable durable;
  @override
  final LocationRef? location;
  final SessionInboxEnqueuedData data;

  /// Always `session.inbox.enqueued`.
  @override
  String get type => 'session.inbox.enqueued';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.inbox.enqueued',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.inbox.cancelled`
final class SessionInboxCancelled extends SessionEventDurable {
  const SessionInboxCancelled({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionInboxCancelled.fromJson(Map<String, Object?> json) =>
      SessionInboxCancelled(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionInboxCancelledDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionInboxCancelledData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionInboxCancelledDurable durable;
  @override
  final LocationRef? location;
  final SessionInboxCancelledData data;

  /// Always `session.inbox.cancelled`.
  @override
  String get type => 'session.inbox.cancelled';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.inbox.cancelled',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.inbox.delivery.changed`
final class SessionInboxDeliveryChanged extends SessionEventDurable {
  const SessionInboxDeliveryChanged({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionInboxDeliveryChanged.fromJson(Map<String, Object?> json) =>
      SessionInboxDeliveryChanged(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionInboxDeliveryChangedDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionInboxDeliveryChangedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionInboxDeliveryChangedDurable durable;
  @override
  final LocationRef? location;
  final SessionInboxDeliveryChangedData data;

  /// Always `session.inbox.delivery.changed`.
  @override
  String get type => 'session.inbox.delivery.changed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.inbox.delivery.changed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.execution.started`
final class SessionExecutionStarted extends SessionEventDurable {
  const SessionExecutionStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionExecutionStarted.fromJson(Map<String, Object?> json) =>
      SessionExecutionStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionExecutionStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionExecutionStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionExecutionStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionExecutionStartedData data;

  /// Always `session.execution.started`.
  @override
  String get type => 'session.execution.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.execution.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.execution.succeeded`
final class SessionExecutionSucceeded extends SessionEventDurable {
  const SessionExecutionSucceeded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionExecutionSucceeded.fromJson(Map<String, Object?> json) =>
      SessionExecutionSucceeded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionExecutionSucceededDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionExecutionSucceededData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionExecutionSucceededDurable durable;
  @override
  final LocationRef? location;
  final SessionExecutionSucceededData data;

  /// Always `session.execution.succeeded`.
  @override
  String get type => 'session.execution.succeeded';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.execution.succeeded',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.execution.failed`
final class SessionExecutionFailed extends SessionEventDurable {
  const SessionExecutionFailed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionExecutionFailed.fromJson(Map<String, Object?> json) =>
      SessionExecutionFailed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionExecutionFailedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionExecutionFailedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionExecutionFailedDurable durable;
  @override
  final LocationRef? location;
  final SessionExecutionFailedData data;

  /// Always `session.execution.failed`.
  @override
  String get type => 'session.execution.failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.execution.failed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.execution.interrupted`
final class SessionExecutionInterrupted extends SessionEventDurable {
  const SessionExecutionInterrupted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionExecutionInterrupted.fromJson(Map<String, Object?> json) =>
      SessionExecutionInterrupted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionExecutionInterruptedDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionExecutionInterruptedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionExecutionInterruptedDurable durable;
  @override
  final LocationRef? location;
  final SessionExecutionInterruptedData data;

  /// Always `session.execution.interrupted`.
  @override
  String get type => 'session.execution.interrupted';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.execution.interrupted',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.instructions.updated`
final class SessionInstructionsUpdated extends SessionEventDurable {
  const SessionInstructionsUpdated({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionInstructionsUpdated.fromJson(Map<String, Object?> json) =>
      SessionInstructionsUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionInstructionsUpdatedDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionInstructionsUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionInstructionsUpdatedDurable durable;
  @override
  final LocationRef? location;
  final SessionInstructionsUpdatedData data;

  /// Always `session.instructions.updated`.
  @override
  String get type => 'session.instructions.updated';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.instructions.updated',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.synthetic`
final class SessionSynthetic extends SessionEventDurable {
  const SessionSynthetic({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionSynthetic.fromJson(Map<String, Object?> json) =>
      SessionSynthetic(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionSyntheticDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionSyntheticData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionSyntheticDurable durable;
  @override
  final LocationRef? location;
  final SessionSyntheticData data;

  /// Always `session.synthetic`.
  @override
  String get type => 'session.synthetic';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.synthetic',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.skill.activated`
final class SessionSkillActivated extends SessionEventDurable {
  const SessionSkillActivated({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionSkillActivated.fromJson(Map<String, Object?> json) =>
      SessionSkillActivated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionSkillActivatedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionSkillActivatedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionSkillActivatedDurable durable;
  @override
  final LocationRef? location;
  final SessionSkillActivatedData data;

  /// Always `session.skill.activated`.
  @override
  String get type => 'session.skill.activated';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.skill.activated',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.shell.started`
final class SessionShellStarted extends SessionEventDurable {
  const SessionShellStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionShellStarted.fromJson(Map<String, Object?> json) =>
      SessionShellStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionShellStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionShellStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionShellStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionShellStartedData data;

  /// Always `session.shell.started`.
  @override
  String get type => 'session.shell.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.shell.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `Shell.Info`
final class ShellInfo {
  const ShellInfo({
    required this.id,
    required this.status,
    required this.command,
    required this.cwd,
    required this.shell,
    required this.file,
    this.pid,
    this.exit,
    this.signal,
    required this.metadata,
    required this.time,
  });

  factory ShellInfo.fromJson(Map<String, Object?> json) => ShellInfo(
        id: ShellID.fromJson(asJsonString(json['id'])),
        status: ShellInfoStatus.fromJson(json['status']),
        command: decodeString(json, 'command'),
        cwd: decodeString(json, 'cwd'),
        shell: decodeString(json, 'shell'),
        file: decodeString(json, 'file'),
        pid: decodeOptionalInt(json, 'pid'),
        exit: decodeOptionalNumber(json, 'exit'),
        signal: decodeOptionalString(json, 'signal'),
        metadata: asJsonMap(json['metadata']),
        time: ShellInfoTime.fromJson(asJsonMap(json['time'])),
      );

  final ShellID id;
  final ShellInfoStatus status;
  final String command;
  final String cwd;
  final String shell;
  final String file;
  final int? pid;
  final double? exit;
  final String? signal;
  final Map<String, Object?> metadata;
  final ShellInfoTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'status': status.wire,
        'command': command,
        'cwd': cwd,
        'shell': shell,
        'file': file,
        if (pid != null) 'pid': pid!,
        if (exit != null) 'exit': exit!,
        if (signal != null) 'signal': signal!,
        'metadata': metadata,
        'time': time.toJson(),
      };
}

/// `session.shell.ended`
final class SessionShellEnded extends SessionEventDurable {
  const SessionShellEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionShellEnded.fromJson(Map<String, Object?> json) =>
      SessionShellEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionShellEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionShellEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionShellEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionShellEndedData data;

  /// Always `session.shell.ended`.
  @override
  String get type => 'session.shell.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.shell.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.step.started`
final class SessionStepStarted extends SessionEventDurable {
  const SessionStepStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionStepStarted.fromJson(Map<String, Object?> json) =>
      SessionStepStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionStepStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStepStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionStepStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionStepStartedData data;

  /// Always `session.step.started`.
  @override
  String get type => 'session.step.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.step.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.step.first-token`
final class SessionStepFirstToken extends SessionEventDurable {
  const SessionStepFirstToken({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionStepFirstToken.fromJson(Map<String, Object?> json) =>
      SessionStepFirstToken(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionStepFirstTokenDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStepFirstTokenData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionStepFirstTokenDurable durable;
  @override
  final LocationRef? location;
  final SessionStepFirstTokenData data;

  /// Always `session.step.first-token`.
  @override
  String get type => 'session.step.first-token';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.step.first-token',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.step.streamed`
final class SessionStepStreamed extends SessionEventDurable {
  const SessionStepStreamed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionStepStreamed.fromJson(Map<String, Object?> json) =>
      SessionStepStreamed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionStepStreamedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStepStreamedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionStepStreamedDurable durable;
  @override
  final LocationRef? location;
  final SessionStepStreamedData data;

  /// Always `session.step.streamed`.
  @override
  String get type => 'session.step.streamed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.step.streamed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.step.ended`
final class SessionStepEnded extends SessionEventDurable {
  const SessionStepEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionStepEnded.fromJson(Map<String, Object?> json) =>
      SessionStepEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionStepEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStepEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionStepEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionStepEndedData data;

  /// Always `session.step.ended`.
  @override
  String get type => 'session.step.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.step.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.step.failed`
final class SessionStepFailed extends SessionEventDurable {
  const SessionStepFailed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionStepFailed.fromJson(Map<String, Object?> json) =>
      SessionStepFailed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionStepFailedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStepFailedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionStepFailedDurable durable;
  @override
  final LocationRef? location;
  final SessionStepFailedData data;

  /// Always `session.step.failed`.
  @override
  String get type => 'session.step.failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.step.failed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.text.started`
final class SessionTextStarted extends SessionEventDurable {
  const SessionTextStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionTextStarted.fromJson(Map<String, Object?> json) =>
      SessionTextStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionTextStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionTextStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionTextStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionTextStartedData data;

  /// Always `session.text.started`.
  @override
  String get type => 'session.text.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.text.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.text.ended`
final class SessionTextEnded extends SessionEventDurable {
  const SessionTextEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionTextEnded.fromJson(Map<String, Object?> json) =>
      SessionTextEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionTextEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionTextEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionTextEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionTextEndedData data;

  /// Always `session.text.ended`.
  @override
  String get type => 'session.text.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.text.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.reasoning.started`
final class SessionReasoningStarted extends SessionEventDurable {
  const SessionReasoningStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionReasoningStarted.fromJson(Map<String, Object?> json) =>
      SessionReasoningStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionReasoningStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionReasoningStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionReasoningStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionReasoningStartedData data;

  /// Always `session.reasoning.started`.
  @override
  String get type => 'session.reasoning.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.reasoning.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.reasoning.ended`
final class SessionReasoningEnded extends SessionEventDurable {
  const SessionReasoningEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionReasoningEnded.fromJson(Map<String, Object?> json) =>
      SessionReasoningEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionReasoningEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionReasoningEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionReasoningEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionReasoningEndedData data;

  /// Always `session.reasoning.ended`.
  @override
  String get type => 'session.reasoning.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.reasoning.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.input.started`
final class SessionToolInputStarted extends SessionEventDurable {
  const SessionToolInputStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionToolInputStarted.fromJson(Map<String, Object?> json) =>
      SessionToolInputStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionToolInputStartedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolInputStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionToolInputStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionToolInputStartedData data;

  /// Always `session.tool.input.started`.
  @override
  String get type => 'session.tool.input.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.input.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.input.ended`
final class SessionToolInputEnded extends SessionEventDurable {
  const SessionToolInputEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionToolInputEnded.fromJson(Map<String, Object?> json) =>
      SessionToolInputEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionToolInputEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolInputEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionToolInputEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionToolInputEndedData data;

  /// Always `session.tool.input.ended`.
  @override
  String get type => 'session.tool.input.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.input.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.called`
final class SessionToolCalled extends SessionEventDurable {
  const SessionToolCalled({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionToolCalled.fromJson(Map<String, Object?> json) =>
      SessionToolCalled(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionToolCalledDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolCalledData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionToolCalledDurable durable;
  @override
  final LocationRef? location;
  final SessionToolCalledData data;

  /// Always `session.tool.called`.
  @override
  String get type => 'session.tool.called';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.called',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.success`
final class SessionToolSuccess extends SessionEventDurable {
  const SessionToolSuccess({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionToolSuccess.fromJson(Map<String, Object?> json) =>
      SessionToolSuccess(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionToolSuccessDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolSuccessData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionToolSuccessDurable durable;
  @override
  final LocationRef? location;
  final SessionToolSuccessData data;

  /// Always `session.tool.success`.
  @override
  String get type => 'session.tool.success';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.success',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `Tool.Content`
sealed class ToolContent {
  const ToolContent();

  /// Decodes a payload into the matching variant.
  factory ToolContent.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'text' => ToolTextContent.fromJson(json),
      'file' => ToolFileContent.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Tool.Content discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Tool.TextContent`
final class ToolTextContent extends ToolContent {
  const ToolTextContent({
    required this.text,
  });

  factory ToolTextContent.fromJson(Map<String, Object?> json) =>
      ToolTextContent(
        text: decodeString(json, 'text'),
      );

  final String text;

  /// Always `text`.
  @override
  String get type => 'text';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'text',
        'text': text,
      };
}

/// `Tool.FileContent`
final class ToolFileContent extends ToolContent {
  const ToolFileContent({
    required this.uri,
    required this.mime,
    this.name,
  });

  factory ToolFileContent.fromJson(Map<String, Object?> json) =>
      ToolFileContent(
        uri: decodeString(json, 'uri'),
        mime: decodeString(json, 'mime'),
        name: decodeOptionalString(json, 'name'),
      );

  final String uri;
  final String mime;
  final String? name;

  /// Always `file`.
  @override
  String get type => 'file';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'file',
        'uri': uri,
        'mime': mime,
        if (name != null) 'name': name!,
      };
}

/// `session.tool.failed`
final class SessionToolFailed extends SessionEventDurable {
  const SessionToolFailed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionToolFailed.fromJson(Map<String, Object?> json) =>
      SessionToolFailed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionToolFailedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolFailedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionToolFailedDurable durable;
  @override
  final LocationRef? location;
  final SessionToolFailedData data;

  /// Always `session.tool.failed`.
  @override
  String get type => 'session.tool.failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.failed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.retry.scheduled`
final class SessionRetryScheduled extends SessionEventDurable {
  const SessionRetryScheduled({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionRetryScheduled.fromJson(Map<String, Object?> json) =>
      SessionRetryScheduled(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionRetryScheduledDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionRetryScheduledData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionRetryScheduledDurable durable;
  @override
  final LocationRef? location;
  final SessionRetryScheduledData data;

  /// Always `session.retry.scheduled`.
  @override
  String get type => 'session.retry.scheduled';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.retry.scheduled',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.compaction.started`
final class SessionCompactionStarted extends SessionEventDurable {
  const SessionCompactionStarted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionCompactionStarted.fromJson(Map<String, Object?> json) =>
      SessionCompactionStarted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionCompactionStartedDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionCompactionStartedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionCompactionStartedDurable durable;
  @override
  final LocationRef? location;
  final SessionCompactionStartedData data;

  /// Always `session.compaction.started`.
  @override
  String get type => 'session.compaction.started';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.compaction.started',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.compaction.ended`
final class SessionCompactionEnded extends SessionEventDurable {
  const SessionCompactionEnded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionCompactionEnded.fromJson(Map<String, Object?> json) =>
      SessionCompactionEnded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionCompactionEndedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionCompactionEndedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionCompactionEndedDurable durable;
  @override
  final LocationRef? location;
  final SessionCompactionEndedData data;

  /// Always `session.compaction.ended`.
  @override
  String get type => 'session.compaction.ended';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.compaction.ended',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.compaction.failed`
final class SessionCompactionFailed extends SessionEventDurable {
  const SessionCompactionFailed({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionCompactionFailed.fromJson(Map<String, Object?> json) =>
      SessionCompactionFailed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionCompactionFailedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionCompactionFailedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionCompactionFailedDurable durable;
  @override
  final LocationRef? location;
  final SessionCompactionFailedData data;

  /// Always `session.compaction.failed`.
  @override
  String get type => 'session.compaction.failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.compaction.failed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.revert.staged`
final class SessionRevertStaged extends SessionEventDurable {
  const SessionRevertStaged({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionRevertStaged.fromJson(Map<String, Object?> json) =>
      SessionRevertStaged(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionRevertStagedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionRevertStagedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionRevertStagedDurable durable;
  @override
  final LocationRef? location;
  final SessionRevertStagedData data;

  /// Always `session.revert.staged`.
  @override
  String get type => 'session.revert.staged';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.revert.staged',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.revert.cleared`
final class SessionRevertCleared extends SessionEventDurable {
  const SessionRevertCleared({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionRevertCleared.fromJson(Map<String, Object?> json) =>
      SessionRevertCleared(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionRevertClearedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionRevertClearedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionRevertClearedDurable durable;
  @override
  final LocationRef? location;
  final SessionRevertClearedData data;

  /// Always `session.revert.cleared`.
  @override
  String get type => 'session.revert.cleared';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.revert.cleared',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.revert.committed`
final class SessionRevertCommitted extends SessionEventDurable {
  const SessionRevertCommitted({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionRevertCommitted.fromJson(Map<String, Object?> json) =>
      SessionRevertCommitted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionRevertCommittedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionRevertCommittedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionRevertCommittedDurable durable;
  @override
  final LocationRef? location;
  final SessionRevertCommittedData data;

  /// Always `session.revert.committed`.
  @override
  String get type => 'session.revert.committed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.revert.committed',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.usage.recorded`
final class SessionUsageRecorded extends SessionEventDurable {
  const SessionUsageRecorded({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionUsageRecorded.fromJson(Map<String, Object?> json) =>
      SessionUsageRecorded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable:
            SessionUsageRecordedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionUsageRecordedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionUsageRecordedDurable durable;
  @override
  final LocationRef? location;
  final SessionUsageRecordedData data;

  /// Always `session.usage.recorded`.
  @override
  String get type => 'session.usage.recorded';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.usage.recorded',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.message.content.updated`
final class SessionMessageContentUpdated extends SessionEventDurable {
  const SessionMessageContentUpdated({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory SessionMessageContentUpdated.fromJson(Map<String, Object?> json) =>
      SessionMessageContentUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: SessionMessageContentUpdatedDurable.fromJson(
            asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data:
            SessionMessageContentUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  @override
  final EventID id;
  @override
  final double created;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageContentUpdatedDurable durable;
  @override
  final LocationRef? location;
  final SessionMessageContentUpdatedData data;

  /// Always `session.message.content.updated`.
  @override
  String get type => 'session.message.content.updated';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.message.content.updated',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `SessionGenerateResponse`
final class SessionGenerateResponse {
  const SessionGenerateResponse({
    required this.data,
  });

  factory SessionGenerateResponse.fromJson(Map<String, Object?> json) =>
      SessionGenerateResponse(
        data: SessionGenerateResponseData.fromJson(asJsonMap(json['data'])),
      );

  final SessionGenerateResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `SessionInterruptResponse`
final class SessionInterruptResponse {
  const SessionInterruptResponse({
    required this.interrupted,
  });

  factory SessionInterruptResponse.fromJson(Map<String, Object?> json) =>
      SessionInterruptResponse(
        interrupted: decodeBool(json, 'interrupted'),
      );

  final bool interrupted;

  Map<String, Object?> toJson() => <String, Object?>{
        'interrupted': interrupted,
      };
}

/// `SessionMessagesResponse`
final class SessionMessagesResponse {
  const SessionMessagesResponse({
    required this.data,
    required this.cursor,
  });

  factory SessionMessagesResponse.fromJson(Map<String, Object?> json) =>
      SessionMessagesResponse(
        data: jsonList(json['data'],
            (item) => SessionMessageInfo.fromJson(asJsonMap(item))),
        cursor:
            SessionMessagesResponseCursor.fromJson(asJsonMap(json['cursor'])),
      );

  final List<SessionMessageInfo> data;
  final SessionMessagesResponseCursor cursor;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': [for (final item in data) item.toJson()],
        'cursor': cursor.toJson(),
      };
}

/// `SessionStatus`
sealed class SessionStatus {
  const SessionStatus();

  /// Decodes a payload into the matching variant.
  factory SessionStatus.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'idle' => SessionStatusIdle.fromJson(json),
      'retry' => SessionStatusRetry.fromJson(json),
      'busy' => SessionStatusBusy.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown SessionStatus discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionStatusIdle`
final class SessionStatusIdle extends SessionStatus {
  const SessionStatusIdle();

  factory SessionStatusIdle.fromJson(Map<String, Object?> json) =>
      SessionStatusIdle();

  /// Always `idle`.
  @override
  String get type => 'idle';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'idle',
      };
}

/// `SessionStatusRetry`
final class SessionStatusRetry extends SessionStatus {
  const SessionStatusRetry({
    required this.attempt,
    required this.message,
    this.action,
    required this.next,
  });

  factory SessionStatusRetry.fromJson(Map<String, Object?> json) =>
      SessionStatusRetry(
        attempt: decodeInt(json, 'attempt'),
        message: decodeString(json, 'message'),
        action: json['action'] == null
            ? null
            : SessionStatusRetryAction.fromJson(asJsonMap(json['action'])),
        next: decodeInt(json, 'next'),
      );

  final int attempt;
  final String message;
  final SessionStatusRetryAction? action;
  final int next;

  /// Always `retry`.
  @override
  String get type => 'retry';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'retry',
        'attempt': attempt,
        'message': message,
        if (action != null) 'action': action!.toJson(),
        'next': next,
      };
}

/// `SessionStatusBusy`
final class SessionStatusBusy extends SessionStatus {
  const SessionStatusBusy();

  factory SessionStatusBusy.fromJson(Map<String, Object?> json) =>
      SessionStatusBusy();

  /// Always `busy`.
  @override
  String get type => 'busy';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'busy',
      };
}

/// `SessionStatusUpdated`
final class SessionStatusUpdated {
  const SessionStatusUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionStatusUpdated.fromJson(Map<String, Object?> json) =>
      SessionStatusUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionStatusUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionStatusUpdatedData data;

  /// Always `session.status`.
  String get type => 'session.status';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.status',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `Skill.Info`
final class SkillInfo {
  const SkillInfo({
    required this.id,
    required this.name,
    this.description,
    this.autoinvoke,
    required this.path,
    required this.content,
  });

  factory SkillInfo.fromJson(Map<String, Object?> json) => SkillInfo(
        id: SkillID.fromJson(asJsonString(json['id'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        description: decodeOptionalString(json, 'description'),
        autoinvoke: decodeOptionalBool(json, 'autoinvoke'),
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
        content: decodeString(json, 'content'),
      );

  final SkillID id;
  final SkillName name;
  final String? description;
  final bool? autoinvoke;
  final AbsolutePath path;
  final String content;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (description != null) 'description': description!,
        if (autoinvoke != null) 'autoinvoke': autoinvoke!,
        'path': path,
        'content': content,
      };
}

/// `UsageLimits.Budget`
final class UsageLimitsBudget {
  const UsageLimitsBudget({
    required this.id,
    required this.limit,
    required this.spent,
    required this.scope,
    required this.per,
    required this.coverage,
    required this.models,
    required this.vendors,
    this.inputPriceAtLeast,
    required this.picked,
    required this.shared,
    required this.resetsAt,
  });

  factory UsageLimitsBudget.fromJson(Map<String, Object?> json) =>
      UsageLimitsBudget(
        id: decodeString(json, 'id'),
        limit: MoneyUSD.fromJson(asJsonDouble(json['limit'])),
        spent: MoneyUSD.fromJson(asJsonDouble(json['spent'])),
        scope: UsageLimitsBudgetScope.fromJson(json['scope']),
        per: UsageLimitsBudgetPer.fromJson(json['per']),
        coverage: UsageLimitsBudgetCoverage.fromJson(json['coverage']),
        models: jsonList(json['models'],
            (item) => UsageLimitsBudgetModel.fromJson(asJsonMap(item))),
        vendors: jsonList(json['vendors'], (item) => asJsonString(item)),
        inputPriceAtLeast: json['inputPriceAtLeast'] == null
            ? null
            : MoneyUSDPerMillionTokens.fromJson(
                asJsonDouble(json['inputPriceAtLeast'])),
        picked: decodeBool(json, 'picked'),
        shared: decodeBool(json, 'shared'),
        resetsAt: decodeNumber(json, 'resetsAt'),
      );

  final String id;
  final MoneyUSD limit;
  final MoneyUSD spent;
  final UsageLimitsBudgetScope scope;
  final UsageLimitsBudgetPer per;
  final UsageLimitsBudgetCoverage coverage;
  final List<UsageLimitsBudgetModel> models;
  final List<String> vendors;
  final MoneyUSDPerMillionTokens? inputPriceAtLeast;
  final bool picked;
  final bool shared;
  final double resetsAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'limit': limit,
        'spent': spent,
        'scope': scope.wire,
        'per': per.wire,
        'coverage': coverage.wire,
        'models': [for (final item in models) item.toJson()],
        'vendors': vendors,
        if (inputPriceAtLeast != null) 'inputPriceAtLeast': inputPriceAtLeast!,
        'picked': picked,
        'shared': shared,
        'resetsAt': resetsAt,
      };
}

/// `UsageLimits.BudgetModel`
final class UsageLimitsBudgetModel {
  const UsageLimitsBudgetModel({
    required this.providerID,
    required this.modelID,
    required this.name,
    this.spent,
  });

  factory UsageLimitsBudgetModel.fromJson(Map<String, Object?> json) =>
      UsageLimitsBudgetModel(
        providerID: ProviderID.fromJson(asJsonString(json['providerID'])),
        modelID: decodeString(json, 'modelID'),
        name: decodeString(json, 'name'),
        spent: json['spent'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['spent'])),
      );

  final ProviderID providerID;
  final String modelID;
  final String name;
  final MoneyUSD? spent;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
        'modelID': modelID,
        'name': name,
        if (spent != null) 'spent': spent!,
      };
}

/// `UsageLimits.Go`
final class UsageLimitsGo {
  const UsageLimitsGo({
    required this.rolling,
    required this.weekly,
    required this.monthly,
  });

  factory UsageLimitsGo.fromJson(Map<String, Object?> json) => UsageLimitsGo(
        rolling: UsageLimitsMeter.fromJson(asJsonMap(json['rolling'])),
        weekly: UsageLimitsMeter.fromJson(asJsonMap(json['weekly'])),
        monthly: UsageLimitsMeter.fromJson(asJsonMap(json['monthly'])),
      );

  final UsageLimitsMeter rolling;
  final UsageLimitsMeter weekly;
  final UsageLimitsMeter monthly;

  Map<String, Object?> toJson() => <String, Object?>{
        'rolling': rolling.toJson(),
        'weekly': weekly.toJson(),
        'monthly': monthly.toJson(),
      };
}

/// `UsageLimits.Meter`
final class UsageLimitsMeter {
  const UsageLimitsMeter({
    required this.percent,
    required this.limited,
    required this.resetsAt,
  });

  factory UsageLimitsMeter.fromJson(Map<String, Object?> json) =>
      UsageLimitsMeter(
        percent: decodeNumber(json, 'percent'),
        limited: decodeBool(json, 'limited'),
        resetsAt: decodeNumber(json, 'resetsAt'),
      );

  final double percent;
  final bool limited;
  final double resetsAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'percent': percent,
        'limited': limited,
        'resetsAt': resetsAt,
      };
}

/// `UsageLimits.Info`
final class UsageLimitsInfo {
  const UsageLimitsInfo({
    required this.workspace,
    this.go,
    required this.budgets,
  });

  factory UsageLimitsInfo.fromJson(Map<String, Object?> json) =>
      UsageLimitsInfo(
        workspace:
            UsageLimitsInfoWorkspace.fromJson(asJsonMap(json['workspace'])),
        go: json['go'] == null
            ? null
            : UsageLimitsGo.fromJson(asJsonMap(json['go'])),
        budgets: jsonList(json['budgets'],
            (item) => UsageLimitsBudget.fromJson(asJsonMap(item))),
      );

  final UsageLimitsInfoWorkspace workspace;
  final UsageLimitsGo? go;
  final List<UsageLimitsBudget> budgets;

  Map<String, Object?> toJson() => <String, Object?>{
        'workspace': workspace.toJson(),
        if (go != null) 'go': go!.toJson(),
        'budgets': [for (final item in budgets) item.toJson()],
      };
}

/// `V2Event.rpc`
final class V2EventRpc {
  const V2EventRpc({
    required this.id,
    required this.created,
    this.metadata,
    required this.type,
    required this.location,
    required this.data,
  });

  factory V2EventRpc.fromJson(Map<String, Object?> json) => V2EventRpc(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        type: decodeString(json, 'type'),
        location: LocationRef.fromJson(json['location']),
        data: asJsonMap(json['data']),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final String type;
  final LocationRef location;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': type,
        'location': location.toJson(),
        'data': data,
      };
}

/// `V2Event.server.connected`
final class V2EventServerConnected {
  const V2EventServerConnected({
    required this.id,
    this.metadata,
    this.location,
    required this.data,
  });

  factory V2EventServerConnected.fromJson(Map<String, Object?> json) =>
      V2EventServerConnected(
        id: EventID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `server.connected`.
  String get type => 'server.connected';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        if (location != null) 'location': location!.toJson(),
        'type': 'server.connected',
        'data': data,
      };
}

/// `VoiceModel`
final class VoiceModel {
  const VoiceModel({
    required this.model,
    required this.provider,
    required this.transports,
    required this.available,
  });

  factory VoiceModel.fromJson(Map<String, Object?> json) => VoiceModel(
        model: decodeString(json, 'model'),
        provider: decodeString(json, 'provider'),
        transports: jsonList(
            json['transports'], (item) => VoiceTransportType.fromJson(item)),
        available: decodeBool(json, 'available'),
      );

  final String model;
  final String provider;
  final List<VoiceTransportType> transports;
  final bool available;

  Map<String, Object?> toJson() => <String, Object?>{
        'model': model,
        'provider': provider,
        'transports': [for (final item in transports) item.wire],
        'available': available,
      };
}

/// `VoiceModelsResponse`
final class VoiceModelsResponse {
  const VoiceModelsResponse({
    required this.data,
  });

  factory VoiceModelsResponse.fromJson(Map<String, Object?> json) =>
      VoiceModelsResponse(
        data: VoiceModelsResponseData.fromJson(asJsonMap(json['data'])),
      );

  final VoiceModelsResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `VoiceSessionResponse`
final class VoiceSessionResponse {
  const VoiceSessionResponse({
    required this.data,
  });

  factory VoiceSessionResponse.fromJson(Map<String, Object?> json) =>
      VoiceSessionResponse(
        data: VoiceSessionResponseData.fromJson(asJsonMap(json['data'])),
      );

  final VoiceSessionResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `VoiceTransport`
sealed class VoiceTransport {
  const VoiceTransport();

  /// Decodes a payload into the matching variant.
  factory VoiceTransport.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'webrtc' => VoiceWebRTCTransport.fromJson(json),
      'websocket' => VoiceWebSocketTransport.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown VoiceTransport discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `VoiceWebRTCTransport`
final class VoiceWebRTCTransport extends VoiceTransport {
  const VoiceWebRTCTransport({
    required this.sdp,
  });

  factory VoiceWebRTCTransport.fromJson(Map<String, Object?> json) =>
      VoiceWebRTCTransport(
        sdp: decodeString(json, 'sdp'),
      );

  final String sdp;

  /// Always `webrtc`.
  @override
  String get type => 'webrtc';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'webrtc',
        'sdp': sdp,
      };
}

/// `VoiceWebSocketTransport`
final class VoiceWebSocketTransport extends VoiceTransport {
  const VoiceWebSocketTransport({
    required this.url,
    required this.token,
    required this.expiresAt,
  });

  factory VoiceWebSocketTransport.fromJson(Map<String, Object?> json) =>
      VoiceWebSocketTransport(
        url: decodeString(json, 'url'),
        token: decodeString(json, 'token'),
        expiresAt: json['expiresAt'],
      );

  final String url;
  final String token;
  final Object? expiresAt;

  /// Always `websocket`.
  @override
  String get type => 'websocket';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'websocket',
        'url': url,
        'token': token,
        'expiresAt': expiresAt,
      };
}

/// `VoiceTransportInput`
sealed class VoiceTransportInput {
  const VoiceTransportInput();

  /// Decodes a payload into the matching variant.
  factory VoiceTransportInput.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'webrtc' => VoiceWebRTCTransportInput.fromJson(json),
      'websocket' => VoiceWebSocketTransportInput.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown VoiceTransportInput discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `VoiceWebRTCTransportInput`
final class VoiceWebRTCTransportInput extends VoiceTransportInput {
  const VoiceWebRTCTransportInput({
    required this.sdp,
    this.dcid,
  });

  factory VoiceWebRTCTransportInput.fromJson(Map<String, Object?> json) =>
      VoiceWebRTCTransportInput(
        sdp: decodeString(json, 'sdp'),
        dcid: json['dcid'],
      );

  final String sdp;
  final Object? dcid;

  /// Always `webrtc`.
  @override
  String get type => 'webrtc';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'webrtc',
        'sdp': sdp,
        if (dcid != null) 'dcid': dcid!,
      };
}

/// `VoiceWebSocketTransportInput`
final class VoiceWebSocketTransportInput extends VoiceTransportInput {
  const VoiceWebSocketTransportInput();

  factory VoiceWebSocketTransportInput.fromJson(Map<String, Object?> json) =>
      VoiceWebSocketTransportInput();

  /// Always `websocket`.
  @override
  String get type => 'websocket';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'websocket',
      };
}

/// `WebSearch.Provider`
final class WebSearchProvider {
  const WebSearchProvider({
    required this.id,
    required this.name,
  });

  factory WebSearchProvider.fromJson(Map<String, Object?> json) =>
      WebSearchProvider(
        id: WebSearchID.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
      );

  final WebSearchID id;
  final String name;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
      };
}

/// `WebSearch.ResponseEncoded`
final class WebSearchResponseEncoded {
  const WebSearchResponseEncoded({
    required this.providerID,
    required this.results,
  });

  factory WebSearchResponseEncoded.fromJson(Map<String, Object?> json) =>
      WebSearchResponseEncoded(
        providerID: WebSearchID.fromJson(asJsonString(json['providerID'])),
        results: jsonList(json['results'],
            (item) => WebSearchResult.fromJson(asJsonMap(item))),
      );

  final WebSearchID providerID;
  final List<WebSearchResult> results;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
        'results': [for (final item in results) item.toJson()],
      };
}

/// `WebSearch.Result`
final class WebSearchResult {
  const WebSearchResult({
    required this.url,
    this.title,
    this.content,
    required this.time,
  });

  factory WebSearchResult.fromJson(Map<String, Object?> json) =>
      WebSearchResult(
        url: decodeString(json, 'url'),
        title: decodeOptionalString(json, 'title'),
        content: decodeOptionalString(json, 'content'),
        time: WebSearchResultTime.fromJson(asJsonMap(json['time'])),
      );

  final String url;
  final String? title;
  final String? content;
  final WebSearchResultTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'url': url,
        if (title != null) 'title': title!,
        if (content != null) 'content': content!,
        'time': time.toJson(),
      };
}

/// `agent.updated`
final class AgentUpdated {
  const AgentUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory AgentUpdated.fromJson(Map<String, Object?> json) => AgentUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `agent.updated`.
  String get type => 'agent.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'agent.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `artifact.updated`
final class ArtifactUpdated {
  const ArtifactUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ArtifactUpdated.fromJson(Map<String, Object?> json) =>
      ArtifactUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `artifact.updated`.
  String get type => 'artifact.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'artifact.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `command.updated`
final class CommandUpdated {
  const CommandUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory CommandUpdated.fromJson(Map<String, Object?> json) => CommandUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `command.updated`.
  String get type => 'command.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'command.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `config.updated`
final class ConfigUpdated {
  const ConfigUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ConfigUpdated.fromJson(Map<String, Object?> json) => ConfigUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `config.updated`.
  String get type => 'config.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'config.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `credential.switched`
final class CredentialSwitched {
  const CredentialSwitched({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory CredentialSwitched.fromJson(Map<String, Object?> json) =>
      CredentialSwitched(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: CredentialSwitchedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final CredentialSwitchedData data;

  /// Always `credential.switched`.
  String get type => 'credential.switched';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'credential.switched',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `credential.updated`
final class CredentialUpdated {
  const CredentialUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory CredentialUpdated.fromJson(Map<String, Object?> json) =>
      CredentialUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: CredentialUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final CredentialUpdatedData data;

  /// Always `credential.updated`.
  String get type => 'credential.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'credential.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `experimental.mcp.event`
final class ExperimentalMcpEvent {
  const ExperimentalMcpEvent({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ExperimentalMcpEvent.fromJson(Map<String, Object?> json) =>
      ExperimentalMcpEvent(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: ExperimentalMcpEventData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final ExperimentalMcpEventData data;

  /// Always `experimental.mcp.event`.
  String get type => 'experimental.mcp.event';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'experimental.mcp.event',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `filesystem.changed`
final class FilesystemChanged {
  const FilesystemChanged({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory FilesystemChanged.fromJson(Map<String, Object?> json) =>
      FilesystemChanged(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: FilesystemChangedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final FilesystemChangedData data;

  /// Always `filesystem.changed`.
  String get type => 'filesystem.changed';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'filesystem.changed',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `form.cancelled`
final class FormCancelled {
  const FormCancelled({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory FormCancelled.fromJson(Map<String, Object?> json) => FormCancelled(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: FormCancelledData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final FormCancelledData data;

  /// Always `form.cancelled`.
  String get type => 'form.cancelled';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'form.cancelled',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `form.created`
final class FormCreated {
  const FormCreated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory FormCreated.fromJson(Map<String, Object?> json) => FormCreated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: FormCreatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final FormCreatedData data;

  /// Always `form.created`.
  String get type => 'form.created';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'form.created',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `form.replied`
final class FormReplied {
  const FormReplied({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory FormReplied.fromJson(Map<String, Object?> json) => FormReplied(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: FormRepliedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final FormRepliedData data;

  /// Always `form.replied`.
  String get type => 'form.replied';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'form.replied',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `installation.update-available`
final class InstallationUpdateAvailable {
  const InstallationUpdateAvailable({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory InstallationUpdateAvailable.fromJson(Map<String, Object?> json) =>
      InstallationUpdateAvailable(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: InstallationUpdateAvailableData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final InstallationUpdateAvailableData data;

  /// Always `installation.update-available`.
  String get type => 'installation.update-available';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'installation.update-available',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `installation.updated`
final class InstallationUpdated {
  const InstallationUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory InstallationUpdated.fromJson(Map<String, Object?> json) =>
      InstallationUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: InstallationUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final InstallationUpdatedData data;

  /// Always `installation.updated`.
  String get type => 'installation.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'installation.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `integration.updated`
final class IntegrationUpdated {
  const IntegrationUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory IntegrationUpdated.fromJson(Map<String, Object?> json) =>
      IntegrationUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `integration.updated`.
  String get type => 'integration.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'integration.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `location.shutdown`
final class LocationShutdown {
  const LocationShutdown({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory LocationShutdown.fromJson(Map<String, Object?> json) =>
      LocationShutdown(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `location.shutdown`.
  String get type => 'location.shutdown';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'location.shutdown',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `mcp.resources.changed`
final class McpResourcesChanged {
  const McpResourcesChanged({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory McpResourcesChanged.fromJson(Map<String, Object?> json) =>
      McpResourcesChanged(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: McpResourcesChangedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final McpResourcesChangedData data;

  /// Always `mcp.resources.changed`.
  String get type => 'mcp.resources.changed';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'mcp.resources.changed',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `mcp.status.changed`
final class McpStatusChanged {
  const McpStatusChanged({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory McpStatusChanged.fromJson(Map<String, Object?> json) =>
      McpStatusChanged(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: McpStatusChangedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final McpStatusChangedData data;

  /// Always `mcp.status.changed`.
  String get type => 'mcp.status.changed';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'mcp.status.changed',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `model.updated`
final class ModelUpdated {
  const ModelUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ModelUpdated.fromJson(Map<String, Object?> json) => ModelUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `model.updated`.
  String get type => 'model.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'model.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `models-dev.refreshed`
final class ModelsDevRefreshed {
  const ModelsDevRefreshed({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ModelsDevRefreshed.fromJson(Map<String, Object?> json) =>
      ModelsDevRefreshed(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `models-dev.refreshed`.
  String get type => 'models-dev.refreshed';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'models-dev.refreshed',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `permission.asked`
final class PermissionAsked {
  const PermissionAsked({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PermissionAsked.fromJson(Map<String, Object?> json) =>
      PermissionAsked(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PermissionAskedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PermissionAskedData data;

  /// Always `permission.asked`.
  String get type => 'permission.asked';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'permission.asked',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `permission.replied`
final class PermissionReplied {
  const PermissionReplied({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PermissionReplied.fromJson(Map<String, Object?> json) =>
      PermissionReplied(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PermissionRepliedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PermissionRepliedData data;

  /// Always `permission.replied`.
  String get type => 'permission.replied';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'permission.replied',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `persistent-pty.added`
final class PersistentPtyAdded {
  const PersistentPtyAdded({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PersistentPtyAdded.fromJson(Map<String, Object?> json) =>
      PersistentPtyAdded(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PersistentPtyAddedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PersistentPtyAddedData data;

  /// Always `persistent-pty.added`.
  String get type => 'persistent-pty.added';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'persistent-pty.added',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `persistent-pty.removed`
final class PersistentPtyRemoved {
  const PersistentPtyRemoved({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PersistentPtyRemoved.fromJson(Map<String, Object?> json) =>
      PersistentPtyRemoved(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PersistentPtyRemovedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PersistentPtyRemovedData data;

  /// Always `persistent-pty.removed`.
  String get type => 'persistent-pty.removed';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'persistent-pty.removed',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `persistent-pty.updated`
final class PersistentPtyUpdated {
  const PersistentPtyUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PersistentPtyUpdated.fromJson(Map<String, Object?> json) =>
      PersistentPtyUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PersistentPtyUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PersistentPtyUpdatedData data;

  /// Always `persistent-pty.updated`.
  String get type => 'persistent-pty.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'persistent-pty.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `plugin.updated`
final class PluginUpdated {
  const PluginUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PluginUpdated.fromJson(Map<String, Object?> json) => PluginUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `plugin.updated`.
  String get type => 'plugin.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'plugin.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `project.updated`
final class ProjectUpdated {
  const ProjectUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ProjectUpdated.fromJson(Map<String, Object?> json) => ProjectUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: ProjectUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final ProjectUpdatedData data;

  /// Always `project.updated`.
  String get type => 'project.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'project.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `provider.updated`
final class ProviderUpdated {
  const ProviderUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ProviderUpdated.fromJson(Map<String, Object?> json) =>
      ProviderUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `provider.updated`.
  String get type => 'provider.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'provider.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `pty.created`
final class PtyCreated {
  const PtyCreated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PtyCreated.fromJson(Map<String, Object?> json) => PtyCreated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PtyCreatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PtyCreatedData data;

  /// Always `pty.created`.
  String get type => 'pty.created';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'pty.created',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `pty.deleted`
final class PtyDeleted {
  const PtyDeleted({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PtyDeleted.fromJson(Map<String, Object?> json) => PtyDeleted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PtyDeletedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PtyDeletedData data;

  /// Always `pty.deleted`.
  String get type => 'pty.deleted';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'pty.deleted',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `pty.exited`
final class PtyExited {
  const PtyExited({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PtyExited.fromJson(Map<String, Object?> json) => PtyExited(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PtyExitedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PtyExitedData data;

  /// Always `pty.exited`.
  String get type => 'pty.exited';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'pty.exited',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `pty.updated`
final class PtyUpdated {
  const PtyUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory PtyUpdated.fromJson(Map<String, Object?> json) => PtyUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: PtyUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final PtyUpdatedData data;

  /// Always `pty.updated`.
  String get type => 'pty.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'pty.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `reference.updated`
final class ReferenceUpdated {
  const ReferenceUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ReferenceUpdated.fromJson(Map<String, Object?> json) =>
      ReferenceUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `reference.updated`.
  String get type => 'reference.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'reference.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `session.compaction.delta`
final class SessionCompactionDelta {
  const SessionCompactionDelta({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionCompactionDelta.fromJson(Map<String, Object?> json) =>
      SessionCompactionDelta(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionCompactionDeltaData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionCompactionDeltaData data;

  /// Always `session.compaction.delta`.
  String get type => 'session.compaction.delta';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.compaction.delta',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.idle`
final class SessionIdle {
  const SessionIdle({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionIdle.fromJson(Map<String, Object?> json) => SessionIdle(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionIdleData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionIdleData data;

  /// Always `session.idle`.
  String get type => 'session.idle';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.idle',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.reasoning.delta`
final class SessionReasoningDelta {
  const SessionReasoningDelta({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionReasoningDelta.fromJson(Map<String, Object?> json) =>
      SessionReasoningDelta(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionReasoningDeltaData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionReasoningDeltaData data;

  /// Always `session.reasoning.delta`.
  String get type => 'session.reasoning.delta';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.reasoning.delta',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.text.delta`
final class SessionTextDelta {
  const SessionTextDelta({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionTextDelta.fromJson(Map<String, Object?> json) =>
      SessionTextDelta(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionTextDeltaData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionTextDeltaData data;

  /// Always `session.text.delta`.
  String get type => 'session.text.delta';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.text.delta',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.input.delta`
final class SessionToolInputDelta {
  const SessionToolInputDelta({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionToolInputDelta.fromJson(Map<String, Object?> json) =>
      SessionToolInputDelta(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolInputDeltaData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionToolInputDeltaData data;

  /// Always `session.tool.input.delta`.
  String get type => 'session.tool.input.delta';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.input.delta',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.tool.progress`
final class SessionToolProgress {
  const SessionToolProgress({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionToolProgress.fromJson(Map<String, Object?> json) =>
      SessionToolProgress(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionToolProgressData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionToolProgressData data;

  /// Always `session.tool.progress`.
  String get type => 'session.tool.progress';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.tool.progress',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `session.usage.updated`
final class SessionUsageUpdated {
  const SessionUsageUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SessionUsageUpdated.fromJson(Map<String, Object?> json) =>
      SessionUsageUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: SessionUsageUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final SessionUsageUpdatedData data;

  /// Always `session.usage.updated`.
  String get type => 'session.usage.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'session.usage.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `shell.created`
final class ShellCreated {
  const ShellCreated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ShellCreated.fromJson(Map<String, Object?> json) => ShellCreated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: ShellCreatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final ShellCreatedData data;

  /// Always `shell.created`.
  String get type => 'shell.created';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'shell.created',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `shell.deleted`
final class ShellDeleted {
  const ShellDeleted({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ShellDeleted.fromJson(Map<String, Object?> json) => ShellDeleted(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: ShellDeletedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final ShellDeletedData data;

  /// Always `shell.deleted`.
  String get type => 'shell.deleted';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'shell.deleted',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `shell.exited`
final class ShellExited {
  const ShellExited({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory ShellExited.fromJson(Map<String, Object?> json) => ShellExited(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: ShellExitedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final ShellExitedData data;

  /// Always `shell.exited`.
  String get type => 'shell.exited';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'shell.exited',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `skill.updated`
final class SkillUpdated {
  const SkillUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory SkillUpdated.fromJson(Map<String, Object?> json) => SkillUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `skill.updated`.
  String get type => 'skill.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'skill.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `tui.command.execute`
final class TuiCommandExecute {
  const TuiCommandExecute({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory TuiCommandExecute.fromJson(Map<String, Object?> json) =>
      TuiCommandExecute(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: TuiCommandExecuteData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final TuiCommandExecuteData data;

  /// Always `tui.command.execute`.
  String get type => 'tui.command.execute';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'tui.command.execute',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `tui.prompt.append`
final class TuiPromptAppend {
  const TuiPromptAppend({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory TuiPromptAppend.fromJson(Map<String, Object?> json) =>
      TuiPromptAppend(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: TuiPromptAppendData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final TuiPromptAppendData data;

  /// Always `tui.prompt.append`.
  String get type => 'tui.prompt.append';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'tui.prompt.append',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `tui.session.select`
final class TuiSessionSelect {
  const TuiSessionSelect({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory TuiSessionSelect.fromJson(Map<String, Object?> json) =>
      TuiSessionSelect(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: TuiSessionSelectData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final TuiSessionSelectData data;

  /// Always `tui.session.select`.
  String get type => 'tui.session.select';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'tui.session.select',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `tui.toast.show`
final class TuiToastShow {
  const TuiToastShow({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory TuiToastShow.fromJson(Map<String, Object?> json) => TuiToastShow(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: TuiToastShowData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final TuiToastShowData data;

  /// Always `tui.toast.show`.
  String get type => 'tui.toast.show';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'tui.toast.show',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `vcs.branch.updated`
final class VcsBranchUpdated {
  const VcsBranchUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory VcsBranchUpdated.fromJson(Map<String, Object?> json) =>
      VcsBranchUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: VcsBranchUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final VcsBranchUpdatedData data;

  /// Always `vcs.branch.updated`.
  String get type => 'vcs.branch.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'vcs.branch.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `websearch.updated`
final class WebsearchUpdated {
  const WebsearchUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory WebsearchUpdated.fromJson(Map<String, Object?> json) =>
      WebsearchUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: json['data'],
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final Object? data;

  /// Always `websearch.updated`.
  String get type => 'websearch.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'websearch.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data,
      };
}

/// `worktree.resolved`
final class WorktreeResolved {
  const WorktreeResolved({
    required this.id,
    required this.created,
    this.metadata,
    required this.durable,
    this.location,
    required this.data,
  });

  factory WorktreeResolved.fromJson(Map<String, Object?> json) =>
      WorktreeResolved(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        durable: WorktreeResolvedDurable.fromJson(asJsonMap(json['durable'])),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: WorktreeResolvedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final WorktreeResolvedDurable durable;
  final LocationRef? location;
  final WorktreeResolvedData data;

  /// Always `worktree.resolved`.
  String get type => 'worktree.resolved';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'worktree.resolved',
        'durable': durable.toJson(),
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}

/// `worktree.updated`
final class WorktreeUpdated {
  const WorktreeUpdated({
    required this.id,
    required this.created,
    this.metadata,
    this.location,
    required this.data,
  });

  factory WorktreeUpdated.fromJson(Map<String, Object?> json) =>
      WorktreeUpdated(
        id: EventID.fromJson(asJsonString(json['id'])),
        created: decodeNumber(json, 'created'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        location: json['location'] == null
            ? null
            : LocationRef.fromJson(json['location']),
        data: WorktreeUpdatedData.fromJson(asJsonMap(json['data'])),
      );

  final EventID id;
  final double created;
  final Map<String, Object?>? metadata;
  final LocationRef? location;
  final WorktreeUpdatedData data;

  /// Always `worktree.updated`.
  String get type => 'worktree.updated';

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'created': created,
        if (metadata != null) 'metadata': metadata!,
        'type': 'worktree.updated',
        if (location != null) 'location': location!.toJson(),
        'data': data.toJson(),
      };
}
