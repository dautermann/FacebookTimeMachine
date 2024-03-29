//
//  DataSource.swift
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/24/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// FuelTank is a singleton, since we'll share it between at least two view controllers
// https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton
public class FuelTank {
    static let shared: FuelTank = FuelTank()
    
    private var startingLevel: Int = 0
    private(set) var currentLevel: Int = 0

    func refillTankWith(liters: Int) {
        startingLevel = liters
        currentLevel = liters
    }
    
    func deductCost(liters: Int) -> Bool {
        if liters > currentLevel {
            // we are out of dilithium / gas / fuel pellets / soylent green
            return false
        }
        currentLevel -= liters
        return true
    }
}

// I generated this beautiful Decodable thing via https://app.quicktype.io/#l=swift

// MARK: - PrizeWinner
struct PrizeWinner: Codable {
    let id: Int
    let category: Category
    let died, diedcity, borncity, born: String
    let surname, firstname, motivation: String
    let location: Location
    let city, borncountry, year, diedcountry: String
    let country: String
    let gender: Gender
    let name: String
    var cost: Int?

    func distanceFrom(coordinate: Location) -> Double {
        let coord1 = CLLocation(latitude: location.lat, longitude: location.lng)
        let coord2 = CLLocation(latitude: coordinate.lat, longitude: coordinate.lng)
        let distance = coord1.distance(from: coord2)

        // print("the distance between the two points is: \(distance) meters")
        // distance in km's
        return (distance / 1000)
    }

    func calculateCostFor(thisYear: Int, andDistanceFrom: Location) -> Int {
        let nobelYear = Int(year) ?? 0
        let cost = (abs(thisYear - nobelYear) * 10) + Int(distanceFrom(coordinate: andDistanceFrom))
        return cost
    }

    func createCopyWithCostFor(thisYear: Int, andDistanceFrom: Location) -> PrizeWinner {
        let cost = calculateCostFor(thisYear: thisYear, andDistanceFrom: andDistanceFrom)
        return(PrizeWinner(id: id, category: category, died: died, diedcity: diedcity, borncity: borncity, born: born, surname: surname, firstname: firstname, motivation: motivation, location: location, city: city, borncountry: borncountry, year: year, diedcountry: diedcountry, country: country, gender: gender, name: name, cost: cost))
    }
}

enum Category: String, Codable {
    case chemistry = "Chemistry"
    case economics = "Economics"
    case medicine = "Medicine"
    case physics = "Physics"
}

enum Gender: String, Codable {
    case female = "female"
    case male = "male"
}

// MARK: - Location
// CLLocationCoordinate2D isn't Codeable or Hashable... since Apple might eventually do this,
// we'll create our own Codable type -- https://www.objc.io/blog/2018/10/23/custom-types-for-codable/
struct Location: Codable {
    let lat, lng: Double
}

struct LocationWithCoordinates {
    let name: String
    let coordinates: CLLocationCoordinate2D

    // get our app-native location struct from CLLocationCoordinate2D
    var location: Location {
        return Location(lat: coordinates.latitude, lng: coordinates.longitude)
    }
}

typealias PrizeWinnerArray = [PrizeWinner]

class DataSource {
    var prizeWinners = PrizeWinnerArray()

    init() {
        if let path = Bundle.main.path(forResource: "nobel-prize-laureates", ofType: "json")
        {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do {
                    prizeWinners = try JSONDecoder().decode(PrizeWinnerArray.self, from: jsonData)
                } catch let error as NSError {
                    debugPrint("Error: \(error.description)")
                }
            } catch let error as NSError {
                debugPrint("Data couldn't be read from \(path) - \(error)")
            }
        }
    }

    class func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
}

class PickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let yearArray = Array(1900...2020)

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(yearArray[row])
    }
}
