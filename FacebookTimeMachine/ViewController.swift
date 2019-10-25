//
//  ViewController.swift
//  FacebookTimeMachine
//
//  Created by Michael Dautermann on 10/24/19.
//  Copyright © 2019 Michael Dautermann. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var startingFuelTankLevelField: UITextField!

    let pickerDataSource = PickerDataSource()
    let cellId = "cellId"
    let coordinateCharacterSet: CharacterSet = {
        var newCharacterSet = CharacterSet.decimalDigits
        newCharacterSet.insert(charactersIn: " -.,")
        return newCharacterSet
    }()

    //create a city name completion routine
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sc = MKLocalSearchCompleter()
        sc.filterType = .locationsOnly
        sc.delegate = self
        return sc
    }()

    var searchSource: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        yearPickerView.dataSource = pickerDataSource
        yearPickerView.delegate = pickerDataSource
        yearPickerView.selectRow(pickerDataSource.yearArray.count - 2, inComponent:0, animated:true)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartTimeMachine" {
            if let nextViewController = segue.destination as? LaureatesNearbyViewController, let startingFuelTankLevel = startingFuelTankLevelField.text {
                FuelTank.shared.refillTankWith(liters: Int(startingFuelTankLevel) ?? 0)
                guard let selectedLocation = sender as? LocationWithCoordinates else { return }
                nextViewController.initialYear = pickerDataSource.yearArray[yearPickerView.selectedRow(inComponent: 0)]
                nextViewController.initialPosition = selectedLocation
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //change searchCompleter depends on searchBar's text
        if !searchText.isEmpty {
            if onlyCoordinateDigits(searchText) == false {
                searchCompleter.queryFragment = searchText
            } else {
                getCityNameFor(searchText)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSource?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = self.searchSource?[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // convert this location name into lat and longitude and jump to next screen
        if let address = self.searchSource?[indexPath.row]  {
            DataSource.getCoordinateFrom(address: address) { coordinates, error in
                guard let coordinates = coordinates, error == nil else { return }
                let location = LocationWithCoordinates(name: address, coordinates: coordinates)
                // don't forget to update the UI from the main thread
                DispatchQueue.main.async {
                    print(address, "Location:", coordinates)
                    self.performSegue(withIdentifier: "StartTimeMachine", sender: location)
                }
            }
        }
    }
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchSource = completer.results.map { $0.title }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ViewController {
    func onlyCoordinateDigits(_ candidateString: String) -> Bool {
        return coordinateCharacterSet.isSuperset(of: CharacterSet(charactersIn: candidateString))
    }

    func getCityNameFor(_ latLngString: String) {
        // allow separating lat & long by either a comma or a space
        var latLngStringsArray = latLngString.components(separatedBy: ",")
        if (latLngStringsArray.count == 0) {
            latLngStringsArray = latLngString.components(separatedBy: " ")
        }
        if latLngStringsArray.count == 2 {
            if let lat = Double(latLngStringsArray[0].trimmingCharacters(in: .whitespacesAndNewlines)), let lng = Double(latLngStringsArray[1].trimmingCharacters(in: .whitespacesAndNewlines)) {
                let location = CLLocation(latitude: lat, longitude: lng)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    if let city = placemark.locality {
                        self.searchSource = [city]
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
