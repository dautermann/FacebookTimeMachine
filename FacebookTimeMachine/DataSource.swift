//
//  DataSource.swift
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/24/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import Foundation
import CoreLocation

// I generated this beautiful Decodable thing via https://app.quicktype.io/#l=swift

import Foundation

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

    func distanceFrom(coordinate: Location) -> Double {
        let coord1 = CLLocation(latitude: location.lat, longitude: location.lng)
        let coord2 = CLLocation(latitude: coordinate.lat, longitude: coordinate.lng)
        let distance = coord1.distance(from: coord2)

        // print("the distance between the two points is: \(distance) meters")
        return distance
    }

    func calculateCostFor(thisYear: Int, andDistanceFrom: Location) -> Int {
        let nobelYear = Int(year) ?? 0
        let cost = (abs(thisYear - nobelYear) * 10) + Int(distanceFrom(coordinate: andDistanceFrom))
        return cost
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
struct Location: Codable {
    let lat, lng: Double
}

typealias PrizeWinnerArray = [PrizeWinner]

class DataSource {
    init() {
        if let path = Bundle.main.path(forResource: "nobel-prize-laureates", ofType: "json")
        {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do {
                    let prizeWinners : [PrizeWinner] = try JSONDecoder().decode(PrizeWinnerArray.self, from: jsonData)
                    Swift.print("number of prizeWinners is \(prizeWinners.count)")
                } catch let error as NSError {
                    debugPrint("Error: \(error.description)")
                }
            } catch let error as NSError {
                debugPrint("Data couldn't be read from \(path) - \(error)")
            }
        }
    }
}
