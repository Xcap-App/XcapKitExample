//
//  CircleRenderer.swift
//  XcapKitExample
//
//  Created by scchn on 2023/2/24.
//

import Foundation

import XcapKit

class CircleRenderer: ObjectRenderer, Editable {
    
    private var circle: Circle?
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        .singleSection(items: 3, for: layout)
    }
    
    override func layoutDidUpdate() {
        guard let points = layout.first, points.count == 3 else {
            return
        }
        
        circle = .init(points[0], points[1], points[2])
    }
    
    override func makePreliminaryGraphics() -> [Drawable] {
        let graphics = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth, lineCap: .round), color: strokeColor) { path in
            path.addLines(between: layout.first ?? [])
        }
        
        return [graphics]
    }
    
    override func makeMainGraphics() -> [Drawable] {
        guard let circle = circle else {
            return []
        }
        
        let graphics = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth), color: strokeColor) { path in
            path.addCircle(circle)
        }
        
        return [graphics]
    }
    
    override func selectionTest(rect: CGRect) -> Bool {
        guard let circle = circle else {
            return false
        }
        
        return rect.selects(circle: circle)
    }
    
}
