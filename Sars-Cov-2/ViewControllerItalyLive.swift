//
//  ViewControllerItalyLive.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 20/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MapKit

class ViewControllerItalyLive: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dataLoadingIndicator: NVActivityIndicatorView!
    @IBOutlet weak var liveIndicator: NVActivityIndicatorView!
    @IBOutlet weak var totalePositivi: UILabel!
    @IBOutlet weak var lastUpdate: UILabel!
    @IBOutlet weak var pzGravi: UILabel!
    @IBOutlet weak var pzGuariti: UILabel!
    @IBOutlet weak var pzDeceduti: UILabel!
    @IBOutlet weak var tamponiEffettuati: UILabel!
    @IBOutlet weak var pzAncoraPositivi: UILabel!
    @IBOutlet weak var italyMapView: MKMapView!
    
    var regionNames: [String] = []
    var regionCases: [Int] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        
        // Stopping live indicator while updating
        self.liveIndicator.stopAnimating()
        
        // Creating loading indicator
        self.dataLoadingIndicator.type = .lineScaleParty
        self.dataLoadingIndicator.color = UIColor.white
        self.dataLoadingIndicator.startAnimating()
        
        // Setting map view
        self.italyMapView.region.center = CLLocationCoordinate2D(latitude: 42.996626414, longitude: 12.0700133907)
        self.italyMapView.region.span = MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 14)
        self.italyMapView.removeAnnotations(self.italyMapView.annotations)
        
        // Load data
        self.loadMainJSON()
        self.downloadRegions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the view corners
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.masksToBounds = true
        
        // Set the shadow
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.containerView.layer.shadowOpacity = 0.2
        self.containerView.layer.shadowRadius = 5.0
        
    }


    func loadMainJSON() {
        
        self.liveIndicator.stopAnimating()
        //Removing errorView if still present
        if let erView = self.containerView.viewWithTag(110) {
            erView.removeFromSuperview()
        }
        
           URLSession.shared.dataTask(with: URL(string: "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-andamento-nazionale-latest.json")!) { (data, response, error) -> Void in
           // Check if data was received successfully
           if error == nil && data != nil {
               do {
                   
                // Convert to dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String: Any]]
                
                   
                // Access specific key with value of type String
                let updateDate = json[0]["data"] as! String
                let icu = json[0]["terapia_intensiva"] as! Int
                let positivi = json[0]["totale_attualmente_positivi"] as! Int
                let nuoviPositivi = json[0]["nuovi_attualmente_positivi"] as! Int
                let dimessi = json[0]["dimessi_guariti"] as! Int
                let deceduti = json[0]["deceduti"] as! Int
                let totaleCasi = json[0]["totale_casi"] as! Int
                let tamponi = json[0]["tamponi"] as! Int
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.locale = NSLocale(localeIdentifier: "it_IT") as Locale
                let formattedTotaleCasi = numberFormatter.string(from: NSNumber(value: totaleCasi))
                let formattedIcu = numberFormatter.string(from: NSNumber(value: icu))
                let formattedPositivi = numberFormatter.string(from: NSNumber(value: positivi))
                let formattedDimessi = numberFormatter.string(from: NSNumber(value: dimessi))
                let formattedDeceduti = numberFormatter.string(from: NSNumber(value: deceduti))
                let formattedTamponi = numberFormatter.string(from: NSNumber(value: tamponi))
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let lastUpdateDate = dateFormatter.date(from: updateDate)
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "dd/MM/yyyy HH:mm"
                let finalStringDate = dateFormatter2.string(from: lastUpdateDate!)
                
                // Showing parsed results
                DispatchQueue.main.async {
                    self.dataLoadingIndicator.stopAnimating()
                    
                    // Setting live indicator
                    self.liveIndicator.type = .ballScaleMultiple
                    self.liveIndicator.color = UIColor.red
                    self.liveIndicator.startAnimating()
                    
                    self.lastUpdate.text = "Ultimo aggiornamento: " + finalStringDate
                    self.totalePositivi.text = formattedTotaleCasi!
                    self.pzGravi.text = formattedIcu!
                    self.pzAncoraPositivi.text = formattedPositivi! + " (+ \(nuoviPositivi))"
                    self.pzGuariti.text = formattedDimessi!
                    self.pzDeceduti.text = formattedDeceduti!
                    self.tamponiEffettuati.text = formattedTamponi!
                }
            
               } catch {
                
                self.addErrorView()
                print(error)
            }
        }
           }.resume()
    }

    func addErrorView() {
        DispatchQueue.main.async {
            
            self.dataLoadingIndicator.stopAnimating()
            
            let errorView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height))
            errorView.backgroundColor = self.containerView.backgroundColor
            errorView.tag = 110
            
            let errorImage: UIImageView = UIImageView(frame: CGRect(x: errorView.center.x - 30, y: 55, width: 60, height: 60))
            errorImage.image = UIImage(named: "error-icon.png")
            errorImage.contentMode = .scaleAspectFit
            errorView.addSubview(errorImage)
            
            let errorLabel: UILabel = UILabel(frame: CGRect(x: 30, y: errorImage.frame.maxY + 10, width: errorView.frame.size.width - 60, height: 100))
            errorLabel.textColor = UIColor.red
            errorLabel.numberOfLines = 0
            errorLabel.textAlignment = .center
            errorLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            errorLabel.text = "Si è verificato un errore durante il download dei dati"
            errorView.addSubview(errorLabel)
            
            // Adding the errorView to containerView
            self.containerView.addSubview(errorView)
        }
    }
    
    func downloadRegions() {
        
        self.regionCases.removeAll()
        self.regionNames.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-regioni-latest.json")!) { (data, response, error) -> Void in
           // Check if data was received successfully
           if error == nil && data != nil {
               do {
                   
                // Convert to dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String: Any]]
                
                // Retrieving all datas
                for singleRegion in json {
                    self.regionNames.append(singleRegion["denominazione_regione"] as! String)
                    self.regionCases.append(singleRegion["totale_casi"] as! Int)
                }
                
                DispatchQueue.main.async {
                    
                    var i = 0
                    for region in self.regionNames {
                        
                        let cases = self.regionCases[i]
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        numberFormatter.locale = NSLocale(localeIdentifier: "it_IT") as Locale
                        let formattedCases = numberFormatter.string(from: NSNumber(value: cases))
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = self.regionCoordinates[region]!
                        annotation.title = "\(region)" + " - " + formattedCases! + " casi"
                        self.italyMapView.addAnnotation(annotation)
                        print(i)
                        i = i + 1
                    }
                }
            
               } catch {
                
                print(error)
            }
        }
           }.resume()
    }
}

