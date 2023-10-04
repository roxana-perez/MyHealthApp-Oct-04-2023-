//
//  HealthData.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 9/28/23.
//

import Foundation
import HealthKit

class HealthData: ObservableObject{
    
    static let healthStore: HKHealthStore = HKHealthStore() ///healthstore object
    


 ///function for requestion authorization to access health data of the user
class func requestHealthDataAccessIfNeeded(toShare shareTypes: Set<HKSampleType>?,
                                           read readTypes: Set<HKObjectType>?,
                                           completion: @escaping (_ success: Bool) -> Void) {
    if !HKHealthStore.isHealthDataAvailable() {
        fatalError("Health data is not available!")
    }
    
    print("Requesting HealthKit authorization...")
    healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { (success, error) in
        if let error = error {
            print("requestAuthorization error:", error.localizedDescription)
        }
        
        if success {
            print("HealthKit authorization request was successful!")
        } else {
            print("HealthKit authorization was not successful.")
        }
        
        completion(success)
    }
}
}
    
///method that returns HKSampleType given an identifier
func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    return nil
}
