//
//  GraphView.swift
//  Calculator
//
//  Created by Ziheng Chen on 2/1/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 50 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineColor: UIColor = UIColor.green { didSet { setNeedsDisplay() } }
    
    private var graphCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // the position of the function coordinate origin in the graph coordinate
    private var functionCoordinateOrigin: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // label if it's the first time to run the program, used for put functionCoordinateOrigin
    // to the center of the screen when launching the program
    private var firstTime: Bool = true

    // x vs y function
    var function: ((Double) -> Double)? = nil
    
    // handler for pinch recognizer
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            pointsPerUnit *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    // handler for tap recognizer
    func tapToGraphCenter(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            let tapLocation = tapRecognizer.location(in: self)
            functionCoordinateOrigin.x += (graphCenter.x - tapLocation.x)
            functionCoordinateOrigin.y += (graphCenter.y - tapLocation.y)
        default:
            break
        }
    }
    
    // handler for pan recognizer
    func moveGraph(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            functionCoordinateOrigin.x += translation.x
            functionCoordinateOrigin.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    // transform view X coordinate to function X coordinate
    private func viewXToFunctionX(with viewX: CGFloat) -> Double {
        return Double((viewX - functionCoordinateOrigin.x) / pointsPerUnit)
        
    }
    
    // transform function Y coordinate to view Y coordinate
    private func functionYToViewY(with functionY: Double) -> CGFloat {
        return CGFloat(Double(functionCoordinateOrigin.y) - ((functionY - 0) * Double(pointsPerUnit)))
    }
    
    private func pathForFunction() -> UIBezierPath? {
        let path = UIBezierPath()
        if function != nil {
            for viewX in stride(from: bounds.minX, through: bounds.maxX, by: 1/contentScaleFactor) {
                let functionX = viewXToFunctionX(with: viewX)
                let functionY = function!(functionX)
                let viewY = functionYToViewY(with: functionY)
                if viewX != bounds.minX {    // don't add line for the first time, only move to the edge point
                    path.addLine(to: CGPoint(x: viewX, y: viewY))
                }
                path.move(to: CGPoint(x: viewX, y: viewY))
            }
            path.lineWidth = lineWidth
            return path
        } else {
            return nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        var axesdrawer = AxesDrawer()
        axesdrawer.contentScaleFactor = contentScaleFactor
        
        if firstTime {  // put function coordinate origin to the center of the screen when first launching the program
            firstTime = false
            functionCoordinateOrigin = graphCenter
        }
        
        axesdrawer.drawAxes(in: rect, origin: functionCoordinateOrigin, pointsPerUnit: pointsPerUnit)
        if let pathForFunction = pathForFunction() {
            pathForFunction.stroke()
        }
    }
}
