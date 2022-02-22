//
//  ViewControllerDetails.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 21/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit
import MapKit

class ViewControllerDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var selectRegion: UIButton! {
        didSet {
            selectRegion.layer.cornerRadius = 20.0
            selectRegion.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var regionMapView: MKMapView!
    @IBOutlet weak var dataTable: UITableView!
    
    var regionsArray: [String] = [String]()
    var totalArray: [Int] = [Int]()
    var positiviArray: [Int] = [Int]()
    var graviArray: [Int] = [Int]()
    var guaritiArray: [Int] = [Int]()
    var decedutiArray: [Int] = [Int]()
    
    var provinces: [String] = [String]()
    var totalCasesProvinces: [Int] = [Int]()
    
    var selectedRegion = ""
    var updating = false
    let regionCoordinates: [String: CLLocationCoordinate2D] = [
        "Abruzzo": CLLocationCoordinate2D(latitude: 42.3506978, longitude: 13.3999338),
        "Basilicata": CLLocationCoordinate2D(latitude: 40.6686534, longitude: 16.6060872),
        "P.A. Bolzano": CLLocationCoordinate2D(latitude: 46.4951665, longitude: 11.3541034),
        "Calabria": CLLocationCoordinate2D(latitude: 38.1092915, longitude: 15.6439327),
        "Campania": CLLocationCoordinate2D(latitude: 40.8399968, longitude: 14.2528707),
        "Emilia Romagna": CLLocationCoordinate2D(latitude: 44.4944456, longitude: 11.3492311),
        "Friuli Venezia Giulia": CLLocationCoordinate2D(latitude: 45.6536295, longitude: 13.7784072),
        "Lazio": CLLocationCoordinate2D(latitude: 41.8954656, longitude: 12.4823243),
        "Liguria": CLLocationCoordinate2D(latitude: 44.4070624, longitude: 8.9339889),
        "Lombardia": CLLocationCoordinate2D(latitude: 45.4636707, longitude: 9.1881263),
        "Marche": CLLocationCoordinate2D(latitude: 43.6158281, longitude: 13.5189447),
        "Molise": CLLocationCoordinate2D(latitude: 41.5600859, longitude: 14.6647992),
        "Piemonte": CLLocationCoordinate2D(latitude: 45.0706029, longitude: 7.6867102),
        "Puglia": CLLocationCoordinate2D(latitude: 41.1260529, longitude: 16.8692905),
        "Sardegna": CLLocationCoordinate2D(latitude: 39.2149029, longitude: 9.1094988),
        "Sicilia": CLLocationCoordinate2D(latitude: 37.5028120, longitude: 15.0883146),
        "Toscana": CLLocationCoordinate2D(latitude: 43.7687324, longitude: 11.2569013),
        "P.A. Trento": CLLocationCoordinate2D(latitude: 46.0702531, longitude: 11.1216386),
        "Umbria": CLLocationCoordinate2D(latitude: 43.1107009, longitude: 12.3891720),
        "Valle d'Aosta": CLLocationCoordinate2D(latitude: 45.7356745, longitude: 7.3190697),
        "Veneto": CLLocationCoordinate2D(latitude: 45.4343363, longitude: 12.3387844)
    ]
    let provinceForRegion: [String: Int] = [
        "Abruzzo": 4,
        "Basilicata": 2,
        "P.A. Bolzano": 1,
        "Calabria": 5,
        "Campania": 5,
        "Emilia Romagna": 9,
        "Friuli Venezia Giulia": 4,
        "Lazio": 5,
        "Liguria": 4,
        "Lombardia": 12,
        "Marche": 5,
        "Molise": 2,
        "Piemonte": 8,
        "Puglia": 6,
        "Sardegna": 8,
        "Sicilia": 9,
        "Toscana": 10,
        "P.A. Trento": 1,
        "Umbria": 2,
        "Valle d'Aosta": 1,
        "Veneto": 7
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.selectedRegion == "" {
            
            // Centering map
            self.regionMapView.region.center = CLLocationCoordinate2D(latitude: 42.996626414, longitude: 12.0700133907)
            self.regionMapView.region.span = MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 14)
            self.regionMapView.removeAnnotations(self.regionMapView.annotations)
        } else {
            if !updating {
                
                // Centering map
                self.regionMapView.region.center = CLLocationCoordinate2D(latitude: 42.996626414, longitude: 12.0700133907)
                self.regionMapView.region.span = MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 14)
                self.regionMapView.removeAnnotations(self.regionMapView.annotations)
                
                // Setting titles
                self.selectRegion.setTitle("Seleziona regione", for: .normal)
                self.selectRegion.setTitleColor(UIColor.white, for: .normal)
                self.selectRegion.backgroundColor = .systemBlue
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting delegates
        self.dataTable.delegate = self
        self.dataTable.dataSource = self
    }
    
    @IBAction func showPickerView(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToRegionSelection", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRegionSelection" {
            let destVC = segue.destination as! ViewControllerRegionSelection
            destVC.delegate = self
        }
    }
    
    func updateMapAndData() {
        print(self.selectedRegion)
        
        self.updating = false
        
        // Center map on selected region
        self.regionMapView.setRegion(MKCoordinateRegion(center: self.regionCoordinates[self.selectedRegion]!, span: MKCoordinateSpan(latitudeDelta: 2.5, longitudeDelta: 2.5)), animated: true)

        self.regionsArray.removeAll()
        self.totalArray.removeAll()
        self.positiviArray.removeAll()
        self.graviArray.removeAll()
        self.guaritiArray.removeAll()
        self.decedutiArray.removeAll()
        self.provinces.removeAll()
        self.totalCasesProvinces.removeAll()
        
        // Downloading main region data
        URLSession.shared.dataTask(with: URL(string: "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni-latest.json")!) { (data, response, error) -> Void in
           // Check if data was received successfully
           if error == nil && data != nil {
               do {
                   
                // Convert to dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String: Any]]
                
                // Retrieving all datas
                for singleRegion in json {
                    self.regionsArray.append(singleRegion["denominazione_regione"] as! String)
                    self.totalArray.append(singleRegion["totale_casi"] as! Int)
                    self.positiviArray.append(singleRegion["totale_attualmente_positivi"] as! Int)
                    self.graviArray.append(singleRegion["terapia_intensiva"] as! Int)
                    self.guaritiArray.append(singleRegion["dimessi_guariti"] as! Int)
                    self.decedutiArray.append(singleRegion["deceduti"] as! Int)
                }
                
                DispatchQueue.main.async {
                    URLSession.shared.dataTask(with: URL(string: "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni-latest.json")!) { (data, response, error) -> Void in
                       // Check if data was received successfully
                       if error == nil && data != nil {
                           do {
                               
                            // Convert to dictionary where keys are of type String, and values are of any type
                            let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String: Any]]
                            
                            // Retrieving all datas
                            for singleProvince in json {
                                if (singleProvince["denominazione_regione"] as! String) == self.selectedRegion {
                                    
                                    // Adding to arrays
                                    self.provinces.append(singleProvince["denominazione_provincia"] as! String)
                                    self.totalCasesProvinces.append(singleProvince["totale_casi"] as! Int)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.dataTable.reloadData()
                            }
                           } catch {
                            
                            DispatchQueue.main.async {
                                // Hide loading indicator
                            }
                            print(error)
                        }
                    }
                    }.resume()
                }
               } catch {
                
                DispatchQueue.main.async {
                    // Hide loading indicator
                }
                print(error)
            }
        }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.provinceForRegion[self.selectedRegion]! + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // First cell = region
            let cell = tableView.dequeueReusableCell(withIdentifier: "region_detail_cell", for: indexPath) as! TableViewCell_RegionDetail
            
            
            
            return cell
        } else {
            // Other cells = provinces
            let cell = tableView.dequeueReusableCell(withIdentifier: "province_cell", for: indexPath) as! TableViewCell_Province
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 220
        } else {
            return 100
        }
    }
}
