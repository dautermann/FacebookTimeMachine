//
//  LaureatesNearbyViewController
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/25/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import UIKit

class LaureatesNearbyViewController: UIViewController {
    let dataSource = DataSource()

    var year: Int?
    var location: Location?
    let cellId = "LaureateCell"
    var contextualResults = [PrizeWinner]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentTimeMachineYear = year, let currentTimeMachineLocation = location {
 //           contextualResults = dataSource.prizeWinners.map({(winner) -> PrizeWinner in
 //               let updatedWinner = winner.createCopyWithCostFor(thisYear: currentTimeMachineYear, andDistanceFrom: currentTimeMachineLocation)
 //               return updatedWinner
 //           })
            contextualResults = dataSource.prizeWinners.map { $0.createCopyWithCostFor(thisYear: currentTimeMachineYear, andDistanceFrom: currentTimeMachineLocation) }
            // create list of 20 nobel laureates closest (in cost) to current year and current location
            contextualResults = Array(contextualResults.sorted(by: { $0.cost! < $1.cost! }).prefix(20))

            // and then reload data
            tableView.reloadData()
        }
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

    }
}

class LaureateSummaryCell: UITableViewCell {
    @IBOutlet weak var firstLastLabel: UILabel!
    @IBOutlet weak var categoryAndYearLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
}
