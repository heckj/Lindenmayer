//
//  EmptyModuleSummaryView.swift
//
//
//  Created by Joseph Heck on 1/13/22.
//

import SwiftUI

/// An empty view that takes up the same space as a module summary view.
public struct EmptyModuleSummaryView: View {
    let size: SummarySizes
    public var body: some View {
        switch size {
        case .medium:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        case .large:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        case .touchable:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        default:
            Color.clear
                .frame(width: size.rawValue, height: size.rawValue, alignment: .center)
        }
    }

    public init(size: SummarySizes) {
        self.size = size
    }
}

struct EmptyModuleSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SummarySizes.allCases, id: \.self) { sizeChoice in
            EmptyModuleSummaryView(size: sizeChoice)
        }
    }
}
