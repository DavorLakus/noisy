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
        static let tokenExpirationDate = "expiration_date"
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
        static let ok = "OK"
        static let title = "Title"
        static let errorTitle = "Error"
        static let artists = "artists"
        static let tracks = "tracks"
        static let genres = "genres"
        static let done = "Done"
        static let addToQueue = "Add to queue"
        static let addToPlaylist = "Add to playlist"
        static let addTracksToPlaylists = "Add to playlists"
        static let addedToQueue = "added to queue."
        static let addedToPlaylist = "Tracks successfully added."
        static let addedToFavorites = "added to favorites"
        static let removedFromFavorites = "removed from favorites"
        static let remove = "Remove"
        static let playlist = "Playlist"
        static let yourPlaylists = "Your playlists"
        static let createNew = "Create new"
        static let playlistName = "Playlist name"
        static let createNewPlaylist = "Create new playlist"
        static let save = "Save"
        static let album = "Album"
        static let viewArtist = "View artist"
        static let viewAlbum = "View album"
        static let visualize = "Visualize"
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
        static let sliderCount = "Limit:"
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
        static let recommendations = "Recommendations"
        static let generateRandomSeeds = "Generate random seeds"
        static let initialResultsMessage = "Your recommendation results will appear here"
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
        static let searchBarPlaceholder = "Search"
        static let emptyStateTitle = "Sorry, no results found"
    }
    
    struct Visualize {
        static let visualize = "Visualize"
    }

    struct Artist {
        static let mostPlayed = "'s most played"
        static let albums = "Albums"
        static let related = "Related"
    }
    
    struct Queue {
        static let clearQueue = "Clear queue"
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
