//
//  BasicToggleButtonFigureTheme.swift
//  DesignSystemBookApp
//
//  Created by DOYEON LEE on 6/14/24.
//

import SwiftUI

struct BasicToggleButtonFigureTheme: ToggleButtonFigureTheme {
    private let _shape: BasicToggleButtonShape
    
    init(shape: BasicToggleButtonShape) {
        self._shape = shape
    }
    
    func innnerImageSize() -> FrameOffset {
        switch _shape {
        case .round: return .init(all: 18)
        case .square: return .init(all: 18)
        case .circle: return .init(all: 16)
        }
    }
    
    func padding() -> GapOffset {
        switch _shape {
        case .round: return .init(all: 3)
        case .square: return .init(all: 3)
        case .circle: return .init(all: 4)
        }
    }
    
    func rounded() -> RoundedOffset {
        switch _shape {
        case .round: return .init(all: 4)
        case .square: return .init(all: 2)
        case .circle: return .init(all: .infinity)
        }
    }
    
    func shape() -> AnyShape {
        switch _shape {
        case .square:
            let round = rounded()
            return RoundedRectangle(cornerRadius: round.max).asAnyShape()
        case .round:
            let round = rounded()
            return RoundedRectangle(cornerRadius: round.max).asAnyShape()
        case .circle:
            return Circle().asAnyShape()
        }
    }
    
    func labelTypo() -> Typo {
        return .body1m
    }
}
