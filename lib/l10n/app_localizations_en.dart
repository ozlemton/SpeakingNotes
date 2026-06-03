// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpeakingNotes';

  @override
  String get allNotes => 'All Notes';

  @override
  String get searchNotes => 'Search notes...';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get select => 'Select';

  @override
  String get recordingAudio => 'Recording Audio';

  @override
  String get noNotesYet => 'No notes yet. Tap the mic to record.';

  @override
  String get noNotesFound => 'No notes found for your search.';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Turkish';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create your account';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get syncUnavailable => 'Sync Unavailable';

  @override
  String get syncUnavailableMessage =>
      'Cloud sync is unavailable. Your notes will be saved locally only.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get holdToEditOrDelete => 'Hold to edit or delete';

  @override
  String get failedToLoadCategories => 'Failed to load categories';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get failedToSaveNote => 'Failed to save note. Please try again.';

  @override
  String get newCategory => 'New Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"? Notes in this category will not be deleted.';
  }

  @override
  String get allCategories => 'All Categories';

  @override
  String get create => 'Create';

  @override
  String get recording => 'Recording';

  @override
  String get audio => 'Audio';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteNoteConfirm => 'This note will be permanently deleted.';

  @override
  String wordCharCount(int words, int chars) {
    return '$words words · $chars characters';
  }

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get validationEnterUsername => 'Please enter a username';

  @override
  String get validationUsernameLength =>
      'Username must be at least 2 characters';

  @override
  String get validationEnterEmail => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationEnterPassword => 'Please enter your password';

  @override
  String get validationPasswordLength =>
      'Password must be at least 6 characters';
}
