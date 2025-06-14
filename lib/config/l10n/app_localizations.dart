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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Minecraft Compass'**
  String get appTitle;

  /// The sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// The sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// The sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// The email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// The password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// The confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Link to reset password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Button to create a new account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Text for users who already have an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Text for users who do not have an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Button to sign in using Google account
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// The home screen of the app
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// The compass feature of the app
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compass;

  /// The map feature of the app
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// User profile section
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Friends section in the app
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Messages section in the app
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Newsfeed section in the app
  ///
  /// In en, this message translates to:
  /// **'Newsfeed'**
  String get newsfeed;

  /// Settings section in the app
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Button to edit an item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Button to add a new item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Button to remove an item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Button to confirm an action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Text displayed while loading data
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Button to retry an action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button to close a dialog or popup
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button to acknowledge a message
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Affirmative response button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Negative response button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Title for the compass feature
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassTitle;

  /// The direction displayed by the compass
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// The coordinates displayed on the compass
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// Latitude coordinate
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// Longitude coordinate
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// The accuracy of the location
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Unit of measurement for distance
  ///
  /// In en, this message translates to:
  /// **'meters'**
  String get meters;

  /// Title for the map feature
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// Label for the user's current location on the map
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// Placeholder text for the location search input
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocation;

  /// No description provided for @markers.
  ///
  /// In en, this message translates to:
  /// **'Markers'**
  String get markers;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @friendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsTitle;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message...'**
  String get sendMessage;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @changeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// No description provided for @newsfeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Newsfeed'**
  String get newsfeedTitle;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get locationServiceDisabled;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @signUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sign up successful'**
  String get signUpSuccessful;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully'**
  String get postCreated;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added successfully'**
  String get friendAdded;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get messageSent;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

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

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocation;

  /// No description provided for @allowFriendsToSeeYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow friends to see your location'**
  String get allowFriendsToSeeYourLocation;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @aboutCompass.
  ///
  /// In en, this message translates to:
  /// **'About Compass'**
  String get aboutCompass;

  /// No description provided for @viewAppInformation.
  ///
  /// In en, this message translates to:
  /// **'View app information'**
  String get viewAppInformation;

  /// Description of the compass app
  ///
  /// In en, this message translates to:
  /// **'A compass app that connects with friends, helping you navigate to your loved ones\' locations.'**
  String get compassAppDescription;

  /// Message indicating that the user's location is being shared
  ///
  /// In en, this message translates to:
  /// **'Your location is being shared with friends'**
  String get yourLocationIsBeingShared;

  /// Message indicating that location sharing is enabled
  ///
  /// In en, this message translates to:
  /// **'Location sharing enabled'**
  String get locationSharingEnabled;

  /// Confirmation message when signing out
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Label for user information
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Error message when user information cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Cannot load user information'**
  String get cannotLoadUserInformation;

  /// Message indicating that the app will restart
  ///
  /// In en, this message translates to:
  /// **'The app will restart to apply the new language'**
  String get appWillRestart;
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
