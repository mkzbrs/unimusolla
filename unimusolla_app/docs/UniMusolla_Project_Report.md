# UniMusolla Project Report

## Cover Page

**Project Title:** UniMusolla - Campus Musolla Discovery and Reporting Mobile Application  
**Course:** STTPK2143 Application Development  
**Assessment:** Final Project - Full-Stack Mobile Application Development using Flutter, PHP, and SQLite  
**Student Name:** ______________________________  
**Matric Number:** ______________________________  
**Lecturer:** ______________________________  
**Submission Date:** ______________________________  

## 1. Introduction

UniMusolla is a full-stack mobile application designed to help university students find available musolla locations on campus and report new or updated musolla information. The application supports two main user roles: normal users and administrators.

Normal users can register, log in, browse approved musolla locations, view detailed musolla information, search musollas, submit new musolla reports, submit update reports for existing musollas, upload images, view their report history, edit pending reports, delete reports, and manage their profile. Administrators can view dashboard statistics, review pending reports, approve or reject reports, manage users, manage approved musollas, and view admin activity logs.

The mobile frontend is developed using Flutter. The app communicates with a PHP API through HTTP requests using the Dio package. Data is retrieved from and saved to the backend through JSON API responses. The assignment requires SQLite as the database layer; in this workspace, the Flutter app connects to the hosted API at `https://unimusolla-api.mkzbrs.com`, but the PHP API folder and SQLite database file are not included locally.

## 2. Problem Statement

Students often need a quick way to locate prayer spaces around campus, but musolla information may be scattered, outdated, or unavailable in a single mobile-friendly system. Without a structured reporting workflow, changes such as availability status, exact location, facilities, or photos may not be reviewed before being published.

UniMusolla solves this problem by providing a centralized mobile application where students can browse verified musolla information and contribute updates through reports. Administrators review reports before approving them, which helps maintain data quality while still allowing the community to contribute.

## 3. System Objectives

1. To provide a mobile app for students to view approved musolla locations on campus.
2. To allow users to submit new musolla reports and updates for existing musollas.
3. To allow users to upload musolla/report images.
4. To allow users to view, edit, and delete their own pending reports.
5. To provide an administrator dashboard for reviewing reports and managing users and musollas.
6. To connect the Flutter frontend to a PHP API using HTTP requests and JSON responses.
7. To support real CRUD operations through backend API endpoints.

## 4. Target Users

The target users are:

- **Students:** Browse musollas, search locations, submit new musolla reports, submit update reports, view report status, and manage profile information.
- **Administrators:** Review user-submitted reports, approve or reject reports, monitor system statistics, manage users, manage approved musollas, and review admin logs.

## 5. System Scope

The project scope is suitable for the assignment because it is not an inventory management system and it solves a clear campus daily-use problem. It is more specific than a general campus directory, but complete enough to demonstrate authentication, multiple screens, forms, media upload, HTTP communication, CRUD operations, role-based navigation, and admin workflows.

## 6. System Features

### 6.1 Authentication

- User login using email and password.
- User registration using username, email, and password.
- Session restoration using local storage.
- Role-based redirect after login:
  - Admin users go to the admin dashboard.
  - Normal users go to the user home screen.
- Logout from profile/admin dashboard.

Relevant files:

- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`
- `lib/features/auth/splash_screen.dart`
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`

### 6.2 User Musolla Browsing

- View approved musollas.
- Search and filter musollas.
- View musolla detail page.
- View musolla images, location, availability, facilities, and map preview.
- Submit update report for an existing musolla.

Relevant files:

- `lib/features/home/user_home_screen.dart`
- `lib/features/musolla/musolla_list_screen.dart`
- `lib/features/musolla/search_screen.dart`
- `lib/features/musolla/musolla_detail_screen.dart`
- `lib/services/musolla_service.dart`

### 6.3 Report Management

- Submit a new musolla report.
- Submit an update report for an existing musolla.
- Upload report images.
- View own reports.
- View report detail.
- Edit pending reports.
- Delete reports.
- View report status: pending, approved, or rejected.

Relevant files:

- `lib/features/reports/report_form.dart`
- `lib/features/reports/my_reports_screen.dart`
- `lib/features/reports/report_detail_screen.dart`
- `lib/services/report_service.dart`
- `lib/providers/report_provider.dart`

### 6.4 Profile Management

- View user profile.
- Edit username.
- Upload profile image.
- Logout.

Relevant files:

- `lib/features/profile/profile_screen.dart`
- `lib/features/profile/edit_profile_screen.dart`
- `lib/services/profile_service.dart`
- `lib/providers/profile_provider.dart`

### 6.5 Admin Dashboard and Management

- View dashboard statistics.
- View pending, approved, and rejected reports.
- Approve reports.
- Reject reports.
- View report details.
- Manage users.
- Update user details.
- Delete users.
- View live musollas.
- Delete musollas.
- View admin logs.

Relevant files:

- `lib/features/admin/admin_dashboard_screen.dart`
- `lib/features/admin/pending_reports_screen.dart`
- `lib/features/admin/admin_management_screen.dart`
- `lib/services/admin_service.dart`
- `lib/providers/admin_provider.dart`

## 7. Application Screens

The assignment requires at least 4 functional screens. UniMusolla exceeds this requirement.

| Screen | Purpose | Requirement Coverage |
|---|---|---|
| Splash Screen | Restores session and redirects user | Navigation/session flow |
| Login Screen | User/admin login | Login form, validation |
| Register Screen | New user registration | Registration form, validation |
| User Home Screen | Main user navigation | Dashboard/home |
| Musolla List Screen | Displays approved musollas | List/read data |
| Search Screen | Searches musolla records | Search/read data |
| Musolla Detail Screen | Shows musolla details, map, images, facilities | Detail screen |
| Report Form Screen | Add/edit reports and upload images | Add/edit form |
| My Reports Screen | Shows user report history | History/list screen |
| Report Detail Screen | Shows submitted report details and photos | Detail screen |
| Profile Screen | Shows and edits profile | Profile screen |
| Admin Dashboard Screen | Admin statistics, reports, users, musollas, logs | Admin dashboard |
| Pending Reports Screen | Admin report review | Admin workflow |
| Admin Management Screen | Manage users, musollas, and logs | Admin CRUD |

## 8. Flutter Frontend Requirement Analysis

| Assignment Requirement | Evidence in UniMusolla | Status |
|---|---|---|
| At least 4 functional screens | More than 10 screens are implemented, including login, register, home, list, detail, form, profile, reports, and admin screens. | Met |
| Scaffold | Used across screens such as login, admin dashboard, report form, musolla detail, profile. | Met |
| AppBar | Used in admin dashboard, musolla detail, report form, profile, pending reports. | Met |
| Column and Row | Used throughout forms, dashboards, cards, and detail layouts. | Met |
| ListView | Used in dashboards, forms, musolla lists, reports, and profile sections. | Met |
| Card/card-like UI | Musolla cards, report cards, admin cards, dashboard statistic cards. | Met |
| TextField/TextFormField | Login, register, report form, profile edit, admin user edit. | Met |
| Button widgets | FilledButton, TextButton, IconButton, FloatingActionButton. | Met |
| DropdownButton | Report form uses `DropdownButtonFormField` for availability status. | Met |
| Dialog or Snackbar | Confirmation dialogs and `showAppMessage` snackbar helper are used. | Met |
| Input forms with validation | Login, register, report form, profile/admin edit forms. | Met |
| Navigation between screens | Implemented using `go_router`. | Met |
| HTTP connection to PHP API | Implemented through `ApiClient` using Dio HTTP requests to PHP endpoints. | Met |
| Display data retrieved from backend | Musollas, reports, users, admin logs, dashboard stats, and profile data are displayed from API responses. | Met |
| Add records | Register, create report, upload image, profile update. | Met |
| View/read records | Musolla list/detail, report list/detail, user list, logs, profile. | Met |
| Update records | Edit pending report, update profile, admin update user, approve/reject report. | Met |
| Delete records | Delete report, admin delete user, admin delete musolla. | Met |
| Basic responsive design | Admin dashboard switches side navigation/bottom navigation based on screen width; lists/grids use adaptive columns. | Met |

## 9. PHP Backend Requirement Analysis

The Flutter app communicates with a hosted PHP API at:

`https://unimusolla-api.mkzbrs.com`

The local workspace analyzed for this report does not include the PHP API source folder. Therefore, backend implementation details such as folder structure, PHP validation code, and SQLite connection code cannot be directly inspected locally. However, the Flutter app clearly uses PHP endpoint paths and expects JSON responses from the backend.

| Assignment Requirement | Evidence in UniMusolla | Status |
|---|---|---|
| PHP API files in proper API structure | Flutter calls organized endpoint groups such as `/auth`, `/reports`, `/musollas`, `/admin`, `/profile`, and `/uploads`. Source files are not included locally. | Partially evidenced |
| API endpoints for CRUD operations | Auth, reports, musollas, admin users, admin reports, profile, and uploads endpoints are used. | Met from client integration |
| SQLite database connection | Required by assignment, but SQLite database file/source connection code is not included in this workspace. | Not locally evidenced |
| JSON response format | App decodes JSON and unwraps `success`, `message`, `data`, `reports`, `musollas`, `users`, and `logs`. | Met from client integration |
| Proper handling of HTTP requests | App sends GET, POST JSON, and multipart upload requests. | Met from client integration |
| Basic backend validation | Not directly visible because backend source is not included. The app handles error messages returned from API. | Not locally evidenced |
| Clear response messages | App reads API messages/errors through `ApiClient._messageFrom`. | Partially evidenced |

## 10. SQLite Database Requirement Analysis

The assignment requires at least 2 related SQLite tables, proper primary keys, suitable fields, and sample data. The local workspace does not include a `.db`, `.sqlite`, or `.sql` file, so the actual SQLite design cannot be directly verified.

Based on the Flutter models and API payloads, the expected database design is:

### 10.1 Expected `users` Table

| Field | Suggested Type | Description |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | User ID |
| username | TEXT NOT NULL | User display name |
| email | TEXT NOT NULL UNIQUE | Login email |
| password | TEXT NOT NULL | Hashed password |
| role | TEXT NOT NULL | `user` or `admin` |
| profile_image | TEXT | Profile image filename |
| created_at | TEXT | Created timestamp |

### 10.2 Expected `musollas` Table

| Field | Suggested Type | Description |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Musolla ID |
| name | TEXT NOT NULL | Musolla name |
| location | TEXT NOT NULL | General location |
| exact_location | TEXT | Exact location description |
| latitude | REAL | Map latitude |
| longitude | REAL | Map longitude |
| status | TEXT | `available` or `unavailable` |
| has_wudhu | INTEGER | Facility flag |
| has_toilet | INTEGER | Facility flag |
| has_aircond | INTEGER | Facility flag |
| has_mats | INTEGER | Facility flag |
| has_telekung | INTEGER | Facility flag |
| thumbnail | TEXT | Main image filename |
| created_at | TEXT | Created timestamp |

### 10.3 Expected `reports` Table

| Field | Suggested Type | Description |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Report ID |
| user_id | INTEGER | Related user |
| musolla_id | INTEGER | Related musolla for update reports |
| name | TEXT NOT NULL | Submitted musolla name |
| location | TEXT NOT NULL | Submitted location |
| exact_location | TEXT | Submitted exact location |
| latitude | REAL | Submitted latitude |
| longitude | REAL | Submitted longitude |
| status | TEXT | Musolla availability status |
| approval_status | TEXT | `pending`, `approved`, `rejected` |
| admin_review | TEXT | Admin comment/review |
| has_wudhu | INTEGER | Facility flag |
| has_toilet | INTEGER | Facility flag |
| has_aircond | INTEGER | Facility flag |
| has_mats | INTEGER | Facility flag |
| has_telekung | INTEGER | Facility flag |
| created_at | TEXT | Created timestamp |

### 10.4 Expected `report_images` Table

| Field | Suggested Type | Description |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Image ID |
| report_id | INTEGER | Related report |
| image_path | TEXT NOT NULL | Uploaded report image filename/path |
| created_at | TEXT | Created timestamp |

### 10.5 Expected `admin_logs` Table

| Field | Suggested Type | Description |
|---|---|---|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Log ID |
| admin_id | INTEGER | Admin user ID |
| action | TEXT NOT NULL | Admin action |
| target_type | TEXT | User/report/musolla/etc. |
| target_id | INTEGER | Affected record |
| created_at | TEXT | Log timestamp |

## 11. API Endpoint List

The following endpoints are used by the Flutter app.

| Endpoint | Method | Purpose |
|---|---|---|
| `/auth/login.php` | POST JSON | Login user/admin |
| `/auth/register.php` | POST JSON | Register new user |
| `/profile/me.php` | GET | Get profile by user ID |
| `/profile/update.php` | POST JSON | Update profile username |
| `/uploads/profile.php` | POST multipart | Upload profile image |
| `/musollas/list.php` | GET | Get approved musolla list |
| `/musollas/search.php` | GET | Search musollas |
| `/musollas/detail.php` | GET | Get musolla detail |
| `/reports/list.php` | GET | Get current user's reports |
| `/reports/detail.php` | GET | Get report detail |
| `/reports/create.php` | POST JSON | Create new report |
| `/reports/update.php` | POST JSON | Update pending report |
| `/reports/delete.php` | POST JSON | Delete report |
| `/uploads/report.php` | POST multipart | Upload report images |
| `/admin/dashboard.php` | GET | Get dashboard statistics |
| `/admin/reports.php` | GET | Get reports by approval status |
| `/admin/report_detail.php` | GET | Get admin report detail |
| `/admin/approve.php` | POST JSON | Approve report |
| `/admin/reject.php` | POST JSON | Reject report |
| `/admin/users.php` | GET | Get user list |
| `/admin/user_detail.php` | GET | Get user detail |
| `/admin/update_user.php` | POST JSON | Update user |
| `/admin/delete_user.php` | POST JSON | Delete user |
| `/admin/delete_musolla.php` | POST JSON | Delete approved musolla |
| `/admin/logs.php` | GET | Get admin activity logs |

## 12. CRUD Operation Mapping

| CRUD Operation | User Feature | Admin Feature | Evidence |
|---|---|---|---|
| Create | Register account, create report, upload images | Approving a report creates/updates approved musolla data | `AuthService`, `ReportService`, `AdminService` |
| Read | View musollas, report history, report detail, profile | View dashboard, reports, users, musollas, logs | `MusollaService`, `ReportService`, `ProfileService`, `AdminService` |
| Update | Edit pending report, edit profile | Approve/reject reports, update users | `ReportService.update`, `ProfileService.update`, `AdminService.updateUser` |
| Delete | Delete own report | Delete user, delete musolla | `ReportService.delete`, `AdminService.deleteUser`, `AdminService.deleteMusolla` |

## 13. Testing Evidence

Testing evidence should include screenshots and/or a short screen recording. The following test cases can be demonstrated:

| Test Case | Steps | Expected Result | Status |
|---|---|---|---|
| Register user | Open register screen, enter username, email, password, submit | Account is created and user returns to login | To demonstrate |
| Login user | Enter valid email/password | User navigates to `/home` | To demonstrate |
| Invalid login | Enter wrong credentials | Email/password fields show invalid messages | Implemented |
| View musollas | Login as user and open home musolla list | Approved musollas are displayed | Implemented |
| View musolla detail | Tap a musolla card | Detail page shows location, facilities, map, and image area | Implemented |
| Submit new report | Open report form, fill details, choose image, submit | Report is created and appears in report history | Implemented |
| Edit pending report | Open pending report detail and edit | Report details are updated | Implemented |
| Delete report | Delete own report | Report is removed from history | Implemented |
| Admin login | Login with admin credentials | Admin dashboard is displayed | Implemented |
| Review pending report | Admin opens report detail | Report details and uploaded images are shown if returned by API | Implemented |
| Approve report | Admin approves report | Report becomes approved and musolla appears in live musolla list | Implemented |
| Reject report | Admin rejects report | Report status becomes rejected | Implemented |
| Manage users | Admin opens user management | Users can be viewed, updated, and deleted | Implemented |
| Manage musollas | Admin opens live musollas | Approved musollas can be viewed and deleted | Implemented |

Flutter static analysis result:

`flutter analyze` completed with `No issues found`.

## 14. Screenshots Section

Add screenshots to this section before exporting the final report to PDF.

Suggested screenshots:

1. Login screen.
2. Register screen.
3. User home/musolla list screen.
4. Musolla detail screen.
5. Report form screen with image upload.
6. My reports screen.
7. Report detail screen.
8. Profile screen.
9. Admin dashboard screen.
10. Admin pending report detail screen.
11. Admin users management screen.
12. Admin live musolla management screen.

## 15. Assignment Requirement Coverage Summary

### 15.1 Application Idea and Scope

| Criteria | Status | Notes |
|---|---|---|
| Suitable and realistic idea | Met | Campus musolla discovery and reporting is realistic for university use. |
| Solves clear problem | Met | Centralizes musolla information and update reporting. |
| Scope not too simple/complex | Met | Includes user and admin flows but remains focused on musolla reports. |
| Not inventory management | Met | Project is unrelated to inventory management. |

### 15.2 Flutter UI Design and User Experience

| Criteria | Status | Notes |
|---|---|---|
| At least 4 functional screens | Met | App has more than 10 screens. |
| Neat, readable, consistent layout | Met | Consistent Material design, cards, forms, and navigation. |
| Uses required widgets | Met | Scaffold, AppBar, ListView, Card, TextField, buttons, dropdown, dialog/snackbar. |
| Good navigation flow | Met | Uses `go_router` with role-based redirects. |
| Clear input forms | Met | Login, register, report, profile, and admin forms use validation. |
| Responsive design | Met | Adaptive admin navigation and grid layouts. |
| Suitable visual design | Met | Mosque/musolla theme, clean campus utility interface. |

### 15.3 Flutter Development and Functionality

| Criteria | Status | Notes |
|---|---|---|
| Connects to PHP API | Met | Uses Dio HTTP client with hosted PHP API. |
| Displays backend data | Met | Musollas, reports, profile, users, logs, stats. |
| Add/create works | Met | Register and report creation. |
| View/read works | Met | List/detail views for musollas and reports. |
| Update/edit works | Met | Edit report, profile, users, approve/reject. |
| Delete/cancel works | Met | Delete reports, users, musollas. |

### 15.4 PHP Backend Development

| Criteria | Status | Notes |
|---|---|---|
| Organized PHP API folder | Partially evidenced | Endpoint paths are organized, but source folder is not in local workspace. |
| SQLite connection | Not locally evidenced | Database connection code is not included locally. |
| JSON responses | Met from integration | Flutter parses JSON responses successfully. |
| Complete CRUD operations | Met from integration | Client uses CRUD endpoints. |
| Backend validation/error handling | Partially evidenced | Flutter receives and displays API errors, but backend code is unavailable locally. |
| Useful response messages | Partially evidenced | Client supports `message`, `error`, and `detail` response keys. |

### 15.5 SQLite Database Design

| Criteria | Status | Notes |
|---|---|---|
| At least 2 related tables | Not locally evidenced | Expected tables are users, musollas, reports, report_images, admin_logs. |
| Suitable fields and primary keys | Not locally evidenced | Inferred from models/API only. |
| Structure matches app requirements | Partially evidenced | Flutter models match expected relational structure. |
| Sample data provided | Not locally evidenced | Hosted API contains sample data, but local database file is missing. |

### 15.6 Testing, Demonstration, and Documentation

| Criteria | Status | Notes |
|---|---|---|
| Demonstrates major functions | Ready | Demo can show user and admin workflows. |
| Report includes screenshots and flow | Needs screenshots | This document includes flow; screenshots must be inserted. |
| Includes database design and API list | Met | Included above. |
| Demo video/live demonstration | Needs recording | Must be provided separately. |
| Source code submitted properly | Partially ready | Flutter source is present; PHP API folder and SQLite DB should be added if required. |

## 16. Files to Submit

Based on the assignment deliverables, the final submission should include:

1. Flutter project folder: `unimusolla/unimusolla_app`
2. PHP API folder: should be included if available from the hosted backend project.
3. SQLite database file: should be included if available from the hosted backend project.
4. Project report exported as PDF.
5. Application screenshots.
6. Short screen recording or demo video.
7. GitHub link or zipped source code.

## 17. Important Notes Before Final Submission

The Flutter app satisfies the frontend and client-side integration requirements strongly. However, the assignment explicitly requires the PHP API folder and SQLite database file in the project submission. These files are not present in the analyzed workspace. To avoid losing marks under the backend and database rubric, add the backend source folder and SQLite database file to the submission package, or provide clear access to the backend repository if it is stored separately.

Also add real screenshots to Section 14 and export the final document as PDF.

## 18. Conclusion

UniMusolla is a suitable final project for a full-stack mobile application assignment. It addresses a realistic campus problem by helping students discover musollas and submit verified updates. The Flutter app includes authentication, role-based navigation, multiple screens, validated forms, image upload, responsive layouts, backend communication, and CRUD workflows for both users and administrators.

The application meets the majority of the Flutter frontend and functionality requirements. The backend and SQLite requirements are evidenced by the client API integration, but the PHP source files and SQLite database file should be included in the final submission to fully satisfy the assignment deliverables and marking rubric.
