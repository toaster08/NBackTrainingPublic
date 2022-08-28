//
//  ViewController.swift
//  NBackTraining
//  Created by 山田　天星 on 2022/05/24.
//

import UIKit
import Foundation
import Lottie
import GoogleMobileAds
import AVFoundation
import SafariServices

protocol ViewDelegate: AnyObject {
    func configureNumberButtonInteraction(flag: Bool)
    func stopSound()
}

final class MainViewController: UIViewController, ViewDelegate {
    typealias ButtonNumber = Int
    
    var nBackCountForNextAnswerStart: Int?
    var practiceNCount: Int = 0

    var userSetting: UserSetting?
    var resultAlert: ResultAlert?
    
    //MARK: - notification for DataBinding
    let notificationCenter = NotificationCenter()
    let notificationCenterDefault = NotificationCenter.default
    
    //MARK: - ViewModel
    private lazy var viewModel = ViewModel(notificationCenter: notificationCenter, view: self)
    
    //MARK: - progress
    var progressDuration: Float = 1
    var progressTimer:Timer!
    
    //MARK: - sound
    private var correctSoundAudioPlayer : AVAudioPlayer!
    private var incorrectSoundAudioPlayer : AVAudioPlayer!
    private var clearSoundAudioPlayer : AVAudioPlayer!
    
    //MARK: - feedback
    let generator = UINotificationFeedbackGenerator()
    
    //TODO: LottieAnimation
    private var animationView = AnimationView()
    
    //TODO: GoogleAds
    var bannerView: GADBannerView!
    @IBOutlet weak var bannerParentView: UIView!
    
    //MARK: Problem
    @IBOutlet weak private var inputProblemLabel: UILabel!
    @IBOutlet weak var inputGuideLabel: UILabel!
    
    @IBOutlet weak private var outputProblemLabel: UILabel!
    @IBOutlet weak var outputGuideLabel: UILabel!
    
    @IBOutlet weak private var inputProblemLabelView: UIView!
    @IBOutlet weak private var currentQuestionLabelView: UIView!
    
    //MARK: - NumberButton
    private var numberButtons: [UIButton] {
        return [oneButton,
                twoButton,
                threeButton,
                fourButton,
                fiveButton,
                sixButton,
                sevenButton,
                eightButton,
                nineButton]
    }
    @IBOutlet weak private var oneButton: UIButton!
    @IBOutlet weak private var twoButton: UIButton!
    @IBOutlet weak private var threeButton: UIButton!
    @IBOutlet weak private var fourButton: UIButton!
    @IBOutlet weak private var fiveButton: UIButton!
    @IBOutlet weak private var sixButton: UIButton!
    @IBOutlet weak private var sevenButton: UIButton!
    @IBOutlet weak private var eightButton: UIButton!
    @IBOutlet weak private var nineButton: UIButton!
    
    @IBOutlet weak var answerTimerProgressView: UIProgressView!
    
    //MARK: - PreSetButton
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var currentNBackNumberButton: UIButton!
    @IBOutlet weak var buyOptionButton: UIButton!
    @IBOutlet weak var ruleDecriptionButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var spare1Button: UIButton!
    @IBOutlet weak var spare2Button: UIButton!
    
    //TODO: 未実装のボタン
    var nonFunctionalButton: [UIButton] {
        [spare1Button,
         spare2Button,
         settingButton,
         buyOptionButton]
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configure()
        
        nonFunctionalButton
            .forEach {
                $0.isUserInteractionEnabled = false
            }
        
        playButton
            .addTarget(
                self,
                action: #selector(playButtonTapped),
                for: .touchUpInside
            )
        
        privacyPolicyButton
            .addTarget(
                self,
                action: #selector(privacyPolicyButtonTapped),
                for: .touchUpInside
            )
        
        shareButton
            .addTarget(
                self,
                action: #selector(shareResult),
                for: .touchUpInside)
        
        //バックグラウンドに映った場合はリセット
        notificationCenterDefault
            .addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.initialize()
            }
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(updateInputProblemLabel),
                name: .inputProblem,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(updateOutputProblemLabel),
                name: .outputProblem,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(respondAnswer),
                name: .answerNotification,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(respondState),
                name: .stateNotification,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(respondResult),
                name: .resultNotification,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(reloadProgressView),
                name: .progressNotification,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(updateNBackLevel),
                name: .nbackLevelNotification,
                object: nil
            )
        
        notificationCenter
            .addObserver(
                self,
                selector: #selector(updateUserSetting),
                name: .userSettingNotification,
                object: nil
            )
        
        viewModel.initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        initialize()
    }
    
    //MARK: configure
    private func configure() {
        numberButtons.forEach {
            $0.addTarget(
                self,
                action: #selector(numberButtonTapped),
                for: .touchUpInside)
        }
        
        
        
        //MARK: Sound
        configureEffectSound()
        configureGADBanner()
    }
    
    func configureNumberButtonInteraction(flag: Bool) {
        numberButtons.forEach { $0.isUserInteractionEnabled = flag }
    }
    
    func set(NBackLevel: Int) {
        let levelString = String(NBackLevel)
        nBackCountForNextAnswerStart = NBackLevel
        practiceNCount = 0
        
        currentNBackNumberButton.configurationUpdateHandler = { button in
            var config = button.configuration
            config?.title = levelString
            config?.attributedTitle?.font = UIFont.systemFont(ofSize: 50)
            button.configuration = config
        }
    }
    
    private func setup() {
        let questionLabel = [outputProblemLabel, inputProblemLabel]
        let questionView = [currentQuestionLabelView, inputProblemLabelView]
        
        questionView.forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = UIColor.white.cgColor
            $0?.layer.shadowColor = UIColor.gray.cgColor
            $0?.layer.shadowOffset = CGSize(width: 0, height: 1)
            $0?.layer.shadowOpacity = 0.6
        }
        
        questionLabel.forEach {
            $0?.layer.cornerRadius = 20
        }
        
        switchButton(in: .notPlay)
        bannerParentView.backgroundColor = UIColor.clear
    }
    
    private func initialize() {
        //View
        inputProblemLabel.text?.removeAll()
        inputProblemLabel.backgroundColor = .white
        inputProblemLabelView.backgroundColor = .white
        inputProblemLabel.textColor = .black
        inputGuideLabel.isHidden = false
        
        outputProblemLabel.text?.removeAll()
        outputProblemLabel.backgroundColor = .white
        currentQuestionLabelView.backgroundColor = .white
        outputProblemLabel.textColor = .black
        outputGuideLabel.isHidden = false
        
        initializeProgress()
        
        
        //ViewModel
        //        viewModel.initialize()
    }
    
    @objc private func playButtonTapped() {
        viewModel.didTappedStartPlayButton()
    }
    
    @objc private func privacyPolicyButtonTapped() {
        let urlString = NSLocalizedString("privacyPolicyLocarizedURL",
                                          comment: "switch japanese/english privacy policy description")
        let url = URL(string: urlString)!
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: false, completion: nil)
    }
    
    @objc private func numberButtonTapped(button: UIButton)  {
        let buttonNumber = button.tag
        viewModel.didTappedNumberButton(input: buttonNumber)
    }
    
    private func switchButton(in state: State) {
        configureNumberButtonInteraction(flag: false)
        //
        let menuButton =  [playButton,
                           currentNBackNumberButton,
                           privacyPolicyButton,
                           ruleDecriptionButton,
                           settingButton,
                           spare1Button,
                           spare2Button,
                           settingButton,
                           buyOptionButton,
                           shareButton
        ]
        
        switch state {
        case .playing:
            menuButton.forEach { $0?.isHidden = true }
            //TODO: 未実装のButton
            nonFunctionalButton.forEach { $0.isUserInteractionEnabled = false }
        case .notPlay:
            menuButton.forEach { $0?.isHidden = false }
            nonFunctionalButton.forEach { $0.isUserInteractionEnabled = false }
            
        }
    }
    
    private func announceResult(accracy: Int) {
        self.initialize()
        
        if accracy >= 80 {
            if ((userSetting?.sound) != nil) {
                clearSoundAudioPlayer.play()
            }
        }
        
        resultAlert = ResultAlert()
        resultAlert!.show(with: accracy,
                         on: self)
    }
    
    //MARK: - ProgressView/Timer
    private func initializeProgress() {
        progressDuration = 1.0
        answerTimerProgressView.setProgress(progressDuration, animated: false)
    }
    
    private func startProgressTimer() {
        progressTimer
        = Timer
            .scheduledTimer(
                withTimeInterval: 0.001,
                repeats: true) { [weak self] _ in
                    self?.doneProgress()
                }
    }
    
    private func doneProgress() {
        let milliSecondProgress = 0.0003333
        progressDuration -= Float(milliSecondProgress)
        answerTimerProgressView.setProgress(progressDuration, animated: true)
    }
    
    private func stopProgressTimer(){
        progressTimer.invalidate()
    }
    
    //MARK: - Alert
    @objc func dismissAlert() {
        resultAlert?.dismissAlert()
    }
    
    //MARK: - Lottie
    private func addAnimation(in view: UIView) {
        animationView = AnimationView(name: "99718-confetti-animation")
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        animationView.contentMode = .scaleToFill
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
}

//MARK: - Effect
extension MainViewController {
    
    //TODO: ここでon/offを切り分ける
    private func responseEffect(for judge: Answer) {
        switch judge {
            
        case .correct:
            if userSetting?.sound == true {
                correctSoundAudioPlayer.play()
            }
            
            if userSetting?.vibration == true {
                generator.notificationOccurred(.success)
            }
        case .incorrect:
            if userSetting?.sound == true {
                incorrectSoundAudioPlayer.play()
            }
            
            if userSetting?.vibration == true {
                generator.notificationOccurred(.error)
            }
        }
    }
    
    func crearEffect() {
        //TODO: Animation
        addAnimation(in: self.view)
        //TODO: Sound
        if ((userSetting?.sound) != nil) {
            clearSoundAudioPlayer.play()
        }
    }
    
    func stopSound() {
        [self.correctSoundAudioPlayer,
         self.incorrectSoundAudioPlayer]
            .forEach {
                if (($0?.isPlaying) != nil) {
                    $0?.stop()
                    $0?.currentTime = 0
                }
            }
    }
    
    private func stopEffect() {
        [correctSoundAudioPlayer,
         incorrectSoundAudioPlayer]
            .forEach {
                if (($0?.isPlaying) != nil) {
                    $0?.stop()
                    $0?.currentTime = 0
                }
            }
    }
    
    private func configureEffectSound(){
        //正解音
        let correctSoundFilePath = Bundle.main.path(forResource: "CorrectSound", ofType: "mp3")!
        let correctSound = URL(fileURLWithPath: correctSoundFilePath)
        //不正解音
        let incorrectSoundFilePath = Bundle.main.path(forResource: "IncorrectSound", ofType: "mp3")!
        let incorrectSound:URL = URL(fileURLWithPath: incorrectSoundFilePath)
        //クリア音声
        let clearSoundFilePath = Bundle.main.path(forResource: "ClearSound", ofType: "mp3")!
        let clearSound:URL = URL(fileURLWithPath: clearSoundFilePath)
        //AVAudioPlayerのインスタンス作成
        do {
            correctSoundAudioPlayer = try AVAudioPlayer(contentsOf: correctSound, fileTypeHint:nil)
            incorrectSoundAudioPlayer = try AVAudioPlayer(contentsOf: incorrectSound, fileTypeHint:nil)
            clearSoundAudioPlayer = try AVAudioPlayer(contentsOf: clearSound, fileTypeHint:nil)
        } catch(let error) {
            print(error)
        }
        //バッファに保持
        correctSoundAudioPlayer.prepareToPlay()
        incorrectSoundAudioPlayer.prepareToPlay()
        clearSoundAudioPlayer.prepareToPlay()
    }
}

//MARK: - Notification
extension MainViewController {
    
    @objc func updateInputProblemLabel(notification: Notification) {
        practiceNCount += 1
        
        guard let inputProblemString = notification.object as? String else {
            inputGuideLabel.isHidden = true
            inputProblemLabel.backgroundColor = .clear
            inputProblemLabelView.backgroundColor = .clear
            inputProblemLabel.text = "Answer"
            inputProblemLabel.textColor = .white
            inputProblemLabel.font = UIFont(name: inputProblemLabel.font.fontName, size: CGFloat(30))
            return
        }
        
        inputGuideLabel.isHidden = false
        inputProblemLabel.font = UIFont(name: inputProblemLabel.font.fontName, size: CGFloat(50))
        inputProblemLabel.textColor = .black
        inputProblemLabel.backgroundColor = .white
        inputProblemLabelView.backgroundColor = .white
        inputProblemLabel.text = inputProblemString
    }
    
    @objc func updateOutputProblemLabel(notification: Notification) {
        guard let outputProblemString = notification.object as? String else {
            outputGuideLabel.isHidden = true
            outputProblemLabel.backgroundColor = .clear
            currentQuestionLabelView.backgroundColor = .clear
            
            if nBackCountForNextAnswerStart != nil {
                if practiceNCount == nBackCountForNextAnswerStart {
                    outputProblemLabel.text = "Start next"
                }  else {
                    outputProblemLabel.text = "Remember"
                }
            } else {
                outputProblemLabel.text = "Remember"
            }
            
            outputProblemLabel.textColor = .white
            outputProblemLabel.font = UIFont(name: outputProblemLabel.font.fontName, size: CGFloat(30))
            
            
            return
        }
        
        outputGuideLabel.isHidden = false
        outputProblemLabel.font = UIFont(name: outputProblemLabel.font.fontName, size: CGFloat(50))
        outputProblemLabel.textColor = .black
        outputProblemLabel.backgroundColor = .white
        currentQuestionLabelView.backgroundColor = .white
        outputProblemLabel.text = outputProblemString
    }
    
    @objc func respondAnswer(notification: Notification) {
        guard let answer = notification.object as? Answer else { return }
        responseEffect(for: answer)
    }
    
    @objc func respondState(notification: Notification) {
        guard let state = notification.object as? State else { return }
        switchButton(in: state)
    }
    
    @objc func respondResult(notification: Notification) {
        guard let accuration = notification.object as? Int else { return }
        print(accuration)
        announceResult(accracy: accuration)
    }
    
    @objc func reloadProgressView(notification: Notification) {
        guard let on_off = notification.object as? Bool else { return }
        DispatchQueue.main.async { [weak self] in
            if on_off == true {
                self?.initializeProgress()
                self?.startProgressTimer()
            } else {
                self?.stopProgressTimer()
            }
        }
    }
    
    @objc func updateNBackLevel(notification: Notification) {
        guard let level = notification.object as? Int else { return }
        set(NBackLevel: level)
    }
    
    @objc func updateUserSetting(notification: Notification) {
        let userSetting = notification.object as? UserSetting
        self.userSetting = userSetting
    }
    
    @objc func shareResult() {
        //シェアするテキストを作成
        let text = "このゲームやってます"
        let hashTag = "#Nバック計算"
        let urlString = "https://apps.apple.com/us/app/nbacktraining/id1627478554"
        
        let completedText = text + "\n" + hashTag + "\n" + urlString
        //作成したテキストをエンコード
        let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        //エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }
}

//MARK: - GoogleAdoMob
extension MainViewController {
    func configureGADBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

#if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
#endif

        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
    }

    func addBannerViewToView(_ bannerView:GADBannerView){
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerParentView.addSubview(bannerView)
        bannerParentView.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 0).isActive = true
        bannerParentView.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 0).isActive = true
        bannerParentView.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 0).isActive = true
        bannerParentView.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: 0).isActive = true
    }
}
