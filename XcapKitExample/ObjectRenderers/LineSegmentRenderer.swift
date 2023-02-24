//
//  LineSegmentRenderer.swift
//  XcapKitExample
//
//  Created by scchn on 2023/2/24.
//

import Foundation

import XcapKit

class LineSegmentRenderer: ObjectRenderer, Editable {
    
    private var line: Line?
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        .singleSection(items: 2, for: layout)
    }
    
    override func layoutDidUpdate() {
        guard let points = layout.first, points.count == 2 else {
            return
        }
        
        line = Line(start: points[0], end: points[1])
    }
    
    override func makePreliminaryGraphics() -> [Drawable] {
        []
    }
    
    override func makeMainGraphics() -> [Drawable] {
        guard let line = line else {
            return []
        }
        
        let graphics = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth, lineCap: .round), color: strokeColor) { path in
            path.addLine(line)
        }
        
        return [graphics]
    }
    
    override func selectionTest(rect: CGRect) -> Bool {
        guard let line = line else {
            return false
        }
        
        return rect.selects(line: line)
    }
    
}
