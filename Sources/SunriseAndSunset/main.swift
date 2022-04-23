import CoreLocation

let date = Date()

var location = CLLocation(latitude: 55.75316530316796, longitude: 48.743053486993084)

location = CLLocation(latitude: 30.04401300690781, longitude: 31.224810839949903)

let officialZenithSunrise = date.sunset(location)
let astronomicalZenithSunrise = date.sunset(location, zenith: .astronomical)
let civilZenithSunrise = date.sunset(location, zenith: .civil)

let nauticalZenithSunrise = date.sunset(location, zenith: .nautical)

let officialZenithSunset = date.sunset(location)

// Create Date Formatter
let dateFormatter = DateFormatter()
dateFormatter.timeStyle = .short

print(dateFormatter.string(from: officialZenithSunrise!))
print(dateFormatter.string(from: astronomicalZenithSunrise!))
print(dateFormatter.string(from: civilZenithSunrise!))
print(dateFormatter.string(from: nauticalZenithSunrise!))

print(dateFormatter.string(from: officialZenithSunset!))
