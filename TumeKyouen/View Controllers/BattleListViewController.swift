//
//  BattleListViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/14.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import SVProgressHUD

class BattleListViewController: UIViewController {

    let cellIdentifier = "battleCell"

    @IBOutlet weak var tableView: UITableView!

    struct Battle {
        let id: Int
        let name: String
    }
    var battleList: [Battle]?

    override func viewDidLoad() {
        tableView.registerNib(UINib(nibName: "BattleListCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.dataSource = self

        TumeKyouenServer().fetchRealtimeBattleRooms { response, error in
            if error != nil {
                // 通信が異常終了
                SVProgressHUD.showErrorWithStatus(error.localizedDescription)
            }
            self.battleList = []
            for item in response {
                if let dic = item as? NSDictionary {
                    guard let id = dic["size"] as? Int else {
                        continue
                    }
                    guard let nameDic = dic["player1"] as? Dictionary<String, String> else {
                        continue
                    }
                    let battle = Battle(id: id, name: nameDic["scscreenName"]!)
                    self.battleList?.append(battle)
                }
            }
            self.tableView.reloadData()
        }
    }
}

extension BattleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let battleList = battleList else {
            return 0
        }

        return battleList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? BattleListCell

        cell!.idLabel?.text = String(battleList![indexPath.row].id)
        cell!.nameLabel?.text = String(battleList![indexPath.row].name)

        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
}
