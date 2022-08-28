//
//  SettingTableViewCell.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/07/23.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    var switchedCoompletion: ((Bool) -> Void)?
    @IBOutlet weak var rowTitleLabel: UILabel!
    @IBOutlet weak var settingToggleSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        settingToggleSwitch
            .addTarget(
                self,
                action: #selector(settingToggleSwitchTouchUpInside),
                for: .touchUpInside
            )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(title: String, isOn: Bool, completion: @escaping ((Bool) -> Void)) {
            rowTitleLabel.text = title
            settingToggleSwitch.isOn = isOn
            switchedCoompletion = completion
        }
        
        @objc func settingToggleSwitchTouchUpInside() {
            guard let switchedCoompletion = switchedCoompletion else { return }
            let result = settingToggleSwitch.isOn
            return switchedCoompletion(result)
        }
    
}
