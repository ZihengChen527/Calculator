//
//  ViewController.swift
//  Calculator
//
//  Created by Ziheng Chen on 1/10/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var mathSequenceDisplay: UILabel!
    @IBOutlet weak var variableDisplay: UILabel!
    var userIsInTheMiddleOfTyping = false
    let variableName = "M"
    var currentState: (result: Double?, description: String) = (nil, " ")
    
    // gets the digit number pressed from the sender's title
    @IBAction func touchDigit(_ sender: UIButton) {
        let userInputContent = sender.currentTitle!
        if userInputContent != "." {
            let digit = userInputContent;
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
        } else {
            if display.text?.contains(".") == false {
                display.text! += "."
                userIsInTheMiddleOfTyping = true
            }
        }
    }
    
    // the value of the text in the display UILabel as a Double
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }   
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    // operation buttons
    @IBAction func performOperation(_ sender: UIButton) {
        if sender.currentTitle == variableName {
            currentState = brain.setOperand(variable: variableName)
        }
        if sender.currentTitle == "→\(variableName)" {
            if variables[variableName] != nil {
                variables[variableName] = displayValue
                variableDisplay.text = "\(variableName)=\(displayValue)"
                currentState = brain.evaluate(using: variables)
            }
            userIsInTheMiddleOfTyping = false
        }
        if userIsInTheMiddleOfTyping {
            currentState = brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            currentState = brain.performOperation(mathematicalSymbol)
        }
        displayResultDescription()
    }
    
    // undo button
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if display.text?.characters.count == 1 {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            } else {
                display.text?.characters.removeLast()
            }
        } else {
            currentState = brain.undo()
            displayResultDescription()
        }
    }
    
    // UIButton that clears everything of the calculator
    @IBAction func clearCalculator(_ sender: UIButton) {
        brain.clear()
        display.text = "0"
        mathSequenceDisplay.text = " "
        variableDisplay.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    private func displayResultDescription() {
        if let result = currentState.result {
            displayValue = result
        }
        
        if currentState.result == nil  {
            mathSequenceDisplay.text = currentState.description + "..."
            showGraph.setTitleColor(UIColor.lightGray, for: UIControlState.normal)   // show gray on graphing button when graphing is disabled
        } else {
            mathSequenceDisplay.text = currentState.description + "="
            showGraph.setTitleColor(UIColor.blue, for: UIControlState.normal)  // show blue on graphing button when graphing is abled
        }
    }
    
    @IBOutlet weak var showGraph: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show graph":
                var destinationController = segue.destination
                if let navigationController = destinationController as? UINavigationController {
                    destinationController = navigationController.visibleViewController ?? destinationController
                }
                if let graphViewController = destinationController as? GraphViewController {
                    // set the x vs y function in graphView
                    if (variables[self.variableName] != nil) {  // graph the x vs y function only when 'M' is in the formula
                        graphViewController.function = { [unowned self] (independentVariable: Double) -> Double in
                            variables[self.variableName] = independentVariable
                            return self.brain.evaluate(using: variables).result!
                        }
                    } else {
                        graphViewController.function = nil
                    }
                    // set the title of the graph view showing the function being drawn
                    graphViewController.navigationItem.title = currentState.description
                }
            default:
                break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        // if result is pending, then disable segue
        if identifier == "show graph" && currentState.result == nil {
            return false
        }
        return true
    }
}
