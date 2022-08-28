//
//  repository.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/04.
//

import Foundation

class UserSettingRepository {
    
    let nBackString = "nBack"
    
    let userdefaluts = UserDefaults.standard
    
    func save(nBackLevel: Int) {        
        userdefaluts.set(nBackLevel, forKey: nBackString)
    }

    func loadNBackLevel() -> Int {
        let nbackLevel = userdefaluts.integer(forKey: nBackString)
        if nbackLevel >= 3 {
            return nbackLevel
        } else {
            return 3
        }
    }
    
    func save(setting: UserSetting?) {
        do {
            guard let setting = setting else {
                print("setting is nil")
                return
            }

            let settingData = try JSONEncoder().encode(setting)
            userdefaluts.set(settingData, forKey: "SettingData")
        } catch {
            print("failed to encode")
        }
    }
    
    func load() -> UserSetting {
        do {
            guard let data = userdefaluts.data(forKey: "SettingData") else {
                return UserSetting.defaultSet
            }
            
            let settingData = try JSONDecoder().decode(UserSetting.self, from: data)
            return settingData
        } catch {
            return UserSetting.defaultSet
        }
    }
}
