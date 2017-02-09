//
//  GraphViewController.swift
//  Calculator
//
//  Created by Ziheng Chen on 2/1/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var function: ((Double) -> Double)? = nil
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.function = function
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale(byReactingTo:)))
            graphView.addGestureRecognizer(pinchGestureRecognizer)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.tapToGraphCenter(byReactingTo:)))
            tapGestureRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGestureRecognizer)
            
            let panGestureRecoginzer = UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.moveGraph(byReactingTo:)))
            graphView.addGestureRecognizer(panGestureRecoginzer)
        }
    }
    
}



