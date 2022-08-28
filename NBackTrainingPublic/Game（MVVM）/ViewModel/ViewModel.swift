//
//  ViewModel.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/05/29.
//

import Foundation

enum ProblemError: Error {
    case empty
}

//TODO: 状態の扱い方がおかしい
enum State: CaseIterable {
    case playing
    case notPlay
}

extension Notification.Name {
    static let inputProblem = Notification.Name("inputProblem")
    static let outputProblem = Notification.Name("outputProblem")
    static let answerNotification = Notification.Name("answer")
    static let stateNotification = Notification.Name("state")
    static let resultNotification = Notification.Name("result")
    static let progressNotification = Notification.Name("progressNotification")
    static let durationNotification = Notification.Name("durationNotification")
    static let nbackLevelNotification = Notification.Name("nbackLevelNotification")
    static let userSettingNotification = Notification.Name("userSettingNotification")
    //Setiing
}

class ViewModel {
    //TODO: このケース名がおかしい
    enum AnswerTime {
        case inner
        case waiting
    }
    
    //Timer
    let answerTimeInterbal: Double = 3.0
    private var answerTimer: Timer!
    private let notificationCenter: NotificationCenter
    
    let usecase = GameUseCase()
    private var state: State
    weak var view: ViewDelegate!
    
    init(notificationCenter: NotificationCenter, view: ViewDelegate) {
        state = .notPlay
        self.notificationCenter = notificationCenter
        self.view = view
    }
    
    func initialize() {
        state = .notPlay
        usecase.initialize()
        
        notifyState()
        notifyNBackLevel()
    }
    
    func didTappedNumberButton(input: Int) {
        if checkEnableAnswer() {
            view.configureNumberButtonInteraction(flag: false)
        }
        stopAnswerTimeInterval()
        //通知
        notifySwitchingProgress(in: .waiting)
        notifyOutputProblem(in: .waiting)
        notifyAnswer(for: input)
        //待機時間
        waitingTimeForNext()
    }
    
    func didTappedStartPlayButton() {
        state = .playing
        view.configureNumberButtonInteraction(flag: false)
        notifyState()
        playing()
    }
    
    private func playing() {
        switch usecase.playing() {
        case .none:
            //通知
            notifyUserSetting()
            notifyInputProblem()
            notifyOutputProblem(in: .inner)
            notifySwitchingProgress(in: .inner)
            //回答開始
            enableAnswerTimeInterval()
            //ボタンのインタラクション
            if checkEnableAnswer() {
                view.configureNumberButtonInteraction(flag: true)
            }
            
        case .some(let grade):
            state = .notPlay
            stopAnswerTimeInterval()
            //結果の通知
            initialize()
            notify(grade: grade)
        }
    }
    
    private func save(for nbackCount: Int) {
        let setting = UserSettingRepository().load()
        
        if setting.levelOff {
            usecase.repository.save(nBackLevel: nbackCount)
        } else {
            if nbackCount > 20 {
                usecase.repository.save(nBackLevel: 20)
            } else if (3...20).contains(nbackCount) {
                usecase.repository.save(nBackLevel: nbackCount)
            }
        }
    }
    
    private func enableAnswerTimeInterval() {
        answerTimer
        = Timer
            .scheduledTimer(
                withTimeInterval: answerTimeInterbal,
                repeats: false) { [weak self] _ in
                    if self!.checkEnableAnswer() {
                        self?.notifyOutputProblem(in: .waiting)
                        self?.notifyDidNotAnswer()
                    }
                    self?.view.configureNumberButtonInteraction(flag: false)
                    self?.notifySwitchingProgress(in: .waiting)
                    self?.waitingTimeForNext()
                }
    }
    
    private func waitingTimeForNext() {
        Timer
            .scheduledTimer(
                withTimeInterval: 1.0,
                repeats: false
            ) { [weak self] _ in
                self?.view.stopSound()
                self?.playing()
            }
    }
    
    private func stopAnswerTimeInterval(){
        answerTimer?.invalidate()
    }
    
    func checkEnableAnswer() -> Bool {
        return usecase.answerTime()
    }
    
    func loadNBackLevel() -> Int {
        let nBackLevel = usecase.nBackCount
        return nBackLevel
    }
    
    private func notifyInputProblem() {
        let inputProblemString:String? = usecase.currentInputProblem?.expressionString ?? nil
        notificationCenter
            .post(
                name: .inputProblem,
                object: inputProblemString
            )
    }
    
    private func notifyOutputProblem(in time: AnswerTime) {
        switch time {
        case .inner:
            let outputProblemString: String?
            if checkEnableAnswer() {
                outputProblemString = "? □ ?"
            } else {
                outputProblemString = nil
            }
            
            notificationCenter
                .post(
                    name: .outputProblem,
                    object: outputProblemString
                )
            
        case .waiting:
            let outputProblemString = usecase.currentOutputProblem?.expressionString
            notificationCenter
                .post(
                    name: .outputProblem,
                    object: outputProblemString
                )
        }
    }
    
    //TODO: ここをまとめられるか？
    private func notifyAnswer(for input: Int) {
        let answer = usecase.didAnswered(inputNumber: input)
        notificationCenter
            .post(
                name: .answerNotification,
                object: answer
            )
    }
    
    private func notifyDidNotAnswer() {
        let answer = usecase.didNotAnswered()
        notificationCenter
            .post(
                name: .answerNotification,
                object: answer
            )
    }
    
    private func notifySwitchingProgress(in time: AnswerTime) {
        switch time {
        case .inner:
            notificationCenter
                .post(
                    name: .progressNotification,
                    object: true
                )
        case .waiting:
            notificationCenter
                .post(
                    name: .progressNotification,
                    object: false
                )
        }
    }
    
    private func notify(grade: Int) {
        notificationCenter
            .post(
                name: .resultNotification,
                object: grade
            )
    }
    
    private func notifyState() {
        notificationCenter
            .post(
                name: .stateNotification,
                object: state
            )
    }
    
    private func notifyNBackLevel() {
        let nbackLevel = usecase.nBackCount
        notificationCenter
            .post(
                name: .nbackLevelNotification,
                object: nbackLevel
            )
    }
    
    private func notifyUserSetting() {
        let setting = UserSettingRepository().load()
        notificationCenter
            .post(
                name: .userSettingNotification,
                object: setting,
                userInfo: nil
            )
    }
}
