//
//  ViewController.swift
//  Calculator
//
//  Created by Ziheng Chen on 1/10/17.
//  Copyright © 2017 edu.stanford.cs193p.zihengc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!      // calculator result display
    @IBOutlet weak var mathSequenceDisplay: UILabel!
 
    var userIsInTheMiddleOfTyping = false
    
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
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let mathSequence = brain.mathSequence {
            if brain.resultIsPending {
                mathSequenceDisplay.text = mathSequence + "..."
            } else {
                mathSequenceDisplay.text = mathSequence + "="
            }
        } else {
            mathSequenceDisplay.text = "0"
        }
    }
    
    // UIButton that clears everything of the calculator
    @IBAction func clearCalculator(_ sender: UIButton) {
        brain.clear()
        display.text = "0"
        mathSequenceDisplay.text = "0"
        userIsInTheMiddleOfTyping = false
    }
}





