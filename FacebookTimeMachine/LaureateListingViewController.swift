//
//  LaureatesNearbyViewController
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/25/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import UIKit
import CoreLocation

class LaureatesNearbyViewController: UIViewController {
    let dataSource = DataSource()

    var year: Int?
    var location: LocationWithCoordinates?
    let cellId = "LaureateCell"
    var contextualResults = [PrizeWinner]()

    var initialYear: Int?
    var initialPosition: LocationWithCoordinates?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var currentPositionLabel: UILabel!
    @IBOutlet var currentYearLabel: UILabel!
    @IBOutlet var currentFuelLevelLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let year = initialYear, let location = initialPosition {
            leapTo(newLocation: location, in: year, with: 0)
        }
        // go full screen because we can never return to
        // where we start without a cost, yes?
        modalPresentationStyle = .fullScreen
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NobelDetails" {
            if let button = sender as? UIButton {
                let buttonPosition = button.convert(button.bounds.origin, to: tableView)
                if let indexPath = tableView.indexPathForRow(at: buttonPosition), let nextViewController = segue.destination as? NobelDetailsViewController {
                    nextViewController.nobelWinner = contextualResults[indexPath.row]
                }
            }
        }
    }

    func leapTo(newLocation: LocationWithCoordinates, in newYear: Int, with cost: Int) {
        if FuelTank.shared.deductCost(liters: cost) == true {
            currentPositionLabel.text = "location: \(newLocation.name)"
            currentYearLabel.text = "year: \(newYear)"
            currentFuelLevelLabel.text = "fuel level: \(FuelTank.shared.currentLevel)"

            // calculate cost for all Nobel prize winners based on our current time machine year & location
            contextualResults = dataSource.prizeWinners.map { $0.createCopyWithCostFor(thisYear: newYear, andDistanceFrom: newLocation.location) }
            // create list of 20 nobel laureates closest (in cost) to current year and current location
            contextualResults = Array(contextualResults.sorted(by: { $0.cost! < $1.cost! }).prefix(20))
            // and then reload data
            tableView.reloadData()
            tableView.setContentOffset(.zero, animated: true)
        } else {
            // throw UIAlertViewController
            let alert = UIAlertController(title: "not enough fuel to travel", message: "You need \(cost) and you only have \(FuelTank.shared.currentLevel)", preferredStyle: .alert)
            // harsh!
            alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }

    @IBAction func unwindToLaureatesNearbyViewController(segue: UIStoryboardSegue) {
        //nothing goes here
    }
}

extension LaureatesNearbyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextualResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LaureateSummaryCell
        let winner = contextualResults[indexPath.row]
        cell.firstLastLabel.text = "\(winner.firstname) \(winner.surname)"
        cell.categoryAndYearLabel.text = "\(winner.category) \(winner.year)"
        cell.cityLabel.text = "\(winner.city)"
        cell.costLabel.text = "\(winner.cost ?? 0)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // jump to detail screen for this winner to learn about him/her
        let winner = contextualResults[indexPath.row]
        let loc_coords = CLLocationCoordinate2D(latitude: winner.location.lat, longitude:  winner.location.lng)
        if let newYear = Int(winner.year), let cost = winner.cost {
            leapTo(newLocation: LocationWithCoordinates(name: winner.city, coordinates: loc_coords), in: newYear, with: cost)
        }
    }
}

class LaureateSummaryCell: UITableViewCell {
    @IBOutlet var firstLastLabel: UILabel!
    @IBOutlet var categoryAndYearLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
}
