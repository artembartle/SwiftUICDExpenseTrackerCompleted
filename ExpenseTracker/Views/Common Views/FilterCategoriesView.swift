//
//  FilterCategoriesView.swift
//  ExpenseTracker
//
//  Created by Alfian Losari on 19/04/20.
//  Copyright © 2020 Alfian Losari. All rights reserved.
//

import SwiftUI

protocol FilterItem: Identifiable, Hashable, RawRepresentable where RawValue == String {
    var title: String { get }
    var color: Color { get }
}

extension FilterItem {
    var title: String {
        return rawValue.capitalized
    }
}

struct FilterCategoriesView<T: FilterItem>: View {
    
    @Binding var selectedCategories: Set<T>
        
    let categories: [T]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { reader in
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        FilterButtonView(
                            category: category,
                            isSelected: self.selectedCategories.contains(category),
                            onTap: self.onTap
                        )
                            
                            .padding(.leading, category == self.categories.first ? 16 : 0)
                            .padding(.trailing, category == self.categories.last ? 16 : 0)
                        
                    }
                }
                .onAppear {
                    if let firstSelected = self.categories.first(where: { self.selectedCategories.contains($0) }) {
                        reader.scrollTo(firstSelected.id, anchor: .leading)
                    }                    
                }
            }
        }
        .padding(.vertical)
    }
    
    func onTap(category: T) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

struct FilterButtonView<T: FilterItem>: View {
    
    var category: T
    var isSelected: Bool
    var onTap: (T) -> ()
    
    var body: some View {
        Button(action: {
            self.onTap(self.category)
        }) {
            HStack(spacing: 8) {
                Text(category.title)
                    .fixedSize(horizontal: true, vertical: true)
                
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
                
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? category.color : Color(UIColor.lightGray), lineWidth: 1))
                .frame(height: 44)
        }
        .foregroundColor(isSelected ? category.color : Color(UIColor.gray))
    }
    
}


struct FilterCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        FilterCategoriesView(selectedCategories: .constant(Set()), categories: Category.allCases)
    }
}
