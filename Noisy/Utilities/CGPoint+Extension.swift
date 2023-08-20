//
//  CGPoint+Extension.swift
//  Noisy
//
//  Created by Davor Lakus on 21.08.2023..
//

import Foundation

extension CGPoint {
    static func * (_ lhs: CGPoint, _ rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func + (_ lhs: CGPoint, _ rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    func round() -> CGPoint {
        return CGPoint(x: self.x.roundToPlaces(places: 2), y: self.y.roundToPlaces(places: 2))
    }
}

extension CGFloat {
    func roundToPlaces(places:Int) -> Double {
            let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        }
}

extension Double {
    func roundToPlaces(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(2))
        return (self * divisor).rounded() / divisor
    }
}
