//
//  HomeViewController.swift
//  Healthy Breath
//
//  Created by Saikumar Gunishetti on 14/07/22.
//

import UIKit
// import this
import AVFoundation

// create a sound ID, in this case its the tweet sound.
let systemSoundID: SystemSoundID = 1057

struct BreathParameters {
    var breathInTime: Int = 5
    var breathInHoldTime = 10
    var breathOutTime: Int = 10
    var breathOutHoldTime = 5
    
    mutating func clear() {
        breathInTime = 0
        breathInHoldTime = 0
        breathOutTime = 0
        breathOutHoldTime = 0
    }
}

//let timeUnit = 1

enum BreathState {
    case notBreathing
    case inhale
    case holdInhale
    case exhale
    case holdExhale
    
    func nextState() -> BreathState {
        switch self {
            
        case .notBreathing:
            return .inhale
        case .inhale:
            return .holdInhale
        case .holdInhale:
            return .exhale
        case .exhale:
            return .holdExhale
        case .holdExhale:
            return .inhale
        }
    }
}

class HomeViewController: UIViewController {
    
    var params = BreathParameters()
    var currentParameter = BreathParameters(breathInTime: 0, breathInHoldTime: 0, breathOutTime: 0, breathOutHoldTime: 0)
    var currentState = BreathState.notBreathing
    var cycleCount = 0
    
    weak var timer: Timer? = nil
    
    
    @IBOutlet weak var breathInCountLabel: UILabel!
    @IBOutlet weak var breathOutCountLabel: UILabel!
    @IBOutlet weak var breathInHoldCountLabel: UILabel!
    @IBOutlet weak var breathOutHoldCountLabel: UILabel!
    @IBOutlet weak var cycleCountLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func StartAndStopButton(_ sender: Any) {
        
        if currentState == .notBreathing && timer == nil {
            
            startButton.setTitle("Stop", for: .normal)
            currentParameter = params
            updateUI()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleTimer(_:)), userInfo: nil, repeats: true)
        } else {
            startButton.setTitle("Start", for: .normal)
            currentState = .notBreathing
            timer?.invalidate()
            timer = nil
        }
        
    }
    @objc func handleTimer(_ timer: Timer) {
        switch currentState {
        case .notBreathing:
            currentState = .inhale
        case .inhale:
            if currentParameter.breathInTime > 1 {
                currentParameter.breathInTime -= 1
            } else {
                currentParameter.breathInTime = 0
                currentState = .holdInhale
                // to play sound
                AudioServicesPlaySystemSound(systemSoundID)
            }
        case .holdInhale:
            if currentParameter.breathInHoldTime > 1 {
                currentParameter.breathInHoldTime -= 1
            } else {
                currentParameter.breathInHoldTime = 0
                currentState = .exhale
                // to play sound
                AudioServicesPlaySystemSound(systemSoundID)
            }
        case .exhale:
            if currentParameter.breathOutTime > 1 {
                currentParameter.breathOutTime -= 1
            } else {
                currentParameter.breathOutTime = 0
                currentState = .holdExhale
                // to play sound
                AudioServicesPlaySystemSound(systemSoundID)
            }
        case .holdExhale:
            // some code
            if currentParameter.breathOutHoldTime > 1 {
                currentParameter.breathOutHoldTime -= 1
            } else {
                currentParameter.breathOutHoldTime = 0
                currentState = .inhale
                currentParameter = params
                cycleCount += 1
                // to play sound
                AudioServicesPlaySystemSound(systemSoundID)
            }
        }
        updateUI()
    }
    

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
            if parent == nil {
                reset()
            }
    }
    
    fileprivate func reset() {
        startButton.setTitle("Start", for: .normal)
        currentState = .notBreathing
        timer?.invalidate()
        timer = nil
        cycleCount = 0
        currentParameter = params
        updateUI()
    }
    
    @IBAction func ResetCycleCountButton(_ sender: Any) {
        reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentParameter = params
        updateUI()
    }

    private func updateUI() {
        
        breathInCountLabel.text = "\(currentParameter.breathInTime)"
        breathOutCountLabel.text = "\(currentParameter.breathOutTime)"
        breathInHoldCountLabel.text = "\(currentParameter.breathInHoldTime)"
        breathOutHoldCountLabel.text = "\(currentParameter.breathOutHoldTime)"
        cycleCountLabel.text = "\(cycleCount)"
    }

}
