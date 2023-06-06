//
//  String+Localization.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

extension String {
    static let empty = ""
    static let cancel = "Cancel"
    static let close = "Close"
    static let noData = "N/A"

    struct Login {
        static let user = "User"
        static let title = "noisy"
        static let subtitle = "Sign in with your Spotify account to continue"
        static let email = "Email"
        static let roles = "Roles"
        static let id = "ID"
        static let textfieldPlaceholder = "Enter here"
        static let loginButtonTitle = "Sign in"
        static let footer = "Davor Lakuš, 2023 ©"
        static let emptyEmailError = "Please enter your email address."
        static let incorrectEmailError = "Incorrect email. Please try again."
    }

    struct Tabs {
        static let home = "Home"
        static let discover = "Discover"
        static let search = "Search"
        static let liveMusic = "Live Music"
        static let radio = "Radio"
        static let settings = "Settings"
    }

    struct Home {
        static let techComp = "Technical Competencies"
        static let nonTechComp = "Non-Technical Competencies"
        static let lang = "Languages we speak"
        static let engineers = "Software Engineers"
        static let designers = "Designers"
        static let delManagers = "Delivery Managers"
        static let businessDevs = "Business Developers"
        static let marketing = "Marketing Experts"
        static let people = "People & Culture Specialists"
        static let businessSupport = "Business Support"
        static let finance = "Finance Managers"
        static let notifications = "Notifications"
        static let emptyTitle = "There's nothing here yet."
        static let emptyDescription = "You don't have any notifications."
        static let unknown = "Unknown user"
        static let request = "requested a review."
        static let approve = "approved your review request."
        static let reject = "rejected your review request."
    }

    struct Employees {
        static let emptyStateTitle = "Sorry, no results found"
        static let emptyStateDescription = "Please check your spelling and try again. You can also try searching for a related name."
        static let selectDepartment = "Select department"
        static let sortBy = "Sort by"
        static let name = "Name"
        static let surname = "Surname"
        static let department = "Department"
        static let lead = "Lead"
    }

    struct MyTeam {
        static let remove = "Remove"
        static let teamMemberRemoveAlertMessage1 = "Do you want to remove"
        static let teamMemberRemoveAlertMessage2 = "from your Team? This action cannot be reversed."
        static let noteRemoveAlertMessage = "Do you want to remove this note? This action cannot be reversed."
        static let newlyAdded = "NEWLY ADDED"
        static let team = "'s Team"
        static let memberRemoveErrorTitle = "Unable to remove team member"
        static let memberRemoveErrorDescription = "Sorry, we couldn't remove your team member at this time."
    }

    struct Organization {
        static let title = "Organizational Tree"
    }
    
    struct ProfileTabs {
        static let main = "Main Info"
        static let competencies = "Competencies"
    }
    
    struct Profile {
        static let myProfile = "My Profile"
        static let signOutTitle = "Sign out"
        static let signOutMessage = "Are you sure you want to sign out?"
        static let viewNotes = "Notes"
        static let viewGrowthCheck = "Growth Check"
        static let department = "DEPARTMENT"
        static let lead = "LEAD"
        static let role = "ROLE"
        static let companyWorkTime = "COMPANY WORK TIME"
        static let industryWorkTime = "INDUSTRY WORK TIME"
        static let noData = "No data entered for this user"
        static let technicalCompetencies = "Technical Competencies"
        static let nonTechnicalCompetencies = "Non-Technical Competencies"
        static let languages = "Languages"
        static let experience = "Experience"
        static let interest = "Interest"
        static let demoExperience = "I know it so well that I could share my knowledge with others"
        static let demoInterest = "I want to keep using it and learn new things"
        static let profile = "Employee Profile"
    }
    
    struct Notes {
        static let title = "Notes"
        static let emptyStateTitle = "There’s nothing here yet"
        static let emptyStateDescription = "There are no notes for this team member. Tap on the plus icon in the top right corner of the screen to start adding notes."
        static let noteRemoveErrorTitle = "Unable to delete note"
        static let noteRemoveErrorDescription = "Sorry, we couldn't delete your note at this time."
        static let untitled = "Untitled"
        static let bottomID = "scrollBottom"
        static let textPlaceholder = "Tap here to start writing..."
        static let bulletTab = "•   "
        static let placeholderNumbering = "1.   "
        static let numberedListRegexPattern = #"\d+.\s{3}"#
    }

    struct GrowthCheck {
        static let title = "Growth Check"
        static let compare = "Compare last 3 years"
        static let firstHalfYear = "0 - 6 months"
        static let secondHalfYear = "6 - 12 months"
        static let experience = "Experience"
        static let competency = "Competency"
        static let interest = "Interest"
        static let nonTech = "Non-Tech Comp."
        static let prior = "prior"
        static let previous = "previous"
        static let current = "current"
        static let comparison = "comparison"
        static let growthDetails = "growth details"
    }
    
    struct Dictionary {
        static let searchBarPlaceholder = "Search"
        static let emptyStateTitle = "Sorry, no results found"
        static let emptyStateDescription = "Please check your spelling or try a different search term."
    }
    
    struct Utilities {
        static let defaultLocale = "en_US"
        static let backendDateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        static let frontendDateFormat = "MMM yyyy"
    }
    
    struct Mock {
        static let mockDate = "2020-10-21T20:01:11Z"
    }
}
