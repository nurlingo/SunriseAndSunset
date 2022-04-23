//
//  NSDate+SunriseAndSunset.swift
//  Codiad
//
//  Created by Huw Rowlands on 26.1.2016.
//  Copyright © 2016 Huw Rowlands. All rights reserved.
//

import Foundation
import CoreLocation

private enum Event {
    case sunrise
    case sunset
}

private extension TimeZone {
    var hoursfromGMT: Double {
        return Double(self.secondsFromGMT()) / (60 * 60)
    }
}

func longitudinalHour(_ longitude: CLLocationDegrees) -> Double {
    return longitude / SOLAR_DEGREES_PER_HOUR
}

extension Date {
    fileprivate func timeOfEvent(_ event: Event, location: CLLocation, zenith: Zenith) -> Date? {
        let cal = Calendar.current
        
        //1.
        let dayOfYear = Double((cal as NSCalendar).ordinality(of: .day, in: .year, for: self))
        
        let sun = Sun(dayOfYear: dayOfYear)
        
        //2.
        let guess = (event == .sunrise) ? 6.0 : 18.0
        let approxT = ((guess - longitudinalHour(location.coordinate.longitude)) / 24.0) + dayOfYear
        
        //7a.
        let cosHour = sun.localHourAngleCosine(zenith, latitude: location.coordinate.latitude)
        
        guard (cosHour < 1) && (cosHour > -1) else {
            return nil
        }
        
        //7b
        let multiplier = (event == .sunrise) ? -1.0 : 1.0
        let hour = (acos(cosHour).degrees * multiplier) / 15
        
        //8
        let T = (hour + sun.rightAscension - (0.06571 * approxT) - 6.622)
        
        //9 -- coerce into UTC
        var UTC = (T - longitudinalHour(location.coordinate.longitude))
        if UTC < 0 {
            UTC += 24
        }
        
        //coerce into NSDate
        var dateComponents = cal.dateComponents([.day, .month, .year], from: self)
        dateComponents.hour   = Int(UTC)
        dateComponents.minute = Int((UTC * 60).truncatingRemainder(dividingBy: 60))
        dateComponents.second = Int((UTC * 3600).truncatingRemainder(dividingBy: 60))
        dateComponents.timeZone = TimeZone(identifier: "UTC")
        
        return cal.date(from: dateComponents)
    }
    
    func sunrise(_ location: CLLocation, zenith: Zenith) -> Date? {
        return timeOfEvent(.sunrise, location: location, zenith: .official)
    }
    
    func sunset(_ location: CLLocation, zenith: Zenith) -> Date? {
        return timeOfEvent(.sunset, location: location, zenith: .official)
    }
    
    func sunrise(_ location: CLLocation) -> Date? {
        return sunrise(location, zenith: .official)
    }
    
    func sunset(_ location: CLLocation) -> Date? {
        return sunset(location, zenith: .official)
    }
}
