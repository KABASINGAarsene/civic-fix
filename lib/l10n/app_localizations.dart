import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DistrictDirect Rwanda'**
  String get appName;

  /// No description provided for @rolePortalTitle.
  ///
  /// In en, this message translates to:
  /// **'DistrictDirect'**
  String get rolePortalTitle;

  /// No description provided for @rolePortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Government Service Portal'**
  String get rolePortalSubtitle;

  /// No description provided for @roleCitizenTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen Access'**
  String get roleCitizenTitle;

  /// No description provided for @roleCitizenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report local issues and follow updates'**
  String get roleCitizenSubtitle;

  /// No description provided for @roleAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get roleAdminTitle;

  /// No description provided for @roleAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage district services and incidents'**
  String get roleAdminSubtitle;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Government of Rwanda'**
  String get copyright;

  /// No description provided for @homeReportNewIssue.
  ///
  /// In en, this message translates to:
  /// **'REPORT NEW ISSUE'**
  String get homeReportNewIssue;

  /// No description provided for @homeDistrictFeed.
  ///
  /// In en, this message translates to:
  /// **'District Feed'**
  String get homeDistrictFeed;

  /// No description provided for @homeViewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get homeViewMap;

  /// No description provided for @homeNoDistrictReports.
  ///
  /// In en, this message translates to:
  /// **'No district reports yet. Be the first!'**
  String get homeNoDistrictReports;

  /// No description provided for @homeProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get homeProvince;

  /// No description provided for @homeDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get homeDistrict;

  /// No description provided for @homeSector.
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get homeSector;

  /// No description provided for @homeDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get homeDetails;

  /// No description provided for @homeLabel.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get homeLabel;

  /// No description provided for @reportsLabel.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reportsLabel;

  /// No description provided for @chatsLabel.
  ///
  /// In en, this message translates to:
  /// **'CHATS'**
  String get chatsLabel;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileLabel;

  /// No description provided for @citizenProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get citizenProfileTitle;

  /// No description provided for @citizenAppTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get citizenAppTheme;

  /// No description provided for @citizenDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get citizenDarkMode;

  /// No description provided for @citizenLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get citizenLightMode;

  /// No description provided for @citizenNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get citizenNotifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @citizenSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get citizenSecurity;

  /// No description provided for @citizenSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Password, PIN'**
  String get citizenSecuritySubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get kinyarwanda;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @passwordResetPrompt.
  ///
  /// In en, this message translates to:
  /// **'We will send a secure password reset link to your email address. Do you want to proceed?'**
  String get passwordResetPrompt;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @telPrefix.
  ///
  /// In en, this message translates to:
  /// **'TEL:'**
  String get telPrefix;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email! (Check your spam)'**
  String get passwordResetSent;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found. Cannot reset password.'**
  String get emailNotFound;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Profile'**
  String get adminProfileTitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get security;

  /// No description provided for @districtAdmin.
  ///
  /// In en, this message translates to:
  /// **'District Admin'**
  String get districtAdmin;

  /// No description provided for @adminUserFallback.
  ///
  /// In en, this message translates to:
  /// **'Admin User'**
  String get adminUserFallback;

  /// No description provided for @unknownDistrict.
  ///
  /// In en, this message translates to:
  /// **'Unknown District'**
  String get unknownDistrict;

  /// No description provided for @noEmailAvailable.
  ///
  /// In en, this message translates to:
  /// **'No email available'**
  String get noEmailAvailable;

  /// No description provided for @adminDashboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminDashboardLabel;

  /// No description provided for @adminIssuesLabel.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get adminIssuesLabel;

  /// No description provided for @adminMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get adminMapLabel;

  /// No description provided for @citizenChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Conversations'**
  String get citizenChatsTitle;

  /// No description provided for @pleaseLoginToViewChats.
  ///
  /// In en, this message translates to:
  /// **'Please login to view chats'**
  String get pleaseLoginToViewChats;

  /// No description provided for @syncingConversations.
  ///
  /// In en, this message translates to:
  /// **'Syncing Conversations...'**
  String get syncingConversations;

  /// No description provided for @chatSystemSyncingMessage.
  ///
  /// In en, this message translates to:
  /// **'The chat system is being synchronized. Please wait a few moments or try again later.'**
  String get chatSystemSyncingMessage;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @startChatFromReports.
  ///
  /// In en, this message translates to:
  /// **'Start a chat from your issue reports.'**
  String get startChatFromReports;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check updates...'**
  String get checkUpdates;

  /// No description provided for @districtOfficial.
  ///
  /// In en, this message translates to:
  /// **'District Official'**
  String get districtOfficial;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReportsTitle;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @submittedStatus.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submittedStatus;

  /// No description provided for @receivedStatus.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedStatus;

  /// No description provided for @assignedStatus.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedStatus;

  /// No description provided for @fieldVisitStatus.
  ///
  /// In en, this message translates to:
  /// **'Field Visit'**
  String get fieldVisitStatus;

  /// No description provided for @resolvedStatus.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedStatus;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @tapPlusToSubmitIssue.
  ///
  /// In en, this message translates to:
  /// **'Tap + to submit a new issue'**
  String get tapPlusToSubmitIssue;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @acknowledgedByDistrict.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged by District'**
  String get acknowledgedByDistrict;

  /// No description provided for @fieldTeamAssigned.
  ///
  /// In en, this message translates to:
  /// **'Field team assigned'**
  String get fieldTeamAssigned;

  /// No description provided for @teamOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Team is on location'**
  String get teamOnLocation;

  /// No description provided for @issueResolved.
  ///
  /// In en, this message translates to:
  /// **'Issue has been resolved'**
  String get issueResolved;

  /// No description provided for @awaitingDistrictReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting district review'**
  String get awaitingDistrictReview;

  /// No description provided for @issuesManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Issues Management'**
  String get issuesManagementTitle;

  /// No description provided for @noDistrictAssigned.
  ///
  /// In en, this message translates to:
  /// **'No district assigned to your profile.'**
  String get noDistrictAssigned;

  /// No description provided for @noIssuesIn.
  ///
  /// In en, this message translates to:
  /// **'No issues in'**
  String get noIssuesIn;

  /// No description provided for @recentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentLabel;

  /// No description provided for @untitledIssue.
  ///
  /// In en, this message translates to:
  /// **'Untitled Issue'**
  String get untitledIssue;

  /// No description provided for @prioritySuffix.
  ///
  /// In en, this message translates to:
  /// **'PRIORITY'**
  String get prioritySuffix;

  /// No description provided for @citizenMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen Messages'**
  String get citizenMessagesTitle;

  /// No description provided for @pleaseLogInAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please log in as admin'**
  String get pleaseLogInAsAdmin;

  /// No description provided for @indexRequired.
  ///
  /// In en, this message translates to:
  /// **'Index Required'**
  String get indexRequired;

  /// No description provided for @indexRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'To sort chats by time, Firestore needs a composite index. Please click the link in your console or check the project documentation to enable it.'**
  String get indexRequiredDescription;

  /// No description provided for @noActiveConversations.
  ///
  /// In en, this message translates to:
  /// **'No active conversations'**
  String get noActiveConversations;

  /// No description provided for @sendUpdateToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Send an update from a ticket to start a chat.'**
  String get sendUpdateToStartChat;

  /// No description provided for @ticketFallback.
  ///
  /// In en, this message translates to:
  /// **'TICKET'**
  String get ticketFallback;

  /// No description provided for @districtFieldMapTitle.
  ///
  /// In en, this message translates to:
  /// **'District Field Map'**
  String get districtFieldMapTitle;

  /// No description provided for @togglingHeatmapLayer.
  ///
  /// In en, this message translates to:
  /// **'Toggling Heatmap Layer...'**
  String get togglingHeatmapLayer;

  /// No description provided for @exclusiveTerritoryView.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Territory View'**
  String get exclusiveTerritoryView;

  /// No description provided for @viewingIssuesAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Viewing issues assigned to'**
  String get viewingIssuesAssignedTo;

  /// No description provided for @activeFieldTeams.
  ///
  /// In en, this message translates to:
  /// **'Active Field Teams'**
  String get activeFieldTeams;

  /// No description provided for @activeVisits.
  ///
  /// In en, this message translates to:
  /// **'Active visits'**
  String get activeVisits;

  /// No description provided for @fieldSupportTeams.
  ///
  /// In en, this message translates to:
  /// **'Field Support Teams'**
  String get fieldSupportTeams;

  /// No description provided for @resolvedIssues.
  ///
  /// In en, this message translates to:
  /// **'Resolved Issues'**
  String get resolvedIssues;

  /// No description provided for @closedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get closedToday;

  /// No description provided for @districtActivity.
  ///
  /// In en, this message translates to:
  /// **'District Activity'**
  String get districtActivity;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @recentPerformance.
  ///
  /// In en, this message translates to:
  /// **'Recent Performance'**
  String get recentPerformance;

  /// No description provided for @receivedStat.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED'**
  String get receivedStat;

  /// No description provided for @inProgressStat.
  ///
  /// In en, this message translates to:
  /// **'IN-PROGRESS'**
  String get inProgressStat;

  /// No description provided for @resolvedTotalStat.
  ///
  /// In en, this message translates to:
  /// **'RESOLVED TOTAL'**
  String get resolvedTotalStat;

  /// No description provided for @myDistrictStat.
  ///
  /// In en, this message translates to:
  /// **'MY DISTRICT'**
  String get myDistrictStat;

  /// No description provided for @liveTrend.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTrend;

  /// No description provided for @activeTrend.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTrend;

  /// No description provided for @checkTrend.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkTrend;

  /// No description provided for @safeTrend.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safeTrend;

  /// No description provided for @currentHotspot.
  ///
  /// In en, this message translates to:
  /// **'CURRENT HOTSPOT'**
  String get currentHotspot;

  /// No description provided for @currentDistrict.
  ///
  /// In en, this message translates to:
  /// **'Current District'**
  String get currentDistrict;

  /// No description provided for @reportsFound.
  ///
  /// In en, this message translates to:
  /// **'Reports Found'**
  String get reportsFound;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalLabel;

  /// No description provided for @ticketNotFoundOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Ticket not found or session expired.'**
  String get ticketNotFoundOrExpired;

  /// No description provided for @imageCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Image could not be loaded'**
  String get imageCouldNotLoad;

  /// No description provided for @noPhotoProvided.
  ///
  /// In en, this message translates to:
  /// **'No photo provided'**
  String get noPhotoProvided;

  /// No description provided for @citizenDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'CITIZEN DETAILS'**
  String get citizenDetailsLabel;

  /// No description provided for @citizenUser.
  ///
  /// In en, this message translates to:
  /// **'Citizen User'**
  String get citizenUser;

  /// No description provided for @phonePrivate.
  ///
  /// In en, this message translates to:
  /// **'Phone Private'**
  String get phonePrivate;

  /// No description provided for @citizenVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Citizen Voice Note'**
  String get citizenVoiceNote;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @citizenProvidedLocation.
  ///
  /// In en, this message translates to:
  /// **'Citizen Provided Location'**
  String get citizenProvidedLocation;

  /// No description provided for @couldNotLaunchMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not launch maps.'**
  String get couldNotLaunchMaps;

  /// No description provided for @uploadResolutionPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload a resolution photo to complete this ticket.'**
  String get uploadResolutionPhotoRequired;

  /// No description provided for @statusUpdatedCitizenNotified.
  ///
  /// In en, this message translates to:
  /// **'Status updated and citizen notified!'**
  String get statusUpdatedCitizenNotified;

  /// No description provided for @sendUpdate.
  ///
  /// In en, this message translates to:
  /// **'Send Update'**
  String get sendUpdate;

  /// No description provided for @messageToCitizen.
  ///
  /// In en, this message translates to:
  /// **'MESSAGE TO CITIZEN'**
  String get messageToCitizen;

  /// No description provided for @describeActionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the action taken or progress update...'**
  String get describeActionHint;

  /// No description provided for @resolutionSection.
  ///
  /// In en, this message translates to:
  /// **'RESOLUTION SECTION'**
  String get resolutionSection;

  /// No description provided for @photoSelected.
  ///
  /// In en, this message translates to:
  /// **'Photo Selected'**
  String get photoSelected;

  /// No description provided for @uploadResolutionPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Resolution Photo'**
  String get uploadResolutionPhoto;

  /// No description provided for @mandatoryForCompletion.
  ///
  /// In en, this message translates to:
  /// **'Mandatory for ticket completion'**
  String get mandatoryForCompletion;

  /// No description provided for @ticketUpdate.
  ///
  /// In en, this message translates to:
  /// **'Ticket Update'**
  String get ticketUpdate;

  /// No description provided for @proofOfResolution.
  ///
  /// In en, this message translates to:
  /// **'Proof of Resolution'**
  String get proofOfResolution;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @errorNoTicketId.
  ///
  /// In en, this message translates to:
  /// **'Error: No Ticket ID provided'**
  String get errorNoTicketId;

  /// No description provided for @citizenPrefix.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizenPrefix;

  /// No description provided for @ticketLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketLabel;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation...'**
  String get startConversation;

  /// No description provided for @typeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// No description provided for @issueDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Details'**
  String get issueDetailsTitle;

  /// No description provided for @reportNotFound.
  ///
  /// In en, this message translates to:
  /// **'Report not found.'**
  String get reportNotFound;

  /// No description provided for @deleteReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReportTitle;

  /// No description provided for @deleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report? This action cannot be undone.'**
  String get deleteReportConfirm;

  /// No description provided for @reportDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report deleted successfully.'**
  String get reportDeletedSuccess;

  /// No description provided for @messageDistrictOfficial.
  ///
  /// In en, this message translates to:
  /// **'Message District Official'**
  String get messageDistrictOfficial;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @addCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHint;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment!'**
  String get noCommentsYet;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get submittedOn;

  /// No description provided for @voiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get voiceNote;

  /// No description provided for @reportProgress.
  ///
  /// In en, this message translates to:
  /// **'Report Progress'**
  String get reportProgress;

  /// No description provided for @confirmedByDistrict.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by District'**
  String get confirmedByDistrict;

  /// No description provided for @awaitingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get awaitingConfirmation;

  /// No description provided for @fieldTeamDispatched.
  ///
  /// In en, this message translates to:
  /// **'Field team dispatched'**
  String get fieldTeamDispatched;

  /// No description provided for @teamOnSite.
  ///
  /// In en, this message translates to:
  /// **'Team on location'**
  String get teamOnSite;

  /// No description provided for @issueClosed.
  ///
  /// In en, this message translates to:
  /// **'Issue closed'**
  String get issueClosed;

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get editReport;

  /// No description provided for @step1Of2.
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 2'**
  String get step1Of2;

  /// No description provided for @step2Of2.
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 2'**
  String get step2Of2;

  /// No description provided for @captureEvidence.
  ///
  /// In en, this message translates to:
  /// **'Capture Evidence'**
  String get captureEvidence;

  /// No description provided for @incidentDetails.
  ///
  /// In en, this message translates to:
  /// **'Incident Details'**
  String get incidentDetails;

  /// No description provided for @createReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Report'**
  String get createReportTitle;

  /// No description provided for @issueTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Title'**
  String get issueTitle;

  /// No description provided for @issueTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Broken pipe on KG 11 Ave'**
  String get issueTitleHint;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get shortDescription;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe the issue (e.g. Broken streetlight on KG 201 St)...'**
  String get descriptionHint;

  /// No description provided for @addSupportingMedia.
  ///
  /// In en, this message translates to:
  /// **'Add supporting media'**
  String get addSupportingMedia;

  /// No description provided for @supportingMediaHelp.
  ///
  /// In en, this message translates to:
  /// **'DistrictDirect uses media to ensure transparency and faster resolution. Attach photos or record a voice memo.'**
  String get supportingMediaHelp;

  /// No description provided for @tapToChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to Change Photo'**
  String get tapToChangePhoto;

  /// No description provided for @takePhotoOrVideo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo or Video'**
  String get takePhotoOrVideo;

  /// No description provided for @highQualityPreferred.
  ///
  /// In en, this message translates to:
  /// **'High quality preferred'**
  String get highQualityPreferred;

  /// No description provided for @voiceMemoSaved.
  ///
  /// In en, this message translates to:
  /// **'Voice Memo Saved'**
  String get voiceMemoSaved;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get readyToPlay;

  /// No description provided for @limit5Minutes.
  ///
  /// In en, this message translates to:
  /// **'05:00 limit'**
  String get limit5Minutes;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @provideEvidencePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please capture a photo, audio, or write a description.'**
  String get provideEvidencePrompt;

  /// No description provided for @cameraOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open camera'**
  String get cameraOpenFailed;

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied.'**
  String get microphonePermissionDenied;

  /// No description provided for @incidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Incident Location'**
  String get incidentLocation;

  /// No description provided for @locationAcquired.
  ///
  /// In en, this message translates to:
  /// **'Location Acquired'**
  String get locationAcquired;

  /// No description provided for @getCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Get My Current Location'**
  String get getCurrentLocation;

  /// No description provided for @locationUseHelp.
  ///
  /// In en, this message translates to:
  /// **'Use this if you are currently at the place where the incident or issue is located.'**
  String get locationUseHelp;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orLabel;

  /// No description provided for @manualLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter street address or describe the exact location (e.g. near the high school, 500m after the first turn)...'**
  String get manualLocationHint;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get requiredLabel;

  /// No description provided for @incidentLocationDetails.
  ///
  /// In en, this message translates to:
  /// **'Incident Location Details'**
  String get incidentLocationDetails;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// No description provided for @selectTargetDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select Target District'**
  String get selectTargetDistrict;

  /// No description provided for @selectSector.
  ///
  /// In en, this message translates to:
  /// **'Select Sector'**
  String get selectSector;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get priorityLevel;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get medium;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get critical;

  /// No description provided for @priorityInfo.
  ///
  /// In en, this message translates to:
  /// **'\"Medium urgency reports are typically reviewed within 24-48 business hours.\"'**
  String get priorityInfo;

  /// No description provided for @reportAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Report Anonymously'**
  String get reportAnonymously;

  /// No description provided for @anonymousHelp.
  ///
  /// In en, this message translates to:
  /// **'Hide my identity from the public community feed.'**
  String get anonymousHelp;

  /// No description provided for @submitToDistrict.
  ///
  /// In en, this message translates to:
  /// **'Submit to District'**
  String get submitToDistrict;

  /// No description provided for @reportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Report updated!'**
  String get reportUpdated;

  /// No description provided for @incidentReportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Incident reported successfully!'**
  String get incidentReportedSuccess;

  /// No description provided for @failedToSubmit.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit'**
  String get failedToSubmit;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get locationPermissionsDenied;

  /// No description provided for @locationPermissionsDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermissionsDeniedForever;

  /// No description provided for @locationAcquiredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location acquired successfully!'**
  String get locationAcquiredSuccess;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get locationError;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in. Please sign in again.'**
  String get userNotLoggedIn;

  /// No description provided for @selectDistrictSectorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a Target District and Sector.'**
  String get selectDistrictSectorPrompt;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordPrompt;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox (and spam).'**
  String get passwordResetEmailSent;

  /// No description provided for @failedToSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send email'**
  String get failedToSendEmail;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @officialGovernmentPortal.
  ///
  /// In en, this message translates to:
  /// **'Official Government Portal'**
  String get officialGovernmentPortal;

  /// No description provided for @empoweringCommunities.
  ///
  /// In en, this message translates to:
  /// **'Empowering Communities'**
  String get empoweringCommunities;

  /// No description provided for @welcomeDistrictDirect.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DistrictDirect'**
  String get welcomeDistrictDirect;

  /// No description provided for @accessServicesInstantly.
  ///
  /// In en, this message translates to:
  /// **'Access local services and report issues instantly'**
  String get accessServicesInstantly;

  /// No description provided for @officialGovFooter.
  ///
  /// In en, this message translates to:
  /// **'Official Government of the Republic of Rwanda\n© 2026 Government Service Portal'**
  String get officialGovFooter;

  /// No description provided for @zeroTripGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Zero-Trip Guarantee'**
  String get zeroTripGuarantee;

  /// No description provided for @zeroTripDescription.
  ///
  /// In en, this message translates to:
  /// **'Save time. No more traveling to the office.'**
  String get zeroTripDescription;

  /// No description provided for @helloMuraho.
  ///
  /// In en, this message translates to:
  /// **'Hello! Muraho!'**
  String get helloMuraho;

  /// No description provided for @accessDistrictServicesDirectly.
  ///
  /// In en, this message translates to:
  /// **'Access your district services directly'**
  String get accessDistrictServicesDirectly;

  /// No description provided for @joinThousandsDaily.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of citizens saving time daily.'**
  String get joinThousandsDaily;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @privacyShield.
  ///
  /// In en, this message translates to:
  /// **'Privacy Shield: Your data is protected'**
  String get privacyShield;

  /// No description provided for @districtDirectFooter.
  ///
  /// In en, this message translates to:
  /// **'DISTRICTDIRECT RWANDA\n© 2026 Government Service Portal'**
  String get districtDirectFooter;

  /// No description provided for @assignedDistrict.
  ///
  /// In en, this message translates to:
  /// **'Assigned District'**
  String get assignedDistrict;

  /// No description provided for @selectYourDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select your district'**
  String get selectYourDistrict;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get optional;

  /// No description provided for @enterNidHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your 16-digit NID'**
  String get enterNidHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'78 XXX XXXX'**
  String get phoneHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @accountCreatedVerify.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please check your spam folder for the link to verify your sign up.'**
  String get accountCreatedVerify;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'rw': return AppLocalizationsRw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
