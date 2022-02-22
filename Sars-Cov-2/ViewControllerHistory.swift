//
//  ViewControllerHistory.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 21/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Charts

class ViewControllerHistory: UIViewController, UITableViewDelegate, UITableViewDataSource, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {

    @IBOutlet weak var dataLoadingIndicator: NVActivityIndicatorView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var segmentedControl: SJFluidSegmentedControl!
    
    var dataCasiTotali: [Double] = []
    var dataGuariti: [Double] = []
    var dataDeceduti: [Double] = []
    var datas: [String] = []
    var dataPositivi: [Double] = []
    var dataGravi: [Double] = []
    let segmentArray: [String] = ["Tutti", "Casi totali", "Positivi", "Guariti", "Deceduti"]
    var set1: LineChartDataSet = LineChartDataSet()
    var set2: LineChartDataSet = LineChartDataSet()
    var set3: LineChartDataSet = LineChartDataSet()
    var set4: LineChartDataSet = LineChartDataSet()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting chart
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.rightAxis.drawLabelsEnabled = false
        self.chartView.rightAxis.enabled = false
        self.chartView.xAxis.drawLabelsEnabled = false
        
        // Creating loading indicator
        self.dataLoadingIndicator.type = .lineScaleParty
        self.dataLoadingIndicator.color = UIColor.blue
        self.dataLoadingIndicator.startAnimating()
        
        // Load data
        self.loadMainJSON()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting table view
        self.dataTable.delegate = self
        self.dataTable.dataSource = self
        
        // Set chart shadow
        self.chartView.layer.masksToBounds = false
        self.chartView.layer.shadowColor = UIColor.black.cgColor
        self.chartView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.chartView.layer.shadowOpacity = 0.5
        self.chartView.layer.shadowRadius = 4.0
        
        // Set segmented control
        self.segmentedControl.dataSource = self

    }

    func loadMainJSON() {
        
        self.datas.removeAll()
        self.dataCasiTotali.removeAll()
        self.dataGuariti.removeAll()
        self.dataDeceduti.removeAll()
        self.dataPositivi.removeAll()
        self.dataGravi.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-json/dpc-covid19-ita-andamento-nazionale.json")!) { (data, response, error) -> Void in
           // Check if data was received successfully
           if error == nil && data != nil {
               do {
                   
                // Convert to dictionary where keys are of type String, and values are of any type
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String: Any]]
                
                // Retrieving all datas
                for singleDay in json {
                    self.datas.append(singleDay["data"] as! String)
                    self.dataCasiTotali.append(singleDay["totale_casi"] as! Double)
                    self.dataGuariti.append(singleDay["dimessi_guariti"] as! Double)
                    self.dataDeceduti.append(singleDay["deceduti"] as! Double)
                    self.dataPositivi.append(singleDay["totale_attualmente_positivi"] as! Double)
                    self.dataGravi.append(singleDay["terapia_intensiva"] as! Double)
                }
                
                DispatchQueue.main.async {
                    self.dataLoadingIndicator.stopAnimating()
                    
                    var i = 0
                    var j = 0
                    var entries1: [ChartDataEntry] = []
                    var entries2: [ChartDataEntry] = []
                    var entries3: [ChartDataEntry] = []
                    var entries4: [ChartDataEntry] = []
                    
                    for caso in self.dataCasiTotali {
                        entries1.append(ChartDataEntry(x: Double(j), y: caso))
                        entries2.append(ChartDataEntry(x: Double(j), y: self.dataGuariti[i]))
                        entries3.append(ChartDataEntry(x: Double(j), y: self.dataPositivi[i]))
                        entries4.append(ChartDataEntry(x: Double(j), y: self.dataDeceduti[i]))
                        i = i + 1
                        j = j + 10
                    }
                    
                    self.set1 = LineChartDataSet(entries: entries1, label: "Casi totali")
                    self.set2 = LineChartDataSet(entries: entries2, label: "Guariti")
                    self.set3 = LineChartDataSet(entries: entries3, label: "Positivi")
                    self.set4 = LineChartDataSet(entries: entries4, label: "Deceduti")
                    
                    self.set1.setCircleColor(UIColor.black)
                    self.set1.setColor(UIColor.black)
                    self.set1.drawCirclesEnabled = false
                    self.set1.mode = .cubicBezier
                    self.set1.lineWidth = 2.0
                    self.set2.setCircleColor(UIColor.blue)
                    self.set2.setColor(UIColor.blue)
                    self.set2.mode = .cubicBezier
                    self.set2.lineWidth = 2.0
                    self.set2.drawCirclesEnabled = false
                    self.set3.setCircleColor(UIColor.purple)
                    self.set3.setColor(UIColor.purple)
                    self.set3.drawCirclesEnabled = false
                    self.set3.mode = .cubicBezier
                    self.set3.lineWidth = 2.0
                    self.set4.setCircleColor(UIColor.red)
                    self.set4.setColor(UIColor.red)
                    self.set4.drawCirclesEnabled = false
                    self.set4.mode = .cubicBezier
                    self.set4.lineWidth = 2.0
                    
                    let data = LineChartData(dataSets: [self.set1, self.set3, self.set2, self.set4])
                    self.chartView.data = data
                    self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                    
                    self.datas.reverse()
                    self.dataCasiTotali.reverse()
                    self.dataGuariti.reverse()
                    self.dataDeceduti.reverse()
                    self.dataPositivi.reverse()
                    self.dataGravi.reverse()
                    self.dataTable.reloadData()
                }
            
               } catch {
                
                DispatchQueue.main.async {
                    self.dataLoadingIndicator.stopAnimating()
                }
                
                print(error)
            }
        }
           }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history_cell", for: indexPath) as! TableViewCell_History
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = NSLocale(localeIdentifier: "it_IT") as Locale
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = dateFormatter.date(from: self.datas[indexPath.row])
        
        dateFormatter.dateFormat = "dd/MM"
        cell.dateLabel.text = dateFormatter.string(from: currentDate!)
        
        cell.totalLabel.text = "Casi totali: " + numberFormatter.string(from: NSNumber(value: self.dataCasiTotali[indexPath.row]))!
        cell.graviLabel.text = "Casi gravi: " + numberFormatter.string(from: NSNumber(value: self.dataGravi[indexPath.row]))!
        cell.positiviLabel.text = "Casi positivi: " + numberFormatter.string(from: NSNumber(value: self.dataPositivi[indexPath.row]))!
        cell.guaritiLabel.text = "Guariti: " + numberFormatter.string(from: NSNumber(value: self.dataGuariti[indexPath.row]))!
        cell.decedutiLabel.text = "Deceduti: " + numberFormatter.string(from: NSNumber(value: self.dataDeceduti[indexPath.row]))!
        
        if self.dataCasiTotali.indices.contains(indexPath.row + 1) {
            
            cell.totalLabel.text = cell.totalLabel.text! + " (+ " + numberFormatter.string(from: NSNumber(value: self.dataCasiTotali[indexPath.row] - self.dataCasiTotali[indexPath.row + 1]))! + ")"
            /*cell.graviLabel.text = cell.graviLabel.text! + " + (" + numberFormatter.string(from: NSNumber(value: self.dataGravi[indexPath.row] - self.dataGravi[indexPath.row + 1]))! + ")"
            cell.positiviLabel.text = cell.graviLabel.text! + " + (" + numberFormatter.string(from: NSNumber(value: self.dataPositivi[indexPath.row] - self.dataPositivi[indexPath.row + 1]))! + ")"
            cell.guaritiLabel.text = cell.guaritiLabel.text! + " + (" + numberFormatter.string(from: NSNumber(value: self.dataGuariti[indexPath.row] - self.dataGuariti[indexPath.row + 1]))! + ")"
            cell.decedutiLabel.text = cell.decedutiLabel.text! + " + (" + numberFormatter.string(from: NSNumber(value: self.dataDeceduti[indexPath.row] - self.dataDeceduti[indexPath.row + 1]))! + ")"*/
        }
        
        if indexPath.row % 2 != 0 {
            // The number is odd
            cell.backgroundColor = UIColor(displayP3Red: 216/255, green: 225/255, blue: 245/255, alpha: 1.0)
        }
        
        return cell
    }

    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 5
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleForSegmentAtIndex index: Int) -> String? {
        return self.segmentArray[index]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex:Int) {
        
        
        if toIndex == 0 {
            let data = LineChartData(dataSets: [set1, set3, set2, set4])
            self.chartView.data = data
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        } else if toIndex == 1 {
            let data = LineChartData(dataSet: set1)
            self.chartView.data = data
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        } else if toIndex == 2 {
            let data = LineChartData(dataSet: set3)
            self.chartView.data = data
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        } else if toIndex == 3 {
            let data = LineChartData(dataSet: set2)
            self.chartView.data = data
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        } else if toIndex == 4 {
            let data = LineChartData(dataSet: set4)
            self.chartView.data = data
            self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        }
    }
    
}
