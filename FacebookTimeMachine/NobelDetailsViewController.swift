//
//  NobelDetailsViewController.swift
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/26/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import UIKit

class NobelDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var nobelWinner: PrizeWinner?
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // we'll just use default cells for today... if I were unemployed (and had another day), I'd make beaaautiful cells
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        // separators should go edge to edge
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        // hide separators between empty cells
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)

        guard let nobelWinner = nobelWinner else {
            return cell
        }
        switch(indexPath.row) {
        case 0 :
            cell.textLabel?.text = "\(nobelWinner.firstname) \(nobelWinner.surname)"
        case 1 :
            cell.textLabel?.text = "\(nobelWinner.city)"
        case 2 :
            cell.textLabel?.text = "\(nobelWinner.category) \(nobelWinner.year)"
        case 3 :
            cell.textLabel?.text = "\(nobelWinner.motivation)"
        case 4 :
            cell.textLabel?.text = "born: \(nobelWinner.born) in \(nobelWinner.borncity), \(nobelWinner.borncountry)"
        case 5:
            cell.textLabel?.text = "died: \(nobelWinner.died) in \(nobelWinner.diedcity), \(nobelWinner.diedcountry)"
        default:
            break
        }
        return cell
    }
}
