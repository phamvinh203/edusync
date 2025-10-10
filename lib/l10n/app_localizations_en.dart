// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EduSync';

  @override
  String get home => 'Home';

  @override
  String get classes => 'Classes';

  @override
  String get exercises => 'Exercises';

  @override
  String get profile => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get academicInfo => 'Academic Information';

  @override
  String get feeManagement => 'Fee Management';

  @override
  String get changePassword => 'Change Password';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get support => 'Support';

  @override
  String get about => 'About';

  @override
  String get feedback => 'Feedback';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get student => 'Student';

  @override
  String get teacher => 'Teacher';

  @override
  String get admin => 'Administrator';

  @override
  String get user => 'User';

  @override
  String get classLabel => 'Class';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get hello => 'Hello!';

  @override
  String get errorLoadingUserInfo => 'Error loading user info';

  @override
  String get cannotLoadData => 'Cannot load data';

  @override
  String get reload => 'Reload';

  @override
  String get todayAssignments => 'Today\'s Assignments';

  @override
  String get classesJoined => 'Classes Joined';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get noActivities => 'No activities yet';

  @override
  String todayAssignmentsCount(int count) {
    return 'Today\'s Assignments ($count)';
  }

  @override
  String get submitted => 'Submitted';

  @override
  String get overdue => 'Overdue';

  @override
  String get notSubmitted => 'Not Submitted';

  @override
  String get deadline => 'Due';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get managedClasses => 'Managed Classes';

  @override
  String get students => 'Students';

  @override
  String get pendingGrading => 'Pending Grading';

  @override
  String get todayClasses => 'Today\'s Classes';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get createExercise => 'Create Exercise';

  @override
  String get takeAttendance => 'Take Attendance';

  @override
  String todaySchedule(int count) {
    return 'Today\'s Schedule ($count)';
  }

  @override
  String studentCount(int count) {
    return '$count students';
  }

  @override
  String submissionCount(int count) {
    return '$count submissions';
  }

  @override
  String get createExerciseFeatureInDevelopment =>
      'Create exercise feature is under development';

  @override
  String get takeAttendanceFeatureInDevelopment =>
      'Take attendance feature is under development';

  @override
  String get classNotUpdated => 'Class not updated';

  @override
  String get schoolNotUpdated => 'School not updated';

  @override
  String get tutorClasses => 'tutor classes';

  @override
  String get createdClasses => 'created classes';

  @override
  String classCreatedSuccess(String className) {
    return 'Successfully created class \"$className\"!';
  }

  @override
  String get schoolSubjects => 'School Subjects';

  @override
  String get tutorClassesTab => 'Tutor Classes';

  @override
  String get schedule => 'Schedule';

  @override
  String get classInfo => 'Class Information:';

  @override
  String get schoolInfo => 'School';

  @override
  String get subjects => 'subjects';

  @override
  String get createNewClass => 'Create New Class';

  @override
  String get subject => 'Subject';

  @override
  String get gradeLevel => 'Grade';

  @override
  String get teacherName => 'Teacher';

  @override
  String get scheduleLabel => 'Schedule:';

  @override
  String get location => 'Location';

  @override
  String get todayAttendance => 'Today\'s Attendance';

  @override
  String get date => 'Date';

  @override
  String get attendanceHistory => 'Attendance History';

  @override
  String get noHistory => 'No history';

  @override
  String get present => 'Present';

  @override
  String get classAttendance => 'Class Attendance';

  @override
  String get email => 'Email';

  @override
  String get saveAttendance => 'Save Attendance';

  @override
  String get createClass => 'Create New Class';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get className => 'Class Name *';

  @override
  String get enterClassName => 'Enter class name';

  @override
  String get pleaseEnterClassName => 'Please enter class name';

  @override
  String get subjectName => 'Subject *';

  @override
  String get enterSubject => 'Enter subject';

  @override
  String get pleaseEnterSubject => 'Please enter subject';

  @override
  String get extraClass => 'Extra Class';

  @override
  String get extraClassHint => 'E.g: Grade 12, Grade 10, ...';

  @override
  String get pricePerSession => 'Price per Session (VND)';

  @override
  String get priceHint => 'E.g: 20,000';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Enter full description for the exercise...';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationHint => 'Enter study location';

  @override
  String get maxStudents => 'Maximum Students';

  @override
  String get maxStudentsHint => 'Enter maximum number of students';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get addSchedule => 'Add Schedule';

  @override
  String scheduleNumber(int number) {
    return 'Schedule $number';
  }

  @override
  String get enterClassCode => 'Enter Class Code';

  @override
  String get enterClassCodeDescription =>
      'Enter the class code provided by your teacher to join the school class.';

  @override
  String get joinClass => 'Join Class';

  @override
  String get noSubjectsYet => 'No Subjects Yet';

  @override
  String get enterCodeToJoin =>
      'Enter the class code provided by your teacher to start joining school subjects';

  @override
  String get enterClassCodeButton => 'Enter Class Code';

  @override
  String classesCreated(int count) {
    return '$count classes created';
  }

  @override
  String get noClassesYet => 'No Classes Yet';

  @override
  String get createFirstClass =>
      'You haven\'t created any school classes yet. Create a new class to get started.';

  @override
  String get dataLoadError => 'Data Load Error';

  @override
  String get retry => 'Retry';

  @override
  String get noTutorRegistered => 'No Tutor Classes Registered';

  @override
  String get noTutorCreated => 'No Tutor Classes Yet';

  @override
  String get findTutorClasses => 'Find and register for suitable tutor classes';

  @override
  String get createFirstTutorClass => 'Create your first tutor class';

  @override
  String get findTutorButton => 'Find Tutor Classes';

  @override
  String get registrationApplications => 'Registration Applications';

  @override
  String get noTeacherIdError => 'Teacher ID not found. Please log in again.';

  @override
  String get created => 'Created';

  @override
  String get joined => 'Joined Class';

  @override
  String get teacherLabel => 'Teacher';

  @override
  String youSelectedClass(String className) {
    return 'You selected class $className';
  }

  @override
  String get tutor => 'Tutor';

  @override
  String get detail => 'Detail';

  @override
  String get classCodeLabel => 'Class Code';

  @override
  String get classCodeHint => 'Example: 5LG9HA';

  @override
  String get pleaseEnterClassCode => 'Please enter class code';

  @override
  String get joining => 'Joining...';

  @override
  String get joinSuccess => 'Successfully joined the class';

  @override
  String get filterByGrade => 'Filter by grade';

  @override
  String get allGrades => 'All grades';

  @override
  String get errorPrefix => 'Error';

  @override
  String get registerTutorClass => 'Register for Tutor Class';

  @override
  String get addressLabel => 'Address';

  @override
  String get register => 'Register';

  @override
  String get noScheduleYet => 'No schedule yet';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to remove this student from the pending list?';

  @override
  String get delete => 'Delete';

  @override
  String get confirmApprove => 'Confirm Approve';

  @override
  String get confirmApproveMessage =>
      'Are you sure you want to approve this student to join the class?';

  @override
  String get approve => 'Approve';

  @override
  String get loadingPendingStudents => 'Loading pending students list...';

  @override
  String get noPendingStudents => 'No pending students';

  @override
  String get classInfoNotFound => 'Class information not found';

  @override
  String get featureInDevelopment => 'Feature in development';

  @override
  String get confirmDeleteClass =>
      'Are you sure you want to delete this class?';

  @override
  String deleteClassError(String error) {
    return 'Error deleting class: $error';
  }

  @override
  String dayLabel(String day) {
    return '$day';
  }

  @override
  String classTimeLabel(String startTime, String endTime) {
    return 'Time: $startTime - $endTime';
  }

  @override
  String get createClassSuccess => 'Class created successfully!';

  @override
  String get addScheduleDialog => 'Add Schedule';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get endTimeMustBeAfterStart => 'End time must be after start time';

  @override
  String get save => 'Save';

  @override
  String get attendance => 'Attendance';

  @override
  String get noAttendanceHistory => 'No history';

  @override
  String get attendanceDialog => 'Class Attendance';

  @override
  String studentNumber(int number) {
    return 'Student $number';
  }

  @override
  String get idLabel => 'ID';

  @override
  String get emailLabel => 'Email';

  @override
  String get classGrade => 'Grade';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get studentCount2 => 'Number of Students';

  @override
  String get createdDate => 'Created Date';

  @override
  String get availableTutorClasses => 'Available Tutor Classes';

  @override
  String get noTutorClassesAvailable =>
      'No tutor classes available at the moment';

  @override
  String get registerSuccess =>
      'Successfully registered! Please wait for teacher\'s approval.';

  @override
  String get registerError => 'Registration error';

  @override
  String get registering => 'Registering...';

  @override
  String get tuitionFee => 'Tuition Fee';

  @override
  String get perSession => 'VND/session';

  @override
  String get alreadyRegistered => 'You have already registered for this class';

  @override
  String confirmRegister(String className) {
    return 'Do you want to register for class \"$className\"?';
  }

  @override
  String get createClassButton => 'Create Class';

  @override
  String get classNameRequired => 'Class Name *';

  @override
  String get subjectRequired => 'Subject *';

  @override
  String get registerToJoin => 'Register to Join';

  @override
  String get registering2 => 'Registering...';

  @override
  String get waitingForApproval => 'Waiting for teacher approval';

  @override
  String get classFull => 'Class Full';

  @override
  String get studentsLabel => 'Students';

  @override
  String get spotsAvailable => 'Available';

  @override
  String get tuitionFeeLabel => 'Tuition Fee';

  @override
  String get subjectPrefix => 'Subject:';

  @override
  String get gradePrefix => 'Grade:';

  @override
  String get teacherPrefix => 'Teacher:';

  @override
  String get schedulePrefix => 'Schedule:';

  @override
  String get addressPrefix => 'Address:';

  @override
  String get classDetailInfo => 'Detailed Information';

  @override
  String get studentCountLabel => 'Number of Students';

  @override
  String studentCountValue(int current, int max) {
    return '$current/$max students';
  }

  @override
  String get classSchedule => 'Class Schedule';

  @override
  String get studentsInClass => 'Students in Class';

  @override
  String get noStudentsYet => 'No students yet';

  @override
  String get noStudentsDescription => 'No students have joined this class yet';

  @override
  String get errorLoadingClass => 'Error loading class information';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get pendingClasses => 'Pending Classes List';

  @override
  String get noPendingClasses => 'No pending classes';

  @override
  String confirmRemoveStudent(String studentName) {
    return 'Are you sure you want to remove student \"$studentName\" from the pending list?';
  }

  @override
  String studentRemoved(String studentName) {
    return 'Removed student $studentName from pending list';
  }

  @override
  String errorRemovingStudent(String error) {
    return 'Error removing student: $error';
  }

  @override
  String confirmApproveStudent(String studentName) {
    return 'Are you sure you want to approve student \"$studentName\" to join the class?';
  }

  @override
  String studentApproved(String studentName) {
    return 'Approved student $studentName';
  }

  @override
  String errorApprovingStudent(String error) {
    return 'Error approving student: $error';
  }

  @override
  String get pendingStudentsTitle => 'Pending Students';

  @override
  String pendingStudentsCount(int count) {
    return '$count pending students';
  }

  @override
  String get approveInstruction =>
      'Click \"Approve\" button to confirm students into the class';

  @override
  String get allStudentsApproved =>
      'All students have been approved or no one has registered yet';

  @override
  String get startAttendance => 'Start Attendance';

  @override
  String todayDate(String date) {
    return 'Today - $date';
  }

  @override
  String get attendanceStarted => 'Attendance started';

  @override
  String errorStartingAttendance(String error) {
    return 'Error starting attendance: $error';
  }

  @override
  String get absent => 'Absent';

  @override
  String get attendanceSaved => 'Attendance saved successfully';

  @override
  String errorSavingAttendance(String error) {
    return 'Error saving attendance: $error';
  }

  @override
  String get essayExercise => 'Essay Exercise';

  @override
  String get submitExercise => 'Submit Exercise';

  @override
  String get submitting => 'Submitting...';

  @override
  String get pleaseAnswerAllQuestions => 'Please answer all questions';

  @override
  String get mcqSummaryTitle => 'MCQ Submission';

  @override
  String submitSuccessScore(String score, String max) {
    return 'Submission succeeded! Score: $score/$max';
  }

  @override
  String submitError(String error) {
    return 'Error submitting exercise: $error';
  }

  @override
  String get enterContentOrFile => 'Please enter content or pick a file.';

  @override
  String get enterValidGrade => 'Please enter a valid grade';

  @override
  String gradeRange(String max) {
    return 'Grade must be between 0 - $max';
  }

  @override
  String downloaded(String fileName) {
    return 'Downloaded: $fileName';
  }

  @override
  String fileDownloadError(String error) {
    return 'File download error: $error';
  }

  @override
  String get submissionsListTitle => 'Submitted Students List';

  @override
  String get noSubmissionsYet => 'No students have submitted yet';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownTime => 'Unknown time';

  @override
  String get essay => 'Essay';

  @override
  String get multipleChoice => 'Multiple Choice';

  @override
  String timeLeftDays(int days) {
    return 'Remaining $days days';
  }

  @override
  String timeLeftHours(int hours) {
    return 'Remaining $hours hours';
  }

  @override
  String timeLeftMinutes(int minutes) {
    return 'Remaining $minutes minutes';
  }

  @override
  String get noExercises => 'No exercises';

  @override
  String get noQuestionsInMcq => 'This MCQ exercise has no questions';

  @override
  String get mcqExercise => 'MCQ Exercise';

  @override
  String questionCount(int count) {
    return '$count questions';
  }

  @override
  String questionLabel(int number) {
    return 'Question $number';
  }

  @override
  String get multipleAnswers => 'Multiple answers';

  @override
  String get enterContentLabel => 'Enter content';

  @override
  String get contentHint =>
      'Write your answer... (can be empty if attaching a file)';

  @override
  String get pickFile => 'Pick file';

  @override
  String get submitSuccessMessage => 'Submission succeeded';

  @override
  String get manage => 'Manage';

  @override
  String get viewResult => 'View Result';

  @override
  String get viewDetail => 'View Detail';

  @override
  String get doExercise => 'Do Exercise';

  @override
  String get submittedStudentsTitle => 'Submitted Students';

  @override
  String get errorLoadingList => 'Error loading list';

  @override
  String get unknownStudent => 'Unknown';

  @override
  String get scorePrefix => 'Score';

  @override
  String get hasFeedback => 'Has feedback';

  @override
  String get notGraded => 'Not graded';

  @override
  String get invalidGrade => 'Please enter a valid grade';

  @override
  String get graded => 'Graded';

  @override
  String get points => 'points';

  @override
  String get gradeError => 'Grading error';

  @override
  String get submittedAt => 'Submitted at';

  @override
  String get lateSubmission => 'Late';

  @override
  String get submissionContent => 'Submitted';

  @override
  String get attachments => 'Attachments';

  @override
  String get createdAt => 'Created at';

  @override
  String yourScore(String score, String max) {
    return 'Your score: $score/$max';
  }

  @override
  String get yourSubmissionNotGraded => 'Your submission: Not graded';

  @override
  String get redoExercise => 'Redo exercise';

  @override
  String get redoConfirmationContent =>
      'Are you sure you want to redo?\n\nThe previous submission will be permanently deleted.';

  @override
  String get submissionNotFound => 'Submission to delete not found';

  @override
  String get deletingOldSubmission => 'Deleting old submission...';

  @override
  String get fileUpload => 'File upload';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusOpen => 'Open';

  @override
  String get submission => 'Submission';

  @override
  String get upcomingClassTitle => 'Upcoming class';

  @override
  String get assignmentDueTitle => 'Assignment due';

  @override
  String assignmentDueDescription(String title, String hours) {
    return '$title - due in $hours hours';
  }

  @override
  String get newExerciseCreatedTitle => 'New exercise created';

  @override
  String newExerciseCreatedDescription(String title, String count) {
    return '$title - $count students submitted';
  }

  @override
  String get pleaseSelectDueDate => 'Please select a due date';

  @override
  String get pleaseAddAtLeastOneQuestion => 'Please add at least one question';

  @override
  String get createExerciseSuccess => 'Exercise created successfully!';

  @override
  String get exerciseTitleLabel => 'Exercise Title';

  @override
  String get enterExerciseTitle => 'Enter title for the exercise...';

  @override
  String get subjectHintExamples => 'Math, Literature, English...';

  @override
  String get createExerciseButton => 'Create Exercise';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get positiveIntegerError => 'Must be a positive integer';

  @override
  String get exerciseSettings => 'Exercise Settings';

  @override
  String get all => 'All';

  @override
  String get manageExercises => 'Manage Exercises';

  @override
  String get exerciseDetailTitle => 'Exercise details';
}
