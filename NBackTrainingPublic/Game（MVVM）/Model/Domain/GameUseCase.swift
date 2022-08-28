//
//  UseCase.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/05.
//

import Foundation

enum Answer {
    case correct
    case incorrect
}

class GameUseCase {
    let repository = UserSettingRepository()
    var nBackCount: Int
    //問題
    var currentInputProblem: Problem?
    var currentOutputProblem: Problem?
    //リスト
    var inputProblemList: [Problem]
    var outputProblemList: [Problem]
    var answerResults: [Answer]
    //回答回数
    var currentTrainingCount: Int
    //練習回数
    var defaultTrainingCount: Int {
        #if DEBUG
                2 + nBackCount
        #else
                20 + nBackCount
        #endif
    }
  
    init() {
        //初期のレベルを読み込み
        nBackCount = repository.loadNBackLevel()
        //初期化
        currentTrainingCount = 0
        //初期化
        inputProblemList = []
        outputProblemList = []
        answerResults = []
        //問題の生成
        setProblemList()
    }
    
    //答えることが可能になるタイミング
    func answerTime() -> Bool {
        currentTrainingCount > nBackCount ? true : false
    }
    //初期化
    func initialize() {
        //問題の初期化
        currentInputProblem = nil
        currentOutputProblem = nil
        //問題の初期化から生成
        inputProblemList = []
        outputProblemList = []
        setProblemList()
        //答案の初期化
        answerResults.removeAll()
        //カウント数を戻す
        currentTrainingCount = 0
    }
    //問題の初期化から生成
    private func initializeProblem() {
        inputProblemList.removeAll()
        outputProblemList.removeAll()
        setProblemList()
    }
    
    //TODO: テスト用と本番用に分けたい
    private func setProblemList() {
        for i in 1...defaultTrainingCount {
            let problem = Problem.init()
            inputProblemList.append(problem)
        }
    }
    
    //プレイする
    func playing() -> Int? {
        return stepNext()
    }
    
    //回答時間内に答えた場合
    func didAnswered(inputNumber: Int) -> Answer {
        let answer = judge(for: inputNumber)
        answerResults.append(answer)
        return answer
    }
    
    func didNotAnswered() -> Answer {
        answerResults.append(.incorrect)
        return .incorrect
    }
    
    func judge(for inputNumber: Int) -> Answer {
        let totalNumber = currentOutputProblem!.totalNumber
        if totalNumber == inputNumber {
            return .correct
        } else {
            return .incorrect
        }
    }
    
    private func stepNext() -> Int? {
        currentInputProblem = nil
        currentOutputProblem = nil
        incrementTrainigCount()
        
        if answerTime(), !outputProblemList.isEmpty {
            setInputProblem()
            setOutputProblem()
        } else if answerTime(), outputProblemList.isEmpty {
            return endGame()
        } else {
            setInputProblem()
        }
        
        return nil
    }
    
    private func incrementTrainigCount() {
        currentTrainingCount += 1
    }
    
    private func endGame() -> Int {
        let result = calculateAccuracy()
        evaluate(for: result)
        return result
    }
    
    private func setInputProblem() {
        if let currentInputProblem = inputProblemList.first {
            outputProblemList.append(currentInputProblem)
            self.currentInputProblem = currentInputProblem
            inputProblemList.removeFirst()
        }
    }
    
    private func setOutputProblem() {
        if let currentOutputProblem = outputProblemList.first {
            self.currentOutputProblem = currentOutputProblem
            outputProblemList.removeFirst()
        }
    }
    
    private func evaluate(for accracy: Int) {
        if accracy >= 80 {
            nBackCount += 1
        } else if accracy >= 60 {
            print("level not changed")
        } else {
            if nBackCount > 3 {
                nBackCount -= 1
            }
        }
        
        repository.save(nBackLevel: nBackCount)
    }
    private func calculateAccuracy() -> Int {
        let answerResultsCount = Double(answerResults.count)
        print("answerResultsCount:\(answerResultsCount)")

        let correctCount:Double = Double(answerResults.filter { $0 == .correct }.count)
        print("correctCount:\(correctCount)")
        
        let accuracyPercent = (correctCount / answerResultsCount) * 100
        let percent = Int(accuracyPercent)
        return percent
    }
}
