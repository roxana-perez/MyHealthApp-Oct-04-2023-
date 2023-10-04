//
//  ChartView.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 10/3/23.
//

import SwiftUI
import Charts
import HealthKit

struct DailyActivity: Identifiable {
    let id = UUID()
    var date: Date
    var activityData: Double
}



