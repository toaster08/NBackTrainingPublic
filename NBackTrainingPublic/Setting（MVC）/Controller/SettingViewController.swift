//
//  SettingViewController.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/10.
//

import UIKit

//将来的にハーフモーダル
class SettingViewController: UIViewController {
    
    var userSetting: UserSetting {
        UserSettingRepository().load()
    }
    
    @IBOutlet weak var tableView: UITableView!
    //ここでrepositoryを読んで
    override func viewDidLoad() {
        super.viewDidLoad()
        //ここでrepositoryを読んでstructを取り出し、
        tableView.delegate = self
        tableView.dataSource = self
        tableView
            .register(
                UINib(nibName: "SettingTableViewCell",bundle: nil),
                forCellReuseIdentifier: "Cell"
            )
    }
}

extension SettingViewController: UITableViewDelegate,
                                 UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingGroup.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SettingElement.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SettingTableViewCell else { fatalError() }
        guard let row = SettingElement(rawValue: indexPath.row) else { fatalError() }
        
        let cellTitle = row.name
        let cellToggle = row.currentSwitch(in: self.userSetting)
        cell.configure(title: cellTitle, isOn: cellToggle) {[weak self] _ in
            let newUserSetting = self?.userSetting.update(in: row)
            UserSettingRepository().save(setting: newUserSetting)
        }
        
        return cell
    }
}
