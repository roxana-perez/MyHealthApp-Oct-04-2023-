//
//  SwiftUIView.swift
//  MyHealthApp (New 2)
//
//  Created by Roxana  Perez on 10/3/23.
//

import SwiftUI
import Charts

func calcAverage() -> Double {
    let count: Double = Double(ChartViewController.dailyActivity.count)
    var sum = 0.0
    for data in ChartViewController.dailyActivity {
        sum = sum + data.activityData
    }
    let average = sum/count
    return average
}

func calcMax() -> Double {
    var newData: [Double] = []
    for data in ChartViewController.dailyActivity {
        newData.append(data.activityData)
    }
    return newData.max()!
}
func calcMin() -> Double {
    var newData: [Double] = []
    for data in ChartViewController.dailyActivity {
        newData.append(data.activityData)
    }
    return newData.min()!
}


struct SwiftUIView: View {
    @State var selectedDate: Date?
    @State var selectedValue: Double?
    var body: some View {
        VStack {
            Text(CategoriesTableViewController.getDataTypeName(for: CategoriesTableViewController.dataTypeIdentifier)!)
                .bold()
            
            Text("Average: \(calcAverage())")
                .fontWeight(.regular)
                .font(.footnote)
                .foregroundStyle(.black)
            
                .padding()
            
            Chart {
                ForEach(ChartViewController.dailyActivity){ daily in
                    BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Activity Data", daily.activityData))
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(6)
                        .shadow(radius: 3)
                }
            }
            //.foregroundColor(.blue)
            .foregroundStyle(Color("Blue").gradient)
            .frame(width: 350, height: 300, alignment: .center)
            
            .chartXSelection(value: $selectedDate)
            .chartYSelection(value: $selectedValue)
            
        }
        .padding()
        .onAppear()
        if ((selectedDate) != nil) {
            Text(selectedDate!, format: .dateTime)
        }
        else {
            Text("Select a data point to see details")
                .foregroundStyle(Color.gray)
                .fontWeight(.light)
                .font(.system(size: 15))
        }
        
        if (selectedValue != nil) {
            Text(selectedValue!, format: .number)
                .padding()
        }
            
            Text("Data Analysis")
                .fontWeight(.medium)
                .underline()
                .padding()
            Text("Maximum Value:    \(calcMax())  ")
                .fontWeight(.regular)
                .foregroundStyle(.gray)
            Text("Manimum Value:    \(calcMin())  ")
                .fontWeight(.regular)
                .foregroundStyle(.gray)
            
        }
        
        
    }

#Preview {
    SwiftUIView()
}
