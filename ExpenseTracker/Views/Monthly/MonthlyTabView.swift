// Developed by Artem Bartle

import SwiftUI
import CoreData

struct MonthlyTabView: View {
    
    @Environment(\.managedObjectContext)
        var context: NSManagedObjectContext
    
    @State private var searchText : String = ""
    @State private var searchBarHeight: CGFloat = 0
    
    @State var selectedMonths: Set<Month> = Set([Date().month])
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText, keyboardHeight: $searchBarHeight, placeholder: "Search expenses")
                FilterCategoriesView(selectedCategories: $selectedMonths, categories: Month.allCases)
                Divider()
                LogListView(predicate: ExpenseLog.predicate(with: Array(selectedMonths), searchText: searchText),
                            sortDescriptor: ExpenseLogSort(sortType: .date, sortOrder: .ascending).sortDescriptor)
            }
            .padding(.bottom, searchBarHeight)
            .navigationBarTitle("Monthly Summary", displayMode: .inline)
        }
    }
}


struct MonthlyTabView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyTabView()
    }
}
