// Developed by Artem Bartle

import SwiftUI

enum Month: String, CaseIterable, FilterItem {
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    var color: Color {
        return Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
    }
    
    init(date: Date) {
        let month = Calendar.current.component(.month, from: date)
        self = Month.allCases[month - 1]
    }
}

extension Month: Identifiable {
    var id: String { rawValue }
}

extension Date {
    var month: Month {
        let month = Calendar.current.component(.month, from: self)
        return Month.allCases[month - 1]
    }
}
