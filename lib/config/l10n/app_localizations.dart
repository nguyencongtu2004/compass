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
  /// **'Sign up'**
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
  /// **'Confirm password'**
  String get confirmPassword;

  /// Link to reset password
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
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
  /// **'Add friend'**
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
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
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

  /// Button to share the user's location with friends
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocation;

  /// Message indicating that friends can see the user's location
  ///
  /// In en, this message translates to:
  /// **'Allow friends to see your location'**
  String get allowFriendsToSeeYourLocation;

  /// Label for the language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for the about section of the compass app
  ///
  /// In en, this message translates to:
  /// **'About Compass'**
  String get aboutCompass;

  /// Button to view information about the app
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

  /// Placeholder text for entering the user's password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Placeholder text for entering the user's email
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Button to log in to the application
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// Link to reset the user's password
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// Separator for alternative actions
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Message prompting the user to sign up if they do not have an account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up now'**
  String get donTHaveAnAccountSignUpNow;

  /// Message indicating that a password reset email has been sent
  ///
  /// In en, this message translates to:
  /// **'A password reset email has been sent to {email}.'**
  String aPasswordResetEmailHasBeenSentToStateEmail(String email);

  /// Button to create a new account
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// Instructions for filling in registration information
  ///
  /// In en, this message translates to:
  /// **'Fill in the information to register'**
  String get fillInTheInformationToRegister;

  /// Placeholder text for entering the user's display name
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterYourDisplayName;

  /// Placeholder text for entering a password with a minimum length
  ///
  /// In en, this message translates to:
  /// **'Enter password (at least 6 characters)'**
  String get enterPasswordAtLeast6Characters;

  /// Placeholder text for re-entering the password
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reEnterPassword;

  /// Message prompting the user to log in if they already have an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in now'**
  String get alreadyHaveAnAccountLogInNow;

  /// Instructions for entering an email address to receive a password reset link
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a password reset link:'**
  String get enterYourEmailAddressToReceiveAPasswordResetLink;

  /// Message indicating that a password reset email has been sent to the provided email address
  ///
  /// In en, this message translates to:
  /// **'A password reset email has been sent to {email}.'**
  String aPasswordResetEmailHasBeenSentToEmail(String email);

  /// Message indicating that a user has no location information
  ///
  /// In en, this message translates to:
  /// **'{displayName} has no location information'**
  String displaynameHasNoLocationInformation(String displayName);

  /// Error message with a placeholder for the specific error message
  ///
  /// In en, this message translates to:
  /// **'Lỗi: {message}'**
  String errorMessage(String message);

  /// Message prompting the user to try again after an error
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Error message when a user tries to send a message to themselves
  ///
  /// In en, this message translates to:
  /// **'You cannot send messages to yourself.'**
  String get youCannotSendMessagesToYourself;

  /// Error message when unable to create a conversation
  ///
  /// In en, this message translates to:
  /// **'Unable to create conversation: {e}'**
  String unableToCreateConversation(String e);

  /// Title for the details of a post
  ///
  /// In en, this message translates to:
  /// **'Post details'**
  String get postDetails;

  /// Label for available positions in a post
  ///
  /// In en, this message translates to:
  /// **'Available positions'**
  String get availablePositions;

  /// Message indicating that there are no available positions
  ///
  /// In en, this message translates to:
  /// **'No position available'**
  String get noPositionAvailable;

  /// Message indicating that there are no friends yet
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// Message indicating that there are no messages in the conversation
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Message prompting the user to start chatting with friends
  ///
  /// In en, this message translates to:
  /// **'Start chatting with your friends from your friends page'**
  String get startChattingWithYourFriendsFromYourFriendsPage;

  /// Button to navigate to the friends page
  ///
  /// In en, this message translates to:
  /// **'Go to friends page'**
  String get goToFriendsPage;

  /// Button to delete a conversation
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// Confirmation message when deleting a conversation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation?'**
  String get areYouSureYouWantToDeleteThisConversation;

  /// Message indicating that the action cannot be undone
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// Message indicating that a conversation has been deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted conversation'**
  String get deletedConversation;

  /// Label for an unknown user
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Label for an unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Generic error message displayed when an error occurs
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get anErrorHasOccurred;

  /// Message displayed while a conversation is being loaded
  ///
  /// In en, this message translates to:
  /// **'Loading conversation...'**
  String get loadingConversation;

  /// Message prompting the user to send a message to start a conversation
  ///
  /// In en, this message translates to:
  /// **'Send the first message to start a conversation'**
  String get sendTheFirstMessageToStartAConversation;

  /// Chat with a specific user
  ///
  /// In en, this message translates to:
  /// **'Chat with {displayName}'**
  String chatWithDisplayname(String displayName);

  /// Label for the user's profile picture
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// Button to select photos for the profile picture
  ///
  /// In en, this message translates to:
  /// **'Select photos from the library'**
  String get selectPhotosFromTheLibrary;

  /// Button to delete the user's profile picture
  ///
  /// In en, this message translates to:
  /// **'Delete profile picture'**
  String get deleteProfilePicture;

  /// Message indicating that the profile has been updated successfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Error message when the username is already taken
  ///
  /// In en, this message translates to:
  /// **'The username has already been used.'**
  String get theUsernameHasAlreadyBeenUsed;

  /// Label for the username input field
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// Placeholder text for entering a username
  ///
  /// In en, this message translates to:
  /// **'Enter your username (e.g., nguoidep_123)'**
  String get enterYourUsernameEGNguoidep123;

  /// Button to update the user's profile
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// Placeholder text for entering a message
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get enterMessage;

  /// Title for the friends list section
  ///
  /// In en, this message translates to:
  /// **'Friends list'**
  String get friendsList;

  /// Message indicating that a friend request has been sent
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSent;

  /// Message indicating that a user cannot add themselves as a friend
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself as a friend.'**
  String get youCannotAddYourselfAsAFriend;

  /// Message indicating that a user has become a friend
  ///
  /// In en, this message translates to:
  /// **'{displayName} is now your friend.'**
  String displaynameIsNowYourFriend(String displayName);

  /// Message indicating that a user has received a friend request
  ///
  /// In en, this message translates to:
  /// **'You have a friend request from {displayName}'**
  String youHaveAFriendRequestFromDisplayname(String displayName);

  /// Message indicating that a friend request has been accepted
  ///
  /// In en, this message translates to:
  /// **'Accepted friend request'**
  String get acceptedFriendRequest;

  /// Message indicating that a friend request has been declined
  ///
  /// In en, this message translates to:
  /// **'Friend request declined'**
  String get friendRequestDeclined;

  /// Message asking if the user wants to send a friend request
  ///
  /// In en, this message translates to:
  /// **'Would you like to send a friend request?'**
  String get wouldYouLikeToSendAFriendRequest;

  /// Button to send a friend request
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvitation;

  /// Placeholder text for searching friends by email
  ///
  /// In en, this message translates to:
  /// **'Search for friends via email...'**
  String get searchForFriendsViaEmail;

  /// Button to accept a friend request
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Button to reject a friend request
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Label for a text message
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get textMessage;

  /// Button to delete friends
  ///
  /// In en, this message translates to:
  /// **'Delete friends'**
  String get deleteFriends;

  /// Label for the number of friend requests
  ///
  /// In en, this message translates to:
  /// **'Friend request ({length})'**
  String friendRequestLength(int length);

  /// Label for the number of friends
  ///
  /// In en, this message translates to:
  /// **'Friends ({length})'**
  String friendsLength(int length);

  /// Message indicating that there are no friends yet and suggesting to add friends by email
  ///
  /// In en, this message translates to:
  /// **'No friends yet\\nAdd friends by email'**
  String get noFriendsYetNaddFriendsByEmail;

  /// Confirmation message when removing a friend
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {displayName} from your friends list?'**
  String areYouSureYouWantToRemoveDisplaynameFromYourFriendsList(
    String displayName,
  );

  /// Message indicating that removing a friend will also remove them from your friends list
  ///
  /// In en, this message translates to:
  /// **'This action will remove you from each other\'s friends list.'**
  String get thisActionWillRemoveYouFromEachOtherSFriendsList;

  /// Message indicating that friends have been deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted friends'**
  String get deletedFriends;

  /// Label for a message
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Error message when the home page cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Unable to load the home page'**
  String get unableToLoadTheHomePage;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordMustBeAtLeast6CharactersLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMustBeAtLeast6CharactersLong;

  /// No description provided for @confirmPasswordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordIsRequired;

  /// No description provided for @displayNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameIsRequired;

  /// No description provided for @displayNameMustBeAtLeast2CharactersLong.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters long'**
  String get displayNameMustBeAtLeast2CharactersLong;

  /// No description provided for @usernameMustBeAtLeast3CharactersLong.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long'**
  String get usernameMustBeAtLeast3CharactersLong;

  /// No description provided for @usernameCannotExceed20Characters.
  ///
  /// In en, this message translates to:
  /// **'Username cannot exceed 20 characters.'**
  String get usernameCannotExceed20Characters;

  /// No description provided for @usernamesCanOnlyContainLettersNumbersAndUnderscores.
  ///
  /// In en, this message translates to:
  /// **'Usernames can only contain letters, numbers, and underscores.'**
  String get usernamesCanOnlyContainLettersNumbersAndUnderscores;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;
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
