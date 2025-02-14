//
//  DashboardTabView.swift
//  ExpenseTracker
//
//  Created by Alfian Losari on 19/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI
import CoreData

struct DashboardTabView: View {
    
    @Environment(\.managedObjectContext)
    var context: NSManagedObjectContext
    
    @State var totalExpenses: Double?
    @State var categoriesSum: [CategorySum]?
    
    @ObservedObject var currencyConverter = CurrencyConverter(from: .usd, to: .eur)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(currencyConverter.formattedPrice(totalExpenses))
                    .font(.largeTitle)

                if categoriesSum != nil {
                    if totalExpenses != nil && totalExpenses! > 0 {
                        PieChartView(
                            data: categoriesSum!.map { ($0.sum, $0.category.color) },
                            style: Styles.pieChartStyleOne,
                            form: CGSize(width: 300, height: 240),
                            dropShadow: false
                        )
                    }
                    
                    Divider()

                    List {
                        Text("Breakdown").font(.headline)
                        ForEach(self.categoriesSum!) {
                            CategoryRowView(category: $0.category, sum: currencyConverter.formattedPrice($0.sum))
                        }
                    }
                }
                
                if totalExpenses == nil && categoriesSum == nil {
                    Text("No expenses data\nPlease add your expenses from the logs tab")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .onAppear(perform: fetchTotalSums)
            .toolbar {
                Toggle("EUR", isOn: $currencyConverter.converted)
            }
            .overlay {
                if currencyConverter.loading {
                    ProgressView("Refreshing conversion rate")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                }
            }
            .alert("Please try again later", isPresented: $currencyConverter.failed, actions: {})
            .navigationBarTitle("Total expenses", displayMode: .inline)
        }
    }
    
    func fetchTotalSums() {
        ExpenseLog.fetchAllCategoriesTotalAmountSum(context: self.context) { (results) in
            guard !results.isEmpty else { return }
            
            let totalSum = results.map { $0.sum }.reduce(0, +)
            self.totalExpenses = totalSum
            self.categoriesSum = results.map({ (result) -> CategorySum in
                return CategorySum(sum: result.sum, category: result.category)
            })
        }
    }
}

struct CategorySum: Identifiable, Equatable {
    let sum: Double
    let category: Category
    
    var id: String { "\(category)\(sum)" }
}


struct DashboardTabView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTabView()
    }
}
