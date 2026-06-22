enum SurveyStatus { draft, active, closed, unknown }

enum QuestionType { yesNo, rating, mcq, text, unknown }

SurveyStatus parseSurveyStatus(dynamic v) {
  if (v is Map) {
    v = v['name'] ?? v['value'] ?? v['code'] ?? v['status'];
  }
  switch (v?.toString().toLowerCase()) {
    case 'draft':
      return SurveyStatus.draft;
    case 'active':
    case 'live':
    case 'published':
      return SurveyStatus.active;
    case 'closed':
    case 'completed':
    case 'ended':
    case 'archived':
      return SurveyStatus.closed;
    default:
      return SurveyStatus.unknown;
  }
}

/// Resolves list/detail status including [closed_at] from the API.
SurveyStatus resolveSurveyStatus(Map<String, dynamic> json) {
  final closedAt = json['closed_at'];
  final isClosed = json['is_closed'] == true || closedAt != null;
  var status = parseSurveyStatus(
    json['status'] ?? json['survey_status'] ?? json['state'],
  );
  if (isClosed && status != SurveyStatus.draft) {
    return SurveyStatus.closed;
  }
  return status;
}

extension SurveyDeletePolicy on SurveySummary {
  /// Draft and closed surveys may be deleted; active surveys cannot.
  bool get canDelete {
    if (status == SurveyStatus.active) return false;
    if (status == SurveyStatus.draft || status == SurveyStatus.closed) {
      return true;
    }
    // Surveys in the closed tab may still carry a legacy/unknown status label.
    return closedAt != null;
  }
}

QuestionType parseQuestionType(dynamic v) {
  switch (v?.toString().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
    case 'yes_no':
    case 'yesno':
    case 'boolean':
      return QuestionType.yesNo;
    case 'rating':
    case 'star':
    case 'stars':
      return QuestionType.rating;
    case 'mcq':
    case 'multiple_choice':
    case 'single_choice':
    case 'choice':
      return QuestionType.mcq;
    case 'text':
    case 'descriptive':
    case 'descriptive_text':
    case 'paragraph':
      return QuestionType.text;
    default:
      return QuestionType.unknown;
  }
}

String questionTypeToApi(QuestionType t) {
  switch (t) {
    case QuestionType.yesNo:
      return 'yes_no';
    case QuestionType.rating:
      return 'rating';
    case QuestionType.mcq:
      return 'mcq';
    case QuestionType.text:
      return 'text';
    case QuestionType.unknown:
      return 'yes_no';
  }
}

String questionTypeLabel(QuestionType t, {bool allowMultiple = false}) {
  switch (t) {
    case QuestionType.yesNo:
      return 'Yes / No';
    case QuestionType.rating:
      return 'Rating';
    case QuestionType.mcq:
      return allowMultiple ? 'Multiple choice' : 'Single choice';
    case QuestionType.text:
      return 'Descriptive text';
    case QuestionType.unknown:
      return 'Question';
  }
}

bool parseAlreadySubmittedFlag(Map<String, dynamic> json) {
  return json['already_submitted'] == true ||
      json['has_submitted'] == true ||
      json['is_submitted'] == true;
}

class SurveyOption {
  final int id;
  final String text;

  const SurveyOption({required this.id, required this.text});

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return SurveyOption(
      id: parseId(json['id'] ?? json['option_id'] ?? json['pk']),
      text: json['text']?.toString() ?? json['label']?.toString() ?? '',
    );
  }
}

class SurveyQuestion {
  final int id;
  final String text;
  final QuestionType questionType;
  final bool isRequired;
  final int order;
  final bool allowMultiple;
  final int maxWords;
  final List<SurveyOption> options;

  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.questionType,
    this.isRequired = true,
    this.order = 0,
    this.allowMultiple = false,
    this.maxWords = 250,
    this.options = const [],
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final opts = <SurveyOption>[];
    if (rawOptions is List) {
      for (final o in rawOptions) {
        if (o is Map) {
          opts.add(SurveyOption.fromJson(Map<String, dynamic>.from(o)));
        } else if (o is String) {
          opts.add(SurveyOption(id: opts.length, text: o));
        }
      }
    }
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return SurveyQuestion(
      id: parseId(json['id'] ?? json['question_id'] ?? json['pk']),
      text: json['text']?.toString() ?? json['question_text']?.toString() ?? '',
      questionType: parseQuestionType(json['question_type'] ?? json['type']),
      isRequired: json['is_required'] == true || json['required'] == true,
      order: json['order'] is int ? json['order'] as int : int.tryParse('${json['order']}') ?? 0,
      allowMultiple: json['allow_multiple'] == true,
      maxWords: json['max_words'] is int
          ? json['max_words'] as int
          : int.tryParse('${json['max_words']}') ?? 250,
      options: opts,
    );
  }
}

class SurveySummary {
  final int id;
  final String title;
  final String description;
  final SurveyStatus status;
  final bool isAnonymous;
  final int responseCount;
  final DateTime? launchedAt;
  final DateTime? closedAt;
  final double? participationRate;
  final bool alreadySubmitted;

  const SurveySummary({
    required this.id,
    required this.title,
    this.description = '',
    this.status = SurveyStatus.unknown,
    this.isAnonymous = false,
    this.responseCount = 0,
    this.launchedAt,
    this.closedAt,
    this.participationRate,
    this.alreadySubmitted = false,
  });

  SurveySummary copyWith({
    int? id,
    String? title,
    String? description,
    SurveyStatus? status,
    bool? isAnonymous,
    int? responseCount,
    DateTime? launchedAt,
    DateTime? closedAt,
    double? participationRate,
    bool? alreadySubmitted,
  }) {
    return SurveySummary(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      responseCount: responseCount ?? this.responseCount,
      launchedAt: launchedAt ?? this.launchedAt,
      closedAt: closedAt ?? this.closedAt,
      participationRate: participationRate ?? this.participationRate,
      alreadySubmitted: alreadySubmitted ?? this.alreadySubmitted,
    );
  }

  factory SurveySummary.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    final id = parseId(
      json['id'] ?? json['survey_id'] ?? json['pk'] ?? json['surveyId'],
    );

    return SurveySummary(
      id: id,
      title: json['title']?.toString() ?? json['survey_title']?.toString() ?? '',
      description:
          json['description']?.toString() ?? json['survey_description']?.toString() ?? '',
      status: resolveSurveyStatus(json),
      isAnonymous: json['is_anonymous'] == true,
      responseCount: json['response_count'] is int
          ? json['response_count'] as int
          : int.tryParse('${json['response_count']}') ?? 0,
      launchedAt: dt(json['launched_at']),
      closedAt: dt(json['closed_at']),
      participationRate: json['participation_rate'] is num
          ? (json['participation_rate'] as num).toDouble()
          : double.tryParse('${json['participation_rate']}'),
      alreadySubmitted: parseAlreadySubmittedFlag(json),
    );
  }

  /// Parses items from `GET /api/surveys/active/` (flat or nested shapes).
  factory SurveySummary.fromActiveFeedJson(Map<String, dynamic> json) {
    bool taken(dynamic v) {
      if (v == true) return true;
      return false;
    }

    final nested = json['survey'];
    if (nested is Map) {
      final merged = Map<String, dynamic>.from(nested);
      if (json['survey_title'] != null) merged['title'] ??= json['survey_title'];
      if (json['survey_id'] != null) merged['id'] ??= json['survey_id'];
      if (taken(json['already_submitted']) ||
          taken(json['has_submitted']) ||
          taken(json['is_submitted'])) {
        merged['already_submitted'] = true;
      }
      return SurveySummary.fromJson(merged);
    }
    if (nested != null && nested is! Map) {
      final merged = Map<String, dynamic>.from(json);
      merged['id'] ??= nested;
      return SurveySummary.fromJson(merged);
    }
    return SurveySummary.fromJson(json);
  }
}

class SurveyDetail extends SurveySummary {
  final bool isAllUsers;
  final List<int> targetDepartmentIds;
  final List<int> targetDesignationIds;
  final List<int> targetUserIds;
  final List<SurveyQuestion> questions;

  const SurveyDetail({
    required super.id,
    required super.title,
    super.description,
    super.status,
    super.isAnonymous,
    super.responseCount,
    super.launchedAt,
    super.closedAt,
    super.participationRate,
    super.alreadySubmitted,
    this.isAllUsers = true,
    this.targetDepartmentIds = const [],
    this.targetDesignationIds = const [],
    this.targetUserIds = const [],
    this.questions = const [],
  });

  factory SurveyDetail.fromJson(Map<String, dynamic> json) {
    List<int> ids(dynamic v) {
      if (v is! List) return const [];
      return v.map((e) => int.tryParse('$e') ?? 0).where((e) => e > 0).toList();
    }

    final root = json['survey'] is Map
        ? {...Map<String, dynamic>.from(json['survey'] as Map), ...json}
        : json;

    final qs = (root['questions'] as List? ?? json['questions'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SurveyQuestion.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final base = SurveySummary.fromJson(Map<String, dynamic>.from(root));
    return SurveyDetail(
      id: base.id,
      title: base.title,
      description: base.description,
      status: base.status,
      isAnonymous: base.isAnonymous,
      responseCount: base.responseCount,
      launchedAt: base.launchedAt,
      closedAt: base.closedAt,
      participationRate: base.participationRate,
      alreadySubmitted: base.alreadySubmitted ||
          parseAlreadySubmittedFlag(Map<String, dynamic>.from(root)) ||
          parseAlreadySubmittedFlag(json),
      isAllUsers: root['is_all_users'] != false,
      targetDepartmentIds: ids(root['target_department_ids'] ?? root['target_departments']),
      targetDesignationIds: ids(root['target_designation_ids'] ?? root['target_designations']),
      targetUserIds: ids(root['target_user_ids'] ?? root['target_users']),
      questions: qs,
    );
  }

  Map<String, dynamic> toCreateOrUpdateJson({
    required String title,
    required String description,
    required bool isAnonymous,
    required bool isAllUsers,
    required List<int> targetDepartmentIds,
    required List<int> targetDesignationIds,
    required List<int> targetUserIds,
  }) {
    return {
      'title': title,
      'description': description,
      'is_anonymous': isAnonymous,
      'is_all_users': isAllUsers,
      'target_department_ids': targetDepartmentIds,
      'target_designation_ids': targetDesignationIds,
      'target_user_ids': targetUserIds,
    };
  }
}

class SurveyAnswerPayload {
  final int questionId;
  final bool? yesNoValue;
  final int? ratingValue;
  final String? textValue;
  final List<int> selectedOptionIds;

  const SurveyAnswerPayload({
    required this.questionId,
    this.yesNoValue,
    this.ratingValue,
    this.textValue,
    this.selectedOptionIds = const [],
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'question_id': questionId};
    if (yesNoValue != null) m['yes_no_value'] = yesNoValue;
    if (ratingValue != null) m['rating_value'] = ratingValue;
    if (textValue != null) m['text_value'] = textValue;
    if (selectedOptionIds.isNotEmpty) {
      m['selected_option_ids'] = selectedOptionIds;
    }
    return m;
  }
}

class YesNoResult {
  final int yes;
  final int no;
  final int total;
  final double yesPct;
  final double noPct;

  const YesNoResult({
    required this.yes,
    required this.no,
    required this.total,
    required this.yesPct,
    required this.noPct,
  });

  factory YesNoResult.fromJson(Map<String, dynamic> json) {
    return YesNoResult(
      yes: json['yes'] is int ? json['yes'] as int : int.tryParse('${json['yes']}') ?? 0,
      no: json['no'] is int ? json['no'] as int : int.tryParse('${json['no']}') ?? 0,
      total: json['total'] is int ? json['total'] as int : int.tryParse('${json['total']}') ?? 0,
      yesPct: (json['yes_pct'] as num?)?.toDouble() ?? 0,
      noPct: (json['no_pct'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RatingResult {
  final double average;
  final Map<String, int> distribution;

  const RatingResult({required this.average, required this.distribution});

  factory RatingResult.fromJson(Map<String, dynamic> json) {
    final dist = <String, int>{};
    final raw = json['distribution'];
    if (raw is Map) {
      raw.forEach((k, v) {
        dist[k.toString()] = v is int ? v : int.tryParse('$v') ?? 0;
      });
    }
    return RatingResult(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      distribution: dist,
    );
  }
}

class McqOptionResult {
  final int id;
  final String text;
  final int count;
  final double pct;

  const McqOptionResult({
    required this.id,
    required this.text,
    required this.count,
    required this.pct,
  });

  factory McqOptionResult.fromJson(Map<String, dynamic> json) {
    return McqOptionResult(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      text: json['text']?.toString() ?? '',
      count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}') ?? 0,
      pct: (json['pct'] as num?)?.toDouble() ?? 0,
    );
  }
}

class McqResult {
  final List<McqOptionResult> options;

  const McqResult({required this.options});

  factory McqResult.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List? ?? [])
        .whereType<Map>()
        .map((e) => McqOptionResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return McqResult(options: opts);
  }
}

class TextAnswerResult {
  final String text;
  final int wordCount;
  final String? employeeName;

  const TextAnswerResult({
    required this.text,
    this.wordCount = 0,
    this.employeeName,
  });

  factory TextAnswerResult.fromJson(Map<String, dynamic> json) {
    return TextAnswerResult(
      text: json['text']?.toString() ?? json['text_value']?.toString() ?? '',
      wordCount: json['word_count'] is int
          ? json['word_count'] as int
          : int.tryParse('${json['word_count']}') ?? 0,
      employeeName: json['employee_name']?.toString(),
    );
  }
}

class TextResult {
  final int maxWords;
  final int total;
  final List<TextAnswerResult> answers;

  const TextResult({
    this.maxWords = 250,
    this.total = 0,
    this.answers = const [],
  });

  factory TextResult.fromJson(Map<String, dynamic> json) {
    final answers = (json['answers'] as List? ?? [])
        .whereType<Map>()
        .map((e) => TextAnswerResult.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return TextResult(
      maxWords: json['max_words'] is int
          ? json['max_words'] as int
          : int.tryParse('${json['max_words']}') ?? 250,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total']}') ?? answers.length,
      answers: answers,
    );
  }
}

class QuestionResult {
  final int questionId;
  final String text;
  final QuestionType questionType;
  final YesNoResult? yesNo;
  final RatingResult? rating;
  final McqResult? mcq;
  final TextResult? textResult;

  const QuestionResult({
    required this.questionId,
    required this.text,
    required this.questionType,
    this.yesNo,
    this.rating,
    this.mcq,
    this.textResult,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    var type = parseQuestionType(json['question_type'] ?? json['type']);
    if (type == QuestionType.unknown) {
      if (json['yes_no'] is Map || json.containsKey('yes') || json.containsKey('no')) {
        type = QuestionType.yesNo;
      } else if (json['rating'] is Map || json.containsKey('average')) {
        type = QuestionType.rating;
      } else if (json['mcq'] is Map ||
          (json['options'] is List && json['answers'] is! List)) {
        type = QuestionType.mcq;
      } else if (json['answers'] is List &&
          (json['type']?.toString() == 'text' ||
              json['question_type']?.toString() == 'text')) {
        type = QuestionType.text;
      }
    }

    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    YesNoResult? parseYesNo() {
      if (json['yes_no'] is Map) {
        return YesNoResult.fromJson(Map<String, dynamic>.from(json['yes_no']));
      }
      if (json.containsKey('yes') || json.containsKey('no')) {
        return YesNoResult.fromJson(json);
      }
      return null;
    }

    RatingResult? parseRating() {
      if (json['rating'] is Map) {
        return RatingResult.fromJson(Map<String, dynamic>.from(json['rating']));
      }
      if (json.containsKey('average') || json['distribution'] is Map) {
        return RatingResult.fromJson(json);
      }
      return null;
    }

    McqResult? parseMcq() {
      if (json['mcq'] is Map) {
        return McqResult.fromJson(Map<String, dynamic>.from(json['mcq']));
      }
      if (json['options'] is List && json['answers'] is! List) {
        return McqResult.fromJson({'options': json['options']});
      }
      return null;
    }

    TextResult? parseText() {
      if (json['text'] is Map) {
        return TextResult.fromJson(Map<String, dynamic>.from(json['text']));
      }
      if (json['answers'] is List &&
          (type == QuestionType.text ||
              json['type']?.toString() == 'text' ||
              json['question_type']?.toString() == 'text')) {
        return TextResult.fromJson(json);
      }
      return null;
    }

    return QuestionResult(
      questionId: parseId(json['question_id'] ?? json['id'] ?? json['pk']),
      text: json['text']?.toString() ?? json['question_text']?.toString() ?? '',
      questionType: type,
      yesNo: parseYesNo(),
      rating: parseRating(),
      mcq: parseMcq(),
      textResult: parseText(),
    );
  }
}

class SurveyResults {
  final int surveyId;
  final String title;
  final int responseCount;
  final double? participationRate;
  final bool isAnonymous;
  final List<QuestionResult> questions;
  final List<SurveyIndividualResponse> userResponses;

  const SurveyResults({
    required this.surveyId,
    required this.title,
    this.responseCount = 0,
    this.participationRate,
    this.isAnonymous = false,
    this.questions = const [],
    this.userResponses = const [],
  });

  SurveyResults copyWith({
    int? surveyId,
    String? title,
    int? responseCount,
    double? participationRate,
    bool? isAnonymous,
    List<QuestionResult>? questions,
    List<SurveyIndividualResponse>? userResponses,
  }) {
    return SurveyResults(
      surveyId: surveyId ?? this.surveyId,
      title: title ?? this.title,
      responseCount: responseCount ?? this.responseCount,
      participationRate: participationRate ?? this.participationRate,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      questions: questions ?? this.questions,
      userResponses: userResponses ?? this.userResponses,
    );
  }

  /// Fills missing question rows/text from survey detail when results payload is sparse.
  SurveyResults enrichWithDetail(SurveyDetail? detail) {
    if (detail == null) return this;

    var title = this.title;
    if (title.isEmpty) title = detail.title;

    if (questions.isNotEmpty) {
      final byId = {for (final q in detail.questions) q.id: q};
      final enriched = questions.map((r) {
        final q = byId[r.questionId];
        if (q == null) return r;
        return QuestionResult(
          questionId: r.questionId,
          text: r.text.isNotEmpty ? r.text : q.text,
          questionType: r.questionType != QuestionType.unknown
              ? r.questionType
              : q.questionType,
          yesNo: r.yesNo,
          rating: r.rating,
          mcq: r.mcq,
          textResult: r.textResult,
        );
      }).toList();
      return copyWith(title: title, questions: enriched);
    }

    if (detail.questions.isEmpty) return copyWith(title: title);

    final placeholders = detail.questions.map((q) {
      switch (q.questionType) {
        case QuestionType.yesNo:
          return QuestionResult(
            questionId: q.id,
            text: q.text,
            questionType: q.questionType,
            yesNo: const YesNoResult(yes: 0, no: 0, total: 0, yesPct: 0, noPct: 0),
          );
        case QuestionType.rating:
          return QuestionResult(
            questionId: q.id,
            text: q.text,
            questionType: q.questionType,
            rating: const RatingResult(average: 0, distribution: {}),
          );
        case QuestionType.mcq:
          return QuestionResult(
            questionId: q.id,
            text: q.text,
            questionType: q.questionType,
            mcq: McqResult(
              options: q.options
                  .map((o) => McqOptionResult(id: o.id, text: o.text, count: 0, pct: 0))
                  .toList(),
            ),
          );
        case QuestionType.text:
          return QuestionResult(
            questionId: q.id,
            text: q.text,
            questionType: q.questionType,
            textResult: TextResult(maxWords: q.maxWords, total: 0, answers: const []),
          );
        case QuestionType.unknown:
          return QuestionResult(
            questionId: q.id,
            text: q.text,
            questionType: q.questionType,
          );
      }
    }).toList();

    return copyWith(title: title, questions: placeholders);
  }

  factory SurveyResults.fromJson(Map<String, dynamic> json, {int? fallbackSurveyId}) {
    final root = json['survey'] is Map
        ? {...Map<String, dynamic>.from(json['survey'] as Map), ...json}
        : json;

    List<Map<String, dynamic>> questionRows = [];
    for (final key in const [
      'questions',
      'question_results',
      'results',
    ]) {
      final v = root[key];
      if (v is List) {
        questionRows = v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        if (questionRows.isNotEmpty) break;
      }
    }

    final qs = questionRows.map(QuestionResult.fromJson).toList();

    final userResponses = (root['user_responses'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SurveyIndividualResponse.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return SurveyResults(
      surveyId: parseId(root['survey_id'] ?? root['id'] ?? fallbackSurveyId),
      title: root['title']?.toString() ?? root['survey_title']?.toString() ?? '',
      responseCount: root['response_count'] is int
          ? root['response_count'] as int
          : int.tryParse('${root['response_count']}') ?? 0,
      participationRate: (root['participation_rate'] as num?)?.toDouble(),
      isAnonymous: root['is_anonymous'] == true,
      questions: qs,
      userResponses: userResponses,
    );
  }
}

class SurveyUserAnswer {
  final int questionId;
  final String questionText;
  final QuestionType questionType;
  final String displayValue;

  const SurveyUserAnswer({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.displayValue,
  });

  factory SurveyUserAnswer.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    final display = json['display_value']?.toString().trim();
    return SurveyUserAnswer(
      questionId: parseId(json['question_id'] ?? json['id']),
      questionText: json['question_text']?.toString() ?? '',
      questionType: parseQuestionType(json['type'] ?? json['question_type']),
      displayValue: display != null && display.isNotEmpty
          ? display
          : _fallbackDisplayValue(json),
    );
  }

  static String _fallbackDisplayValue(Map<String, dynamic> json) {
    if (json['text_value'] != null) return json['text_value'].toString();
    if (json['yes_no_value'] == true) return 'Yes';
    if (json['yes_no_value'] == false) return 'No';
    if (json['rating_value'] != null) return json['rating_value'].toString();
    final opts = json['selected_option_texts'];
    if (opts is List && opts.isNotEmpty) {
      return opts.map((e) => e.toString()).join(', ');
    }
    return '—';
  }
}

class SurveyIndividualResponse {
  final int? responseId;
  final int? userId;
  final String? employeeCode;
  final String employeeName;
  final String? email;
  final String? department;
  final String? designation;
  final DateTime? submittedAt;
  final List<SurveyUserAnswer> answers;

  const SurveyIndividualResponse({
    this.responseId,
    this.userId,
    this.employeeCode,
    required this.employeeName,
    this.email,
    this.department,
    this.designation,
    this.submittedAt,
    this.answers = const [],
  });

  String get subtitle {
    final parts = <String>[];
    if (department != null && department!.isNotEmpty) parts.add(department!);
    if (designation != null && designation!.isNotEmpty) parts.add(designation!);
    if (employeeCode != null && employeeCode!.isNotEmpty) parts.add(employeeCode!);
    return parts.join(' · ');
  }

  factory SurveyIndividualResponse.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse('$v');
    }

    final answersRaw = (json['answers'] as List? ?? [])
        .whereType<Map>()
        .map((e) => SurveyUserAnswer.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return SurveyIndividualResponse(
      responseId: parseInt(json['response_id']),
      userId: parseInt(json['user_id']),
      employeeCode: json['employee_id']?.toString(),
      employeeName: json['full_name']?.toString() ??
          json['employee_name']?.toString() ??
          json['user_name']?.toString() ??
          json['username']?.toString() ??
          'Employee',
      email: json['email']?.toString(),
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      submittedAt: dt(json['submitted_at']),
      answers: answersRaw,
    );
  }
}

class SurveyMyResponse {
  final int surveyId;
  final DateTime? submittedAt;
  final List<Map<String, dynamic>> answers;

  const SurveyMyResponse({
    required this.surveyId,
    this.submittedAt,
    this.answers = const [],
  });

  factory SurveyMyResponse.fromJson(Map<String, dynamic> json) {
    DateTime? dt(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return SurveyMyResponse(
      surveyId: json['survey_id'] is int
          ? json['survey_id'] as int
          : int.tryParse('${json['survey_id']}') ?? 0,
      submittedAt: dt(json['submitted_at']),
      answers: (json['answers'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}
