import 'dart:convert';

class UserRef {
  final String? id;
  final String? email;
  final String? username;

  const UserRef({this.id, this.email, this.username});

  factory UserRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserRef();
    return UserRef(
      id: map['_id']?.toString(),
      email: map['email']?.toString(),
      username: map['username']?.toString(),
    );
  }
}

class ClassRef {
  final String? id;
  final String? nameClass;
  final String? subject;
  final String? gradeLevel;

  const ClassRef({this.id, this.nameClass, this.subject, this.gradeLevel});

  factory ClassRef.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ClassRef();
    return ClassRef(
      id: map['_id']?.toString(),
      nameClass: map['nameClass']?.toString(),
      subject: map['subject']?.toString(),
      gradeLevel: map['gradeLevel']?.toString(),
    );
  }
}

class Attachment {
  final String? id;
  final String fileName;
  final String fileUrl;
  final int? fileSize;
  final String? mimeType;
  final DateTime? uploadedAt;

  const Attachment({
    this.id,
    required this.fileName,
    required this.fileUrl,
    this.fileSize,
    this.mimeType,
    this.uploadedAt,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) => Attachment(
    id: map['_id']?.toString(),
    fileName: (map['fileName'] ?? '').toString(),
    fileUrl: (map['fileUrl'] ?? '').toString(),
    fileSize: map['fileSize'] is num ? (map['fileSize'] as num).toInt() : null,
    mimeType: map['mimeType']?.toString(),
    uploadedAt:
        map['uploadedAt'] != null
            ? DateTime.tryParse(map['uploadedAt'].toString())
            : null,
  );

  Map<String, dynamic> toMap() => {
    'fileName': fileName,
    'fileUrl': fileUrl,
    if (fileSize != null) 'fileSize': fileSize,
    if (mimeType != null) 'mimeType': mimeType,
  };
}

class Question {
  final String question;
  final List<String> options;
  final List<int> correctAnswers;
  final int points;
  final String? explanation;

  const Question({
    required this.question,
    required this.options,
    required this.correctAnswers,
    this.points = 1,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> map) => Question(
    question: (map['question'] ?? '').toString(),
    options:
        (map['options'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
    correctAnswers:
        (map['correctAnswers'] as List<dynamic>? ?? [])
            .map((e) => e is num ? e.toInt() : int.tryParse(e.toString()) ?? 0)
            .toList(),
    points: map['points'] is num ? (map['points'] as num).toInt() : 1,
    explanation: map['explanation']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    'correctAnswers': correctAnswers,
    'points': points,
    if (explanation != null) 'explanation': explanation,
  };
}

class Submission {
  final String? id;
  final String? studentId; // id tham chiếu (simple)
  final UserRef? student; // thông tin học sinh (khi gọi list submissions)
  final DateTime? submittedAt;
  final String? content;
  final String? fileUrl;
  final List<int>? answers;
  final double? grade;
  final String? feedback;
  final bool isLate;
  final bool hasGrade;

  const Submission({
    this.id,
    this.studentId,
    this.student,
    this.submittedAt,
    this.content,
    this.fileUrl,
    this.answers,
    this.grade,
    this.feedback,
    this.isLate = false,
    this.hasGrade = false,
  });

  factory Submission.fromMap(Map<String, dynamic> map) => Submission(
    id: map['_id']?.toString(),
    studentId: _extractStudentId(map),
    student:
        map['student'] is Map<String, dynamic>
            ? UserRef.fromMap(map['student'] as Map<String, dynamic>)
            : null,
    submittedAt:
        map['submittedAt'] != null
            ? DateTime.tryParse(map['submittedAt'].toString())
            : null,
    content: map['content']?.toString(),
    fileUrl: map['fileUrl']?.toString(),
    answers:
        (map['answers'] as List<dynamic>?)
            ?.map((e) => e is num ? e.toInt() : int.tryParse(e.toString()) ?? 0)
            .toList(),
    grade:
        map['grade'] != null
            ? (map['grade'] is num
                ? (map['grade'] as num).toDouble()
                : double.tryParse(map['grade'].toString()))
            : null,
    feedback: map['feedback']?.toString(),
    isLate: map['isLate'] == true,
    hasGrade: map['hasGrade'] == true,
  );

  static String? _extractStudentId(Map<String, dynamic> map) {
    // Trường hợp 1: studentId là string trực tiếp
    if (map['studentId'] is String) {
      return map['studentId'];
    }

    // Trường hợp 2: student là object có _id
    if (map['student'] is Map<String, dynamic>) {
      final student = map['student'] as Map<String, dynamic>;
      return student['_id']?.toString();
    }

    return null;
  }
}

class Exercise {
  final String? id;
  final String title;
  final String? description;
  final String type; // essay | multiple_choice | file_upload
  final List<Question> questions;
  final List<Attachment> attachments;
  final int? maxScore;
  final String? subject;
  final ClassRef classId;
  final UserRef createdBy;
  final DateTime? startDate;
  final DateTime dueDate;
  final List<Submission> submissions;
  final String status; // open | closed | graded
  final bool deleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Teacher-specific fields for overview
  final int? submissionCount;
  final int? gradedCount;
  final int? ungradedCount;
  final double? gradingProgress;
  final String? gradingStatus; // ungraded | partially_graded | fully_graded
  final double? averageGrade;
  final bool? hasAttachments;
  final int? questionCount;
  final bool? isOverdue;
  final int? daysSinceCreation;

  const Exercise({
    this.id,
    required this.title,
    this.description,
    required this.type,
    this.questions = const [],
    this.attachments = const [],
    this.maxScore,
    this.subject,
    this.classId = const ClassRef(),
    this.createdBy = const UserRef(),
    this.startDate,
    required this.dueDate,
    this.submissions = const [],
    this.status = 'open',
    this.deleted = false,
    this.createdAt,
    this.updatedAt,
    this.submissionCount,
    this.gradedCount,
    this.ungradedCount,
    this.gradingProgress,
    this.gradingStatus,
    this.averageGrade,
    this.hasAttachments,
    this.questionCount,
    this.isOverdue,
    this.daysSinceCreation,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) => Exercise(
    id: map['_id']?.toString(),
    title: (map['title'] ?? '').toString(),
    description: map['description']?.toString(),
    type: (map['type'] ?? 'essay').toString(),
    questions:
        (map['questions'] as List<dynamic>? ?? [])
            .map((e) => Question.fromMap(e as Map<String, dynamic>))
            .toList(),
    attachments:
        (map['attachments'] as List<dynamic>? ?? [])
            .map((e) => Attachment.fromMap(e as Map<String, dynamic>))
            .toList(),
    maxScore: map['maxScore'] is num ? (map['maxScore'] as num).toInt() : null,
    subject: map['subject']?.toString(),
    classId: ClassRef.fromMap(
      map['classId'] as Map<String, dynamic>? ??
          map['class'] as Map<String, dynamic>?,
    ),
    createdBy: UserRef.fromMap(map['createdBy'] as Map<String, dynamic>?),
    startDate:
        map['startDate'] != null
            ? DateTime.tryParse(map['startDate'].toString())
            : null,
    dueDate: DateTime.tryParse(map['dueDate'].toString()) ?? DateTime.now(),
    submissions:
        (map['submissions'] as List<dynamic>? ?? [])
            .map((e) => Submission.fromMap(e as Map<String, dynamic>))
            .toList(),
    status: (map['status'] ?? 'open').toString(),
    deleted: map['deleted'] == true,
    createdAt:
        map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString())
            : null,
    updatedAt:
        map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'].toString())
            : null,
    submissionCount:
        map['submissionCount'] is num
            ? (map['submissionCount'] as num).toInt()
            : null,
    gradedCount:
        map['gradedCount'] is num ? (map['gradedCount'] as num).toInt() : null,
    ungradedCount:
        map['ungradedCount'] is num
            ? (map['ungradedCount'] as num).toInt()
            : null,
    gradingProgress:
        map['gradingProgress'] is num
            ? (map['gradingProgress'] as num).toDouble()
            : null,
    gradingStatus: map['gradingStatus']?.toString(),
    averageGrade:
        map['averageGrade'] is num
            ? (map['averageGrade'] as num).toDouble()
            : null,
    hasAttachments:
        map['hasAttachments'] is bool ? map['hasAttachments'] : null,
    questionCount:
        map['questionCount'] is num
            ? (map['questionCount'] as num).toInt()
            : null,
    isOverdue: map['isOverdue'] is bool ? map['isOverdue'] : null,
    daysSinceCreation:
        map['daysSinceCreation'] is num
            ? (map['daysSinceCreation'] as num).toInt()
            : null,
  );
}

class ExerciseResponse {
  final String message;
  final Exercise data;

  const ExerciseResponse({required this.message, required this.data});

  factory ExerciseResponse.fromMap(Map<String, dynamic> map) =>
      ExerciseResponse(
        message: (map['message'] ?? '').toString(),
        data: Exercise.fromMap(map['data'] as Map<String, dynamic>),
      );

  static ExerciseResponse fromJson(String source) =>
      ExerciseResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// Phản hồi khi học sinh nộp bài
class SubmitExerciseResponse {
  final String message;
  final SubmitResult data;

  const SubmitExerciseResponse({required this.message, required this.data});

  factory SubmitExerciseResponse.fromMap(Map<String, dynamic> map) =>
      SubmitExerciseResponse(
        message: (map['message'] ?? '').toString(),
        data: SubmitResult.fromMap(map['data'] as Map<String, dynamic>),
      );
}

class SubmitResult {
  final String id; // _id
  final String submissionId;
  final UserRef student; // {_id, username, email}
  final ExerciseLite exercise; // {_id, title, type, maxScore}
  final DateTime? submittedAt;
  final String? content;
  final String? fileUrl;

  const SubmitResult({
    required this.id,
    required this.submissionId,
    required this.student,
    required this.exercise,
    this.submittedAt,
    this.content,
    this.fileUrl,
  });

  factory SubmitResult.fromMap(Map<String, dynamic> map) => SubmitResult(
    id: (map['_id'] ?? '').toString(),
    submissionId: (map['submissionId'] ?? '').toString(),
    student: UserRef.fromMap(map['student'] as Map<String, dynamic>?),
    exercise: ExerciseLite.fromMap(map['exercise'] as Map<String, dynamic>?),
    submittedAt:
        map['submittedAt'] != null
            ? DateTime.tryParse(map['submittedAt'].toString())
            : null,
    content: map['content']?.toString(),
    fileUrl: map['fileUrl']?.toString(),
  );
}

class ExerciseLite {
  final String id;
  final String title;
  final String type;
  final int? maxScore;

  const ExerciseLite({
    required this.id,
    required this.title,
    required this.type,
    this.maxScore,
  });

  factory ExerciseLite.fromMap(Map<String, dynamic>? map) {
    final m = map ?? const {};
    return ExerciseLite(
      id: (m['_id'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      type: (m['type'] ?? '').toString(),
      maxScore: m['maxScore'] is num ? (m['maxScore'] as num).toInt() : null,
    );
  }
}

class CreateExerciseRequest {
  final String title;
  final String? description;
  final String type; // essay | multiple_choice | file_upload
  final List<Question> questions;
  final List<Attachment> attachments;
  final int? maxScore;
  final String? subject;
  final DateTime dueDate;

  const CreateExerciseRequest({
    required this.title,
    this.description,
    this.type = 'essay',
    this.questions = const [],
    this.attachments = const [],
    this.maxScore,
    this.subject,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'type': type,
    if (questions.isNotEmpty)
      'questions': questions.map((e) => e.toMap()).toList(),
    if (attachments.isNotEmpty)
      'attachments': attachments.map((e) => e.toMap()).toList(),
    if (maxScore != null) 'maxScore': maxScore,
    if (subject != null && subject!.isNotEmpty) 'subject': subject,
    // Gửi ISO string, backend nhận Date
    'dueDate': dueDate.toUtc().toIso8601String(),
  };
}
