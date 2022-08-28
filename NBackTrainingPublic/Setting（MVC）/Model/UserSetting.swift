//
//  Setting.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/07/23.
//

import Foundation

enum SettingGroup: CaseIterable {
    case game
}

enum SettingElement: Int, CaseIterable {
    case levelOff
    case speed
    case sound
    case vibration
    case challenge
    
    var name: String {
        switch self {
        case .levelOff: return "Without Back limit"
        case .speed: return "Timer Speed"
        case .sound: return "Sound"
        case .vibration: return "Vibration"
        case .challenge: return "Challenge"
        }
    }
    
    func currentSwitch(in setting: UserSetting) -> Bool {
        switch self {
        case .levelOff: return setting.levelOff
        case .speed: return setting.speed
        case .sound: return setting.sound
        case .vibration: return setting.vibration
        case .challenge: return setting.challenge
        }
    }
}

struct UserSetting: Codable {
    let levelOff: Bool
    let speed: Bool
    let sound: Bool
    let vibration: Bool
    let challenge: Bool
    
    func update(in row: SettingElement) -> UserSetting {
        var currentLevelOff = self.levelOff
        var currentSpeed = self.speed
        var currentSound = self.sound
        var currentVibration = self.vibration
        var currentChallenge = self.challenge
        
        switch row {
        case .levelOff: currentLevelOff.toggle()
        case .speed: currentSpeed.toggle()
        case .sound: currentSound.toggle()
        case .vibration: currentVibration.toggle()
        case .challenge: currentChallenge.toggle()
        }
        
        return UserSetting(
            levelOff: currentLevelOff,
            speed: currentSpeed,
            sound: currentSound,
            vibration: currentVibration,
            challenge: currentChallenge
        )
    }
    
    static let defaultSet = UserSetting(levelOff: true,speed: true,sound: true,vibration: true,challenge: true)
}
