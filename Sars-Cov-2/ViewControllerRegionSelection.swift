//
//  ViewControllerRegionSelection.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 22/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit

class ViewControllerRegionSelection: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var regionPicker: UITableView!
    
    var delegate = ViewControllerDetails()
    
    let pickerValues: [String]  = ["Abruzzo", "Basilicata", "P.A. Bolzano", "Calabria", "Campania", "Emilia Romagna", "Friuli Venezia Giulia", "Lazio", "Liguria", "Lombardia", "Marche", "Molise", "Piemonte", "Puglia", "Sardegna", "Sicilia", "Toscana", "P.A. Trento", "Umbria", "Valle d'Aosta", "Veneto"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting delegates
        self.regionPicker.delegate = self
        self.regionPicker.dataSource = self
    }
    
    @IBAction func cancelPage(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pickerValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "region_cell", for: indexPath) as! TableViewCell_Regions
        
        cell.regionName.text = self.pickerValues[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.selectRegion.backgroundColor = UIColor.green
        delegate.selectRegion.setTitle(self.pickerValues[indexPath.row], for: .normal)
        delegate.selectedRegion = self.pickerValues[indexPath.row]
        delegate.updating = true
        delegate.updateMapAndData()
        self.dismiss(animated: true, completion: nil)
    }
}
