//
//  NoisyDateFormatter.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Foundation

final class NoisyDateFormatter {
    static func formatDateToString(_ unformattedString: String? = nil, format: String = .Utilities.frontendDateFormat) -> String {
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: .Utilities.defaultLocale)
        dateFormatter.locale = locale
            
        guard let unformattedString else {
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: .now)
        }
        
        dateFormatter.dateFormat = .Utilities.backendDateFormat
        
        guard let date = dateFormatter.date(from: unformattedString)
        else { return .noData }
        
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func durationToNow(dateString: String?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = .Utilities.backendDateFormat
        dateFormatter.locale = Locale(identifier: .Utilities.defaultLocale)

        guard let dateString,
            let date = dateFormatter.date(from: dateString)
        else { return nil }
        
        return date.timeAgoDisplay()
    }

    static func formatStringToDate(_ unformattedString: String) -> Date? {
        let dateFormatter = DateFormatter()
        let locale = Locale(identifier: .Utilities.defaultLocale)

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSZ"
        dateFormatter.locale = locale
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        guard let date = dateFormatter.date(from: unformattedString) else { return nil }
        return date
    }

    static func getDateComponent(_ date: Date?, _ component: Set<Calendar.Component>) -> Int? {
        let calendar = Calendar.current
        let dateComponent = calendar.dateComponents(component, from: date ?? Date())

        if component == [.month] {
            return dateComponent.month
        } else {
            return dateComponent.year
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "en_UK")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
