import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Properties
    
    var audioPlayer: AVAudioPlayer?
    var remainingTime = 0
    var countDownTimer = Timer()
    var hiDuration: Int = 1
    var liDuration: Int = 1
    var totalCycles: Int = 1

    @IBOutlet var timerStackView: UIStackView!
    @IBOutlet var timerView: UIView!
    @IBOutlet var highIntensityDurationPicker: UIPickerView!
    @IBOutlet var lowIntensityDurationPicker: UIPickerView!
    @IBOutlet var numberOfCyclesPicker: UIPickerView!
    
    @IBOutlet var timeRemaining: UILabel!
    
    let durationOptions = [Int](1...100)
    let numberOfCyclesOptions = [Int](1...50)
    
    var highIntensityDuration = 0
    var lowIntensityDuration = 0
    var numberOfCycles = 1
    
    var timer: Timer?
    var isTimerRunning = false
    var currentInterval = 0
    var currentCycle = 1
    var currentState = State.highIntensity
    

    @IBOutlet weak var timerLabel: UILabel!
    
    let startButtonTapped = UIButton()
    
    // MARK: - IBActions
    
 
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
    
        if isTimerRunning {
            return
        }
        playSound(named: "ping", duration: 0.5)
        startTimer()
        startCountdown()
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        if !isTimerRunning {
            return
        }
        playSound(named: "ping", duration: 0.5)
        playSound(named: "HI_Alarm", duration: 0.0)
        playSound(named: "LI_Alarm", duration: 0.0)
        playSound(named: "End_Alarm", duration: 0.0)
        timer?.invalidate()
        countDownTimer.invalidate()
        isTimerRunning = false
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        playSound(named: "ping", duration: 0.5)
        playSound(named: "HI_Alarm", duration: 0.0)
        playSound(named: "LI_Alarm", duration: 0.0)
        playSound(named: "End_Alarm", duration: 0.0)
        timer?.invalidate()
        countDownTimer.invalidate()
        isTimerRunning = false
        currentInterval = 0
        currentCycle = 0
        
        
        currentState = .highIntensity
        updateTimerLabel()
    }
    
    func playSound(named soundName: String, duration: Double) {
      guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }

      do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

        guard let audioPlayer = audioPlayer else { return }

        audioPlayer.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
          audioPlayer.stop()
        }
      } catch {
        print(error.localizedDescription)
      }
    }

    // MARK: - Private methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            
                self?.currentInterval += 1
                self?.updateTimerLabel()
           
            if self?.currentInterval == self?.highIntensityDuration && self?.currentState == .highIntensity {
                self?.playSound(named: "HI_Alarm", duration: 3.0)
                self?.currentState = .lowIntensity
                self?.currentInterval = 0
            } else if self?.currentInterval == self?.lowIntensityDuration && self?.currentState == .lowIntensity {
                self?.currentCycle += 1
                if self?.currentCycle == self?.numberOfCycles {
                    self?.playSound(named: "LI_Alarm", duration: 3.0)
                    self?.timer?.invalidate()
                    self?.isTimerRunning = false
                } else {
                    self?.playSound(named: "End_Alarm", duration: 3.0)
                    self?.currentState = .highIntensity
                    self?.currentInterval = 0
                }
            }
        }
        
        isTimerRunning = true
        
    }
    
    private func updateTimerLabel() {
        let minutes = currentInterval / 60
        let seconds = currentInterval % 60
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        let timeString = "\(minutesString):\(secondsString)"
        
        switch currentState {
        case .highIntensity:
            timerLabel.textColor = .yellow
        case .lowIntensity:
            timerLabel.textColor = UIColor(red: 25/255, green: 150/255, blue: 240/255, alpha: 1)
        }
        
        timerLabel.text = timeString
    }
       
    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      if pickerView == highIntensityDurationPicker {
        return durationOptions.count
      } else if pickerView == lowIntensityDurationPicker {
        return durationOptions.count
      } else {
        return numberOfCyclesOptions.count
      }
    }
    
    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      if pickerView == highIntensityDurationPicker {
        return "\(durationOptions[row]) seconds"
      } else if pickerView == lowIntensityDurationPicker {
        return "\(durationOptions[row]) seconds"
      } else {
        return "\(numberOfCyclesOptions[row]) cycles"
      }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      if pickerView == highIntensityDurationPicker {
        highIntensityDuration = durationOptions[row]

          hiDuration = Int(highIntensityDuration)
          
      } else if pickerView == lowIntensityDurationPicker {
        lowIntensityDuration = durationOptions[row]

          liDuration = Int(lowIntensityDuration)
          
      } else {
        numberOfCycles = numberOfCyclesOptions[row]
          
          totalCycles = Int(numberOfCycles)
        
      }

    }
    
    func startCountdown() {
        remainingTime = (hiDuration + liDuration) * totalCycles
        
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (countDownTimer) in
            
            self.remainingTime -= 1
            if self.remainingTime <= 0 {
                self.countDownTimer.invalidate()
                self.timer?.invalidate()
                self.isTimerRunning = false
                self.currentInterval = 0
                self.currentCycle = 0
                print("Countdown finished!")
            }
            print(self.remainingTime)
            
            //Calculating minutes and seconds
            let minutes = (self.remainingTime / 60) % 60
            let seconds = self.remainingTime % 60
            
            //update the label
            if seconds < 10 {
                self.timeRemaining.text = "\(minutes) : 0\(seconds)"
            } else {
                self.timeRemaining.text = "\(minutes) : \(seconds)"
            }

            

            
            self.isTimerRunning = true
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      var label: UILabel

      if let view = view as? UILabel {
        label = view
      } else {
        label = UILabel()
      }

      label.textColor = .white
      label.textAlignment = .center
      label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)

      if pickerView == highIntensityDurationPicker {
        label.text = "\(durationOptions[row]) seconds"
      } else if pickerView == lowIntensityDurationPicker {
        label.text = "\(durationOptions[row]) seconds"
      } else {
        label.text = "\(numberOfCyclesOptions[row]) cycles"
      }

      return label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        timerView.layer.cornerRadius = 20
        timerStackView.layer.cornerRadius = 10
        numberOfCyclesPicker.dataSource = self
        numberOfCyclesPicker.delegate = self
        
        highIntensityDurationPicker.dataSource = self
        highIntensityDurationPicker.delegate = self
        
        lowIntensityDurationPicker.dataSource = self
        lowIntensityDurationPicker.delegate = self
        
       }
        
}



// MARK: - State

enum State {
    case highIntensity
    case lowIntensity
}

