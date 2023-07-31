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
    
    struct UserDefaults {
        static let code = "code"
        static let codeVerifier = "code_verifier"
        static let refreshToken = "refresh_token"
        static let accessToken = "access_token"
        static let queueState = "queue_state"
    }
    
    struct Track {
        static let name = "Name: "
        static let artist = "Artist: "
    }

    struct Login {
        static let profile = "Profile"
        static let title = "noisy"
        static let subtitle = "Sign in with your Spotify account to continue"
        static let email = "Email"
        static let id = "ID"
        static let textfieldPlaceholder = "Enter here"
        static let loginButtonTitle = "Sign in"
        static let footer = "Davor Lakuš, 2023 ©"
        static let emptyEmailError = "Please enter your email address."
        static let incorrectEmailError = "Incorrect email. Please try again."
    }
    
    struct Player {
        static let queue = "Queue"
        static let currentQueue = "Current Queue"
    }

    struct Tabs {
        static let home = "Home"
        static let discover = "Discover"
        static let search = "Search"
        static let liveMusic = "Live Music"
        static let radio = "Radio"
        static let settings = "Settings"
    }
    
    struct Shared {
        static let artists = "artists"
        static let tracks = "tracks"
        static let genres = "genres"
        static let done = "Done"
        static let addToQueue = "Add to queue"
        static let addedToQueue = "added to queue."
        static let remove = "Remove"
    }
    
    struct Profile {
        static let viewProfile = "View profile"
        static let general = "General"
        static let about = "About"
        static let signoutTitle = "Sign out"
        static let signoutMessage = "Are you sure you want to sign out?"
    }

    struct Home {
        static let welcome = "Welcome"
        static let pickerTitle = "In:"
        static let sliderCount = "Count:"
        static let topTracks = "Your top tracks"
        static let topArtists = "Your top artists"
        static let playlists = "Your playlists"
        static let total = "Total:"
    }
    
    struct Discover {
        static let manageSeeds = "Set Seeds"
        static let changeSeedParameters = "Change Seed parameters"
        static let seedsTitle = "Artist, Track, and Genre seeds"
        static let seedsSubtitle = "Up to 5 items"
        static let currentSeedSelection = "Current seed selection:"
        static let pleaseSelectSomeDiscoverySeeds = "Select some discovery seeds to get started"
        static let discover = "Discover"
        static let includeAllSeeds = "Include all parameter seeds"
        static let removeAllSeeds = "Remove all parameter seeds"
        static let min = "min"
        static let max = "max"
        static let targetShort = "target"
        static let lowerBound = "Min: "
        static let target = "Target: "
        static let upperBound = "Max: "
    }
    
    struct Search {
        static let tapToStart = "Tap the bar above to start"
        static let searchOptions = "Search options"
        static let filters = "Filters"
        static let sortBy = "Sort by"
        static let tracks = "Tracks"
        static let artists = "Artists"
        static let albums = "Albums"
        static let playlists = "Playlists"
        static let genres = "Genres"
        static let allGenres = "All genres"
    }

    struct Artist {
        static let mostPlayed = "'s most played"
        static let albums = "Albums"
        static let related = "Related"
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
