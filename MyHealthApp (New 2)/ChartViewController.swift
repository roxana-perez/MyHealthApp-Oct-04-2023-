//
//  ChartViewController.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 10/3/23.
//

import UIKit
import HealthKit
import Charts
import SwiftUI


class ChartViewController: UIViewController {
    
    let healthStore: HKHealthStore = HKHealthStore()
    
    let dataTypeTableViewController: DataTypeTableViewController = DataTypeTableViewController()
    var dataTypeIdentifier: String = ""
    var start: Date = Date()
    var end: Date = Date()
    
    static var dailyActivity: [DailyActivity] = []
    
    func performQuery(_ completion: @escaping () -> Void) { ///function to get the neccesary data from healthkit for specific data type
        self.dataTypeIdentifier = CategoriesTableViewController.dataTypeIdentifier
        print("Data Type identifier \(self.dataTypeIdentifier)") //good
        self.start = DataTypeTableViewController.start
        print("start date \(self.start)") //good
        self.end = DataTypeTableViewController.end
        print("end date \(self.end)") //good
        let quantityType = HKQuantityType(HKQuantityTypeIdentifier(rawValue: self.dataTypeIdentifier))
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let options = getStatisticsOptions(for: self.dataTypeIdentifier)
        let anchorDate = createAnchorDate(for: start)
        let dailyInterval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: options, anchorDate: anchorDate, intervalComponents: dailyInterval)
        
        let updateInterfaceWithStaticstics: (HKStatisticsCollection) -> Void = {statisticsCollection in
            ChartViewController.dailyActivity = []
            
            let startDate = self.start
            let endDate = self.end
            
            print(startDate)
            print(endDate)
            
            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) {  (statistics, stop) in
                var dailyAct = DailyActivity(date: startDate, activityData: 0)
                if let quantity = getStatisticsQuantity(for: statistics, with: options),
                   let identifier = self.dataTypeIdentifier as Optional,
                   let unit = preferredUnit(for: identifier) {
                    dailyAct.activityData = quantity.doubleValue(for: unit)
                    let calendar = Calendar.current
                    dailyAct.date = self.start
                    self.start = calendar.date(byAdding: .day, value: 1, to: self.start)!
                    
                }
                ChartViewController.dailyActivity.append(dailyAct)
                print("daily act \(dailyAct)")
            }
            
            completion()
            print("finish query")
        }
        query.initialResultsHandler = { query, statisticsCollection, error in
            if let statisticsCollection = statisticsCollection {
                updateInterfaceWithStaticstics(statisticsCollection)
            }
        }
        HealthData.healthStore.execute(query)
    }


    override func viewDidLoad() {
        performQuery {
            DispatchQueue.main.async {
                print("Query performed")
                let vc = UIHostingController(rootView: SwiftUIView())
                let swiftui = vc.view
                swiftui!.translatesAutoresizingMaskIntoConstraints = false
                self.addChild(vc)
                self.view.addSubview(swiftui!)
                
                NSLayoutConstraint.activate([
                    swiftui!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    swiftui!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
                ])
                
                vc.didMove(toParent: self)
            }
        }
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}



