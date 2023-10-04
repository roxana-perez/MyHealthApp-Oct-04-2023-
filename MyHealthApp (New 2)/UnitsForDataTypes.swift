//
//  UnitsForDataTypes.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 10/3/23.
//

import Foundation
import HealthKit


func preferredUnit(for sample: HKSample) -> HKUnit? { ///assigning unit
    let unit = preferredUnit(for: sample.sampleType.identifier, sampleType: sample.sampleType)
    
    if let quantitySample = sample as? HKQuantitySample, let unit = unit {
        assert(quantitySample.quantity.is(compatibleWith: unit),
               "The preferred unit is not compatiable with this sample.")
        
        
        
        
    }
    return unit
}

/// Returns the appropriate unit to use with an identifier corresponding to a HealthKit data type.
func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}

func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .stepCount, .flightsClimbed:
            unit = .count()
        case .distanceWalkingRunning, .walkingStepLength, .distanceCycling, .distanceSwimming:
            unit = .meter()
        case .heartRate:
            unit = HKUnit(from: "count/min")
        case .activeEnergyBurned, .basalEnergyBurned:
            unit = HKUnit(from: "kcal")
        case .walkingSpeed, .stairAscentSpeed, .stairDescentSpeed, .runningSpeed:
            unit = HKUnit(from: "m/s")
        default:
            break
        }
    }
    return unit
}

func getUnit(for sampleIdentifier: String) -> String? {
    let sampleType = getSampleType(for: sampleIdentifier)
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: sampleIdentifier)
        
        switch quantityTypeIdentifier {
        case .stepCount:
            return "Steps"
        case .distanceWalkingRunning, .walkingStepLength, .distanceCycling, .distanceSwimming:
            return "Meters"
        case .heartRate:
            return "BPM"
        case .activeEnergyBurned, .basalEnergyBurned:
            return "Cal"
        case .flightsClimbed:
            return "Floors"
        case .walkingSpeed, .stairAscentSpeed, .stairDescentSpeed, .runningSpeed:
            return "m/s"
        default:
            break
        }
    }
    return nil
}



// MARK: - Query Support
func createAnchorDate(for date: Date) -> Date {
    let calendar: Calendar = .current
    var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: date)
    anchorComponents.hour = 2
    let anchorDate = calendar.date(from: anchorComponents)!
    return anchorDate
}

/// Return the most preferred `HKStatisticsOptions` for a data type identifier. Defaults to `.discreteAverage`.
func getStatisticsOptions(for dataTypeIdentifier: String) -> HKStatisticsOptions {
    var options: HKStatisticsOptions = .discreteAverage
    let sampleType = getSampleType(for: dataTypeIdentifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier)
        
        switch quantityTypeIdentifier {
        case .stepCount, .distanceWalkingRunning, .activeEnergyBurned, .basalEnergyBurned, .flightsClimbed, .distanceCycling, .distanceSwimming:
            options = .cumulativeSum
        case .heartRate, .walkingSpeed, .walkingStepLength, .walkingAsymmetryPercentage, .stairAscentSpeed, .stairDescentSpeed, .runningSpeed:
            options = .discreteAverage
        default:
            break
        }
    }
    return options
}

/// Return the statistics value in `statistics` based on the desired `statisticsOption`.
func getStatisticsQuantity(for statistics: HKStatistics, with statisticsOptions: HKStatisticsOptions) -> HKQuantity? {
    var statisticsQuantity: HKQuantity?
    
    switch statisticsOptions {
    case .cumulativeSum:
        statisticsQuantity = statistics.sumQuantity()
    case .discreteAverage:
        statisticsQuantity = statistics.averageQuantity()
    default:
        break
    }
    
    return statisticsQuantity
}

