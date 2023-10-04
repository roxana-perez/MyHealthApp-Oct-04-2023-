//
//  DataTypeTableViewController.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 9/28/23.
//

import UIKit
import HealthKit

class DataTypeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ObservableObject {
    
    static let healthStore: HKHealthStore = HKHealthStore()///HealthStore object
    
    
    ///outlet connections
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var showChart: UIButton!
    
    var dataTypeIdentifier: String = ""
    
    
    var dataValues: [HealthDataValue] = [] ///values for specific data type
    //@Published var dailyActivity: [DailyActivity] = []
    static var start : Date = Calendar.current.date(bySettingHour: 2, minute: 0, second: 0, of: Date())!
    static var end : Date = Date()
    
    
    @IBAction func startDate(_ sender: Any) { ///date picker for start date
        DataTypeTableViewController.start = Calendar.current.date(bySettingHour: 2, minute: 0, second: 0, of: startDate.date)!
        endDate.isEnabled = true
        endDate.minimumDate = startDate.date
        presentedViewController?.dismiss(animated: true)
    }
    @IBAction func endDate(_ sender: Any) { ///date picker for end date
        DataTypeTableViewController.end = endDate.date
        startDate.maximumDate = endDate.date
        presentedViewController?.dismiss(animated: true)
    }
    
    func performQuery(_ completion: @escaping () -> Void) { ///function to get the neccesary data from healthkit for specific data type
        self.dataTypeIdentifier = CategoriesTableViewController.dataTypeIdentifier
        print("this is in the other view type id \(self.dataTypeIdentifier)")
        let quantityType = HKQuantityType(HKQuantityTypeIdentifier(rawValue: self.dataTypeIdentifier))
        let predicate = HKQuery.predicateForSamples(withStart: DataTypeTableViewController.start, end: DataTypeTableViewController.end)
        let options = getStatisticsOptions(for: self.dataTypeIdentifier)
        let anchorDate = createAnchorDate(for: DataTypeTableViewController.start)
        let dailyInterval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: options, anchorDate: anchorDate, intervalComponents: dailyInterval)
        
        let updateInterfaceWithStaticstics: (HKStatisticsCollection) -> Void = {statisticsCollection in
            self.dataValues = []
           // self.dailyActivity = []
            
            let startDate = DataTypeTableViewController.start
            let endDate = DataTypeTableViewController.end
            
            print(startDate)
            print(endDate)
            
            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) {(statistics, stop) in
                var dataValue = HealthDataValue(startDate: statistics.startDate, endDate: statistics.endDate, value: 0)
               // var dailyAct = DailyActivity(date: startDate, activityData: 0)
                if let quantity = getStatisticsQuantity(for: statistics, with: options),
                   let identifier = self.dataTypeIdentifier as Optional,
                   let unit = preferredUnit(for: identifier) {
                    dataValue.value = quantity.doubleValue(for: unit)
                  //  dailyAct.activityData = quantity.doubleValue(for: unit)
                }
                self.dataValues.append(dataValue)
               // self?.dailyActivity.append(dailyAct)
            }
            
            completion()
            print("finish query")
        }
        
        query.initialResultsHandler = { query, statisticsCollection, error in
            if let statisticsCollection = statisticsCollection {
                updateInterfaceWithStaticstics(statisticsCollection)
            }
        }
        
        DataTypeTableViewController.healthStore.execute(query)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { ///number of columns in table view
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ///number of rows/ cells in table view
        return dataValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { ///population table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataTypeCell", for: indexPath)
        let value = dataValues[indexPath.row]
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        
        cell.textLabel?.text = String(format: "%.0f \(getUnit(for: dataTypeIdentifier)!)", value.value)
        cell.detailTextLabel?.text = dateformatter.string(from: value.startDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { ///assigning header to table
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = CategoriesTableViewController.getDataTypeName(for: self.dataTypeIdentifier) ?? ""
        label.font = .systemFont(ofSize: 25)
        label.textColor = .lightGray
        label.center = headerView.center
        
        headerView.addSubview(label)
        headerView.backgroundColor = dataTableView.backgroundColor
    
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataValues.isEmpty {
            return 0
        } else {
            return 50
        }
    }
    
    func reloadTable(_ message: String = "No Data"){ if dataValues.count == 0 { ///reloading values in table
        setEmptyDataView(message)
    } else {
        dataTableView.backgroundView = nil
    }
        dataTableView.reloadData()
    }
    
    func setEmptyDataView(_ message: String) { ///if no data table has a message
        let emptyDataView = EmptyDataBackgroundView(message: message)
        dataTableView.backgroundView = emptyDataView
    }
    
    @IBAction func clickedShow(_ sender: Any) { ///action for clicking the show button will perform query and populate the table view
        print("clickedShow")
        self.performQuery {
            DispatchQueue.main.async {
                self.reloadTable()
                self.showChart.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTable("Adjust setting to show your health data.")
        dataTableView.delegate = self
        dataTableView.dataSource = self
        reloadTable("Adjust setting to show your health data.")
        endDate.isEnabled = false
        startDate.maximumDate = Date()
        endDate.maximumDate = Date()
        self.showChart.isEnabled = false
    }
}


