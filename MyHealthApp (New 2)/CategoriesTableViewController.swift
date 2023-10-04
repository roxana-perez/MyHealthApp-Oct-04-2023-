//
//  CategoriesTableViewController.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 9/28/23.
//

import Foundation
import SwiftUI
import HealthKit
import UIKit


class CategoriesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @StateObject var manager = HealthData()
    
    @IBOutlet weak var healthTableView: UITableView! ///table view for categories
    static var dataTypeIdentifier: String = ""
    
    var DataAvailable: [String] = []
    var NoDataAvailable: [String] = []
    
    //------------------------------- VIEW DID LOAD ------------------------------------------------
    override func viewDidLoad() {
        
        var shareType : Set <HKSampleType> =  []
        var readType : Set <HKSampleType> =  []
        
        for dataType in CategoriesTableViewController.allHealthDataTypes {
            let dataTypeIdentifier = dataType.identifier
            let sampleType = getSampleType(for: dataTypeIdentifier)
            if sampleType is HKQuantityType {
                shareType.insert(sampleType!)
                readType.insert(sampleType!)
            }
        }
        HealthData.requestHealthDataAccessIfNeeded(toShare: shareType, read: readType) { success in
            if success {
                print("success")
                self.checkDataAvailability() {
                    self.healthTableView.reloadData()
                }
            }
            else {
                print("oops")
            }
        }
        //super.viewDidLoad()
        healthTableView.delegate = self
        healthTableView.dataSource = self
        
    }
    
    //------------------------------------- Defining all HealthKit data types available in the app ---------------------------------
    
    static var allHealthDataTypes: [HKSampleType]{
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.stepCount.rawValue,
            HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
            HKQuantityTypeIdentifier.heartRate.rawValue,
            HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
            HKQuantityTypeIdentifier.basalEnergyBurned.rawValue,
            HKQuantityTypeIdentifier.flightsClimbed.rawValue,
            HKQuantityTypeIdentifier.walkingSpeed.rawValue,
            HKQuantityTypeIdentifier.walkingStepLength.rawValue,
            HKQuantityTypeIdentifier.stairAscentSpeed.rawValue,
            HKQuantityTypeIdentifier.stairDescentSpeed.rawValue,
            HKQuantityTypeIdentifier.distanceCycling.rawValue,
            HKQuantityTypeIdentifier.runningSpeed.rawValue,
            HKQuantityTypeIdentifier.distanceSwimming.rawValue]
        return typeIdentifiers.compactMap{getSampleType(for:$0)}
    }
    
    ///function to assign data name given identifier, this is used to populate the table view
    static func getDataTypeName(for identifier: String) -> String? {
        
        var description: String?
        let sampleType = getSampleType(for: identifier)
        
        if sampleType is HKQuantityType {
            let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
            
            switch quantityTypeIdentifier {
            case .stepCount:
                description = "👣  Step Count"
            case .distanceWalkingRunning:
                description = "🏃  Distance Walking + Running"
            case .heartRate:
                description = "❤️  Heart Rate"
            case .activeEnergyBurned:
                description = "🔥  Active Energy Burned"
            case .basalEnergyBurned:
                description = "🔥  Resting Energy Burned"
            case .flightsClimbed:
                description = "↗   Flights Climbed"
            case .walkingSpeed:
                description = "🚶  Walking Speed"
            case .walkingStepLength:
                description = "🚶  Walking Step Length"
            case .stairAscentSpeed:
                description = "↗   Stair Ascent Speed"
            case .stairDescentSpeed:
                description = "↗   Stair Descent Speed"
            case .distanceCycling:
                description = "🚴‍♂️  Distance Cycling"
            case .runningSpeed:
                description = "🏃  Running Speed"
            case .distanceSwimming:
                description = "🏊  Distance Swimming"
            default:
                break
            }
        }
        return description
    }
    
    //--------------------------------------- Table View---------------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {  ///number of columns in table view
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ///number of rows/ cells in table view
        if section == 0{
            return DataAvailable.count
        }
        else {
            return NoDataAvailable.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allDataTypes = [self.DataAvailable, self.NoDataAvailable]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HealthDataCell", for: indexPath)
        cell.textLabel?.text = CategoriesTableViewController.getDataTypeName(for: allDataTypes[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { ///assigning header to table
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        if section == 0 {
            label.text = "Data Available"
        } else {
            label.text = "No Data Available"
        }
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18)
        label.center = headerView.center
        
        headerView.addSubview(label)
        headerView.backgroundColor = healthTableView.backgroundColor
    
        return headerView
    }
    
    ///function that will request authorization to the selected data type from the table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allDataTypes = [self.DataAvailable, self.NoDataAvailable]
        let dataType = allDataTypes[indexPath.section][indexPath.row]
        CategoriesTableViewController.dataTypeIdentifier = dataType
        print("this is the data type \(dataType)")
        healthTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //------------------------------------ Data Availability ----------------------------------------------------------
    func checkDataAvailability (_ completion: @escaping () -> Void){
        
        for sampleType in CategoriesTableViewController.allHealthDataTypes {
            let sample = sampleType as! HKQuantityType
            let dataType = sample
            let query = HKSampleQuery(sampleType: dataType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil){ (_, results, error) in
                if let error = error {
                    print("Error queriying healthkit data")
                }
                else{
                    if let samples = results, !samples.isEmpty {
                        print("Data is available \(sampleType.identifier)")
                        self.DataAvailable.append(sampleType.identifier)
                        
                    } else {
                        print("No data is available \(sampleType.identifier)")
                        self.NoDataAvailable.append(sampleType.identifier)
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
            
            
            HealthData.healthStore.execute(query)
        }
        
    }
    
}
