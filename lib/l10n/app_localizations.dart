import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EduSync'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @academicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get academicInfo;

  /// No description provided for @feeManagement.
  ///
  /// In en, this message translates to:
  /// **'Fee Management'**
  String get feeManagement;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @errorLoadingUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading user info'**
  String get errorLoadingUserInfo;

  /// No description provided for @cannotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Cannot load data'**
  String get cannotLoadData;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @todayAssignments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Assignments'**
  String get todayAssignments;

  /// No description provided for @classesJoined.
  ///
  /// In en, this message translates to:
  /// **'Classes Joined'**
  String get classesJoined;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @noActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivities;

  /// No description provided for @todayAssignmentsCount.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Assignments ({count})'**
  String todayAssignmentsCount(int count);

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @notSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not Submitted'**
  String get notSubmitted;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get deadline;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @managedClasses.
  ///
  /// In en, this message translates to:
  /// **'Managed Classes'**
  String get managedClasses;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @pendingGrading.
  ///
  /// In en, this message translates to:
  /// **'Pending Grading'**
  String get pendingGrading;

  /// No description provided for @todayClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get todayClasses;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @createExercise.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExercise;

  /// No description provided for @takeAttendance.
  ///
  /// In en, this message translates to:
  /// **'Take Attendance'**
  String get takeAttendance;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule ({count})'**
  String todaySchedule(int count);

  /// No description provided for @studentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String studentCount(int count);

  /// No description provided for @submissionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} submissions'**
  String submissionCount(int count);

  /// No description provided for @createExerciseFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Create exercise feature is under development'**
  String get createExerciseFeatureInDevelopment;

  /// No description provided for @takeAttendanceFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Take attendance feature is under development'**
  String get takeAttendanceFeatureInDevelopment;

  /// No description provided for @classNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Class not updated'**
  String get classNotUpdated;

  /// No description provided for @schoolNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'School not updated'**
  String get schoolNotUpdated;

  /// No description provided for @tutorClasses.
  ///
  /// In en, this message translates to:
  /// **'tutor classes'**
  String get tutorClasses;

  /// No description provided for @createdClasses.
  ///
  /// In en, this message translates to:
  /// **'created classes'**
  String get createdClasses;

  /// No description provided for @classCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully created class \"{className}\"!'**
  String classCreatedSuccess(String className);

  /// No description provided for @schoolSubjects.
  ///
  /// In en, this message translates to:
  /// **'School Subjects'**
  String get schoolSubjects;

  /// No description provided for @tutorClassesTab.
  ///
  /// In en, this message translates to:
  /// **'Tutor Classes'**
  String get tutorClassesTab;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @classInfo.
  ///
  /// In en, this message translates to:
  /// **'Class Information:'**
  String get classInfo;

  /// No description provided for @schoolInfo.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get schoolInfo;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'subjects'**
  String get subjects;

  /// No description provided for @createNewClass.
  ///
  /// In en, this message translates to:
  /// **'Create New Class'**
  String get createNewClass;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @gradeLevel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeLevel;

  /// No description provided for @teacherName.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherName;

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule:'**
  String get scheduleLabel;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @todayAttendance.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Attendance'**
  String get todayAttendance;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noHistory;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @classAttendance.
  ///
  /// In en, this message translates to:
  /// **'Class Attendance'**
  String get classAttendance;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get saveAttendance;

  /// No description provided for @createClass.
  ///
  /// In en, this message translates to:
  /// **'Create New Class'**
  String get createClass;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @className.
  ///
  /// In en, this message translates to:
  /// **'Class Name *'**
  String get className;

  /// No description provided for @enterClassName.
  ///
  /// In en, this message translates to:
  /// **'Enter class name'**
  String get enterClassName;

  /// No description provided for @pleaseEnterClassName.
  ///
  /// In en, this message translates to:
  /// **'Please enter class name'**
  String get pleaseEnterClassName;

  /// No description provided for @subjectName.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get subjectName;

  /// No description provided for @enterSubject.
  ///
  /// In en, this message translates to:
  /// **'Enter subject'**
  String get enterSubject;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter subject'**
  String get pleaseEnterSubject;

  /// No description provided for @extraClass.
  ///
  /// In en, this message translates to:
  /// **'Extra Class'**
  String get extraClass;

  /// No description provided for @extraClassHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: Grade 12, Grade 10, ...'**
  String get extraClassHint;

  /// No description provided for @pricePerSession.
  ///
  /// In en, this message translates to:
  /// **'Price per Session (VND)'**
  String get pricePerSession;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'E.g: 20,000'**
  String get priceHint;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full description for the exercise...'**
  String get descriptionHint;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter study location'**
  String get locationHint;

  /// No description provided for @maxStudents.
  ///
  /// In en, this message translates to:
  /// **'Maximum Students'**
  String get maxStudents;

  /// No description provided for @maxStudentsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter maximum number of students'**
  String get maxStudentsHint;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @scheduleNumber.
  ///
  /// In en, this message translates to:
  /// **'Schedule {number}'**
  String scheduleNumber(int number);

  /// No description provided for @enterClassCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Class Code'**
  String get enterClassCode;

  /// No description provided for @enterClassCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the class code provided by your teacher to join the school class.'**
  String get enterClassCodeDescription;

  /// No description provided for @joinClass.
  ///
  /// In en, this message translates to:
  /// **'Join Class'**
  String get joinClass;

  /// No description provided for @noSubjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No Subjects Yet'**
  String get noSubjectsYet;

  /// No description provided for @enterCodeToJoin.
  ///
  /// In en, this message translates to:
  /// **'Enter the class code provided by your teacher to start joining school subjects'**
  String get enterCodeToJoin;

  /// No description provided for @enterClassCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Enter Class Code'**
  String get enterClassCodeButton;

  /// No description provided for @classesCreated.
  ///
  /// In en, this message translates to:
  /// **'{count} classes created'**
  String classesCreated(int count);

  /// No description provided for @noClassesYet.
  ///
  /// In en, this message translates to:
  /// **'No Classes Yet'**
  String get noClassesYet;

  /// No description provided for @createFirstClass.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any school classes yet. Create a new class to get started.'**
  String get createFirstClass;

  /// No description provided for @dataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Data Load Error'**
  String get dataLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noTutorRegistered.
  ///
  /// In en, this message translates to:
  /// **'No Tutor Classes Registered'**
  String get noTutorRegistered;

  /// No description provided for @noTutorCreated.
  ///
  /// In en, this message translates to:
  /// **'No Tutor Classes Yet'**
  String get noTutorCreated;

  /// No description provided for @findTutorClasses.
  ///
  /// In en, this message translates to:
  /// **'Find and register for suitable tutor classes'**
  String get findTutorClasses;

  /// No description provided for @createFirstTutorClass.
  ///
  /// In en, this message translates to:
  /// **'Create your first tutor class'**
  String get createFirstTutorClass;

  /// No description provided for @findTutorButton.
  ///
  /// In en, this message translates to:
  /// **'Find Tutor Classes'**
  String get findTutorButton;

  /// No description provided for @registrationApplications.
  ///
  /// In en, this message translates to:
  /// **'Registration Applications'**
  String get registrationApplications;

  /// No description provided for @noTeacherIdError.
  ///
  /// In en, this message translates to:
  /// **'Teacher ID not found. Please log in again.'**
  String get noTeacherIdError;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined Class'**
  String get joined;

  /// No description provided for @teacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherLabel;

  /// No description provided for @youSelectedClass.
  ///
  /// In en, this message translates to:
  /// **'You selected class {className}'**
  String youSelectedClass(String className);

  /// No description provided for @tutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get tutor;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @classCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Class Code'**
  String get classCodeLabel;

  /// No description provided for @classCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 5LG9HA'**
  String get classCodeHint;

  /// No description provided for @pleaseEnterClassCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter class code'**
  String get pleaseEnterClassCode;

  /// No description provided for @joining.
  ///
  /// In en, this message translates to:
  /// **'Joining...'**
  String get joining;

  /// No description provided for @joinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined the class'**
  String get joinSuccess;

  /// No description provided for @filterByGrade.
  ///
  /// In en, this message translates to:
  /// **'Filter by grade'**
  String get filterByGrade;

  /// No description provided for @allGrades.
  ///
  /// In en, this message translates to:
  /// **'All grades'**
  String get allGrades;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @registerTutorClass.
  ///
  /// In en, this message translates to:
  /// **'Register for Tutor Class'**
  String get registerTutorClass;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @noScheduleYet.
  ///
  /// In en, this message translates to:
  /// **'No schedule yet'**
  String get noScheduleYet;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this student from the pending list?'**
  String get confirmDeleteMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Confirm Approve'**
  String get confirmApprove;

  /// No description provided for @confirmApproveMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this student to join the class?'**
  String get confirmApproveMessage;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @loadingPendingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading pending students list...'**
  String get loadingPendingStudents;

  /// No description provided for @noPendingStudents.
  ///
  /// In en, this message translates to:
  /// **'No pending students'**
  String get noPendingStudents;

  /// No description provided for @classInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Class information not found'**
  String get classInfoNotFound;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get featureInDevelopment;

  /// No description provided for @confirmDeleteClass.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this class?'**
  String get confirmDeleteClass;

  /// No description provided for @deleteClassError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting class: {error}'**
  String deleteClassError(String error);

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'{day}'**
  String dayLabel(String day);

  /// No description provided for @classTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {startTime} - {endTime}'**
  String classTimeLabel(String startTime, String endTime);

  /// No description provided for @createClassSuccess.
  ///
  /// In en, this message translates to:
  /// **'Class created successfully!'**
  String get createClassSuccess;

  /// No description provided for @addScheduleDialog.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addScheduleDialog;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @endTimeMustBeAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endTimeMustBeAfterStart;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @noAttendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noAttendanceHistory;

  /// No description provided for @attendanceDialog.
  ///
  /// In en, this message translates to:
  /// **'Class Attendance'**
  String get attendanceDialog;

  /// No description provided for @studentNumber.
  ///
  /// In en, this message translates to:
  /// **'Student {number}'**
  String studentNumber(int number);

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @classGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get classGrade;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @studentCount2.
  ///
  /// In en, this message translates to:
  /// **'Number of Students'**
  String get studentCount2;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @availableTutorClasses.
  ///
  /// In en, this message translates to:
  /// **'Available Tutor Classes'**
  String get availableTutorClasses;

  /// No description provided for @noTutorClassesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tutor classes available at the moment'**
  String get noTutorClassesAvailable;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully registered! Please wait for teacher\'s approval.'**
  String get registerSuccess;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registerError;

  /// No description provided for @registering.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering;

  /// No description provided for @tuitionFee.
  ///
  /// In en, this message translates to:
  /// **'Tuition Fee'**
  String get tuitionFee;

  /// No description provided for @perSession.
  ///
  /// In en, this message translates to:
  /// **'VND/session'**
  String get perSession;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'You have already registered for this class'**
  String get alreadyRegistered;

  /// No description provided for @confirmRegister.
  ///
  /// In en, this message translates to:
  /// **'Do you want to register for class \"{className}\"?'**
  String confirmRegister(String className);

  /// No description provided for @createClassButton.
  ///
  /// In en, this message translates to:
  /// **'Create Class'**
  String get createClassButton;

  /// No description provided for @classNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Class Name *'**
  String get classNameRequired;

  /// No description provided for @subjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get subjectRequired;

  /// No description provided for @registerToJoin.
  ///
  /// In en, this message translates to:
  /// **'Register to Join'**
  String get registerToJoin;

  /// No description provided for @registering2.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registering2;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for teacher approval'**
  String get waitingForApproval;

  /// No description provided for @classFull.
  ///
  /// In en, this message translates to:
  /// **'Class Full'**
  String get classFull;

  /// No description provided for @studentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get studentsLabel;

  /// No description provided for @spotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get spotsAvailable;

  /// No description provided for @tuitionFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tuition Fee'**
  String get tuitionFeeLabel;

  /// No description provided for @subjectPrefix.
  ///
  /// In en, this message translates to:
  /// **'Subject:'**
  String get subjectPrefix;

  /// No description provided for @gradePrefix.
  ///
  /// In en, this message translates to:
  /// **'Grade:'**
  String get gradePrefix;

  /// No description provided for @teacherPrefix.
  ///
  /// In en, this message translates to:
  /// **'Teacher:'**
  String get teacherPrefix;

  /// No description provided for @schedulePrefix.
  ///
  /// In en, this message translates to:
  /// **'Schedule:'**
  String get schedulePrefix;

  /// No description provided for @addressPrefix.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get addressPrefix;

  /// No description provided for @classDetailInfo.
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get classDetailInfo;

  /// No description provided for @studentCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of Students'**
  String get studentCountLabel;

  /// No description provided for @studentCountValue.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} students'**
  String studentCountValue(int current, int max);

  /// No description provided for @classSchedule.
  ///
  /// In en, this message translates to:
  /// **'Class Schedule'**
  String get classSchedule;

  /// No description provided for @studentsInClass.
  ///
  /// In en, this message translates to:
  /// **'Students in Class'**
  String get studentsInClass;

  /// No description provided for @noStudentsYet.
  ///
  /// In en, this message translates to:
  /// **'No students yet'**
  String get noStudentsYet;

  /// No description provided for @noStudentsDescription.
  ///
  /// In en, this message translates to:
  /// **'No students have joined this class yet'**
  String get noStudentsDescription;

  /// No description provided for @errorLoadingClass.
  ///
  /// In en, this message translates to:
  /// **'Error loading class information'**
  String get errorLoadingClass;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @pendingClasses.
  ///
  /// In en, this message translates to:
  /// **'Pending Classes List'**
  String get pendingClasses;

  /// No description provided for @noPendingClasses.
  ///
  /// In en, this message translates to:
  /// **'No pending classes'**
  String get noPendingClasses;

  /// No description provided for @confirmRemoveStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove student \"{studentName}\" from the pending list?'**
  String confirmRemoveStudent(String studentName);

  /// No description provided for @studentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed student {studentName} from pending list'**
  String studentRemoved(String studentName);

  /// No description provided for @errorRemovingStudent.
  ///
  /// In en, this message translates to:
  /// **'Error removing student: {error}'**
  String errorRemovingStudent(String error);

  /// No description provided for @confirmApproveStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve student \"{studentName}\" to join the class?'**
  String confirmApproveStudent(String studentName);

  /// No description provided for @studentApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved student {studentName}'**
  String studentApproved(String studentName);

  /// No description provided for @errorApprovingStudent.
  ///
  /// In en, this message translates to:
  /// **'Error approving student: {error}'**
  String errorApprovingStudent(String error);

  /// No description provided for @pendingStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Students'**
  String get pendingStudentsTitle;

  /// No description provided for @pendingStudentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending students'**
  String pendingStudentsCount(int count);

  /// No description provided for @approveInstruction.
  ///
  /// In en, this message translates to:
  /// **'Click \"Approve\" button to confirm students into the class'**
  String get approveInstruction;

  /// No description provided for @allStudentsApproved.
  ///
  /// In en, this message translates to:
  /// **'All students have been approved or no one has registered yet'**
  String get allStudentsApproved;

  /// No description provided for @startAttendance.
  ///
  /// In en, this message translates to:
  /// **'Start Attendance'**
  String get startAttendance;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today - {date}'**
  String todayDate(String date);

  /// No description provided for @attendanceStarted.
  ///
  /// In en, this message translates to:
  /// **'Attendance started'**
  String get attendanceStarted;

  /// No description provided for @errorStartingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Error starting attendance: {error}'**
  String errorStartingAttendance(String error);

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved successfully'**
  String get attendanceSaved;

  /// No description provided for @errorSavingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Error saving attendance: {error}'**
  String errorSavingAttendance(String error);

  /// No description provided for @essayExercise.
  ///
  /// In en, this message translates to:
  /// **'Essay Exercise'**
  String get essayExercise;

  /// No description provided for @submitExercise.
  ///
  /// In en, this message translates to:
  /// **'Submit Exercise'**
  String get submitExercise;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @pleaseAnswerAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions'**
  String get pleaseAnswerAllQuestions;

  /// No description provided for @mcqSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'MCQ Submission'**
  String get mcqSummaryTitle;

  /// No description provided for @submitSuccessScore.
  ///
  /// In en, this message translates to:
  /// **'Submission succeeded! Score: {score}/{max}'**
  String submitSuccessScore(String score, String max);

  /// No description provided for @submitError.
  ///
  /// In en, this message translates to:
  /// **'Error submitting exercise: {error}'**
  String submitError(String error);

  /// No description provided for @enterContentOrFile.
  ///
  /// In en, this message translates to:
  /// **'Please enter content or pick a file.'**
  String get enterContentOrFile;

  /// No description provided for @enterValidGrade.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid grade'**
  String get enterValidGrade;

  /// No description provided for @gradeRange.
  ///
  /// In en, this message translates to:
  /// **'Grade must be between 0 - {max}'**
  String gradeRange(String max);

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded: {fileName}'**
  String downloaded(String fileName);

  /// No description provided for @fileDownloadError.
  ///
  /// In en, this message translates to:
  /// **'File download error: {error}'**
  String fileDownloadError(String error);

  /// No description provided for @submissionsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted Students List'**
  String get submissionsListTitle;

  /// No description provided for @noSubmissionsYet.
  ///
  /// In en, this message translates to:
  /// **'No students have submitted yet'**
  String get noSubmissionsYet;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get unknownTime;

  /// No description provided for @essay.
  ///
  /// In en, this message translates to:
  /// **'Essay'**
  String get essay;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @timeLeftDays.
  ///
  /// In en, this message translates to:
  /// **'Remaining {days} days'**
  String timeLeftDays(int days);

  /// No description provided for @timeLeftHours.
  ///
  /// In en, this message translates to:
  /// **'Remaining {hours} hours'**
  String timeLeftHours(int hours);

  /// No description provided for @timeLeftMinutes.
  ///
  /// In en, this message translates to:
  /// **'Remaining {minutes} minutes'**
  String timeLeftMinutes(int minutes);

  /// No description provided for @noExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises'**
  String get noExercises;

  /// No description provided for @noQuestionsInMcq.
  ///
  /// In en, this message translates to:
  /// **'This MCQ exercise has no questions'**
  String get noQuestionsInMcq;

  /// No description provided for @mcqExercise.
  ///
  /// In en, this message translates to:
  /// **'MCQ Exercise'**
  String get mcqExercise;

  /// No description provided for @questionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionCount(int count);

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionLabel(int number);

  /// No description provided for @multipleAnswers.
  ///
  /// In en, this message translates to:
  /// **'Multiple answers'**
  String get multipleAnswers;

  /// No description provided for @enterContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter content'**
  String get enterContentLabel;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your answer... (can be empty if attaching a file)'**
  String get contentHint;

  /// No description provided for @pickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick file'**
  String get pickFile;

  /// No description provided for @submitSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Submission succeeded'**
  String get submitSuccessMessage;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View Result'**
  String get viewResult;

  /// No description provided for @viewDetail.
  ///
  /// In en, this message translates to:
  /// **'View Detail'**
  String get viewDetail;

  /// No description provided for @doExercise.
  ///
  /// In en, this message translates to:
  /// **'Do Exercise'**
  String get doExercise;

  /// No description provided for @submittedStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted Students'**
  String get submittedStudentsTitle;

  /// No description provided for @errorLoadingList.
  ///
  /// In en, this message translates to:
  /// **'Error loading list'**
  String get errorLoadingList;

  /// No description provided for @unknownStudent.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownStudent;

  /// No description provided for @scorePrefix.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scorePrefix;

  /// No description provided for @hasFeedback.
  ///
  /// In en, this message translates to:
  /// **'Has feedback'**
  String get hasFeedback;

  /// No description provided for @notGraded.
  ///
  /// In en, this message translates to:
  /// **'Not graded'**
  String get notGraded;

  /// No description provided for @invalidGrade.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid grade'**
  String get invalidGrade;

  /// No description provided for @graded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get graded;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @gradeError.
  ///
  /// In en, this message translates to:
  /// **'Grading error'**
  String get gradeError;

  /// No description provided for @submittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted at'**
  String get submittedAt;

  /// No description provided for @lateSubmission.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateSubmission;

  /// No description provided for @submissionContent.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submissionContent;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score: {score}/{max}'**
  String yourScore(String score, String max);

  /// No description provided for @yourSubmissionNotGraded.
  ///
  /// In en, this message translates to:
  /// **'Your submission: Not graded'**
  String get yourSubmissionNotGraded;

  /// No description provided for @redoExercise.
  ///
  /// In en, this message translates to:
  /// **'Redo exercise'**
  String get redoExercise;

  /// No description provided for @redoConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to redo?\n\nThe previous submission will be permanently deleted.'**
  String get redoConfirmationContent;

  /// No description provided for @submissionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Submission to delete not found'**
  String get submissionNotFound;

  /// No description provided for @deletingOldSubmission.
  ///
  /// In en, this message translates to:
  /// **'Deleting old submission...'**
  String get deletingOldSubmission;

  /// No description provided for @fileUpload.
  ///
  /// In en, this message translates to:
  /// **'File upload'**
  String get fileUpload;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @submission.
  ///
  /// In en, this message translates to:
  /// **'Submission'**
  String get submission;

  /// No description provided for @upcomingClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming class'**
  String get upcomingClassTitle;

  /// No description provided for @assignmentDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment due'**
  String get assignmentDueTitle;

  /// No description provided for @assignmentDueDescription.
  ///
  /// In en, this message translates to:
  /// **'{title} - due in {hours} hours'**
  String assignmentDueDescription(String title, String hours);

  /// No description provided for @newExerciseCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'New exercise created'**
  String get newExerciseCreatedTitle;

  /// No description provided for @newExerciseCreatedDescription.
  ///
  /// In en, this message translates to:
  /// **'{title} - {count} students submitted'**
  String newExerciseCreatedDescription(String title, String count);

  /// No description provided for @pleaseSelectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a due date'**
  String get pleaseSelectDueDate;

  /// No description provided for @pleaseAddAtLeastOneQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one question'**
  String get pleaseAddAtLeastOneQuestion;

  /// No description provided for @createExerciseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exercise created successfully!'**
  String get createExerciseSuccess;

  /// No description provided for @exerciseTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Title'**
  String get exerciseTitleLabel;

  /// No description provided for @enterExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter title for the exercise...'**
  String get enterExerciseTitle;

  /// No description provided for @subjectHintExamples.
  ///
  /// In en, this message translates to:
  /// **'Math, Literature, English...'**
  String get subjectHintExamples;

  /// No description provided for @createExerciseButton.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExerciseButton;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @positiveIntegerError.
  ///
  /// In en, this message translates to:
  /// **'Must be a positive integer'**
  String get positiveIntegerError;

  /// No description provided for @exerciseSettings.
  ///
  /// In en, this message translates to:
  /// **'Exercise Settings'**
  String get exerciseSettings;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @manageExercises.
  ///
  /// In en, this message translates to:
  /// **'Manage Exercises'**
  String get manageExercises;

  /// No description provided for @exerciseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise details'**
  String get exerciseDetailTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
