//
//  BattleListViewController.swift
//  TumeKyouen
//
//  Created by 石倉 昇 on 2016/11/14.
//  Copyright © 2016年 noboru. All rights reserved.
//

import UIKit
import SVProgressHUD
import APIKit

class BattleListViewController: UIViewController {

    let cellIdentifier = "battleCell"

    @IBOutlet weak var tableView: UITableView!

    var battleList: [RealtimeBattleRoom]?

    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(BattleListViewController.tapAdd(_ :)))

        tableView.registerNib(UINib(nibName: "BattleListCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        fetchList()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPathForSelectedRow, animated: true)
        }
    }

    func tapAdd(_: AnyObject) {
        let request = PostRealtimeBattleRoomRequest()
        Session.sendRequest(request) { result in
            switch result {
            case .Success:
                self.fetchList()
            case .Failure(.ResponseError(let error as UnAuthorizedError)):
                print("error2: \(error)")
                let alert = UIAlertController.alert("alert_unauthorized")
                self.presentViewController(alert, animated: true, completion: nil)
            case .Failure(let error):
                print("error1: \(error)")
            }
        }
    }

    private func fetchList() {
        let request = RealtimeBattleRoomRequest()
        Session.sendRequest(request) { result in
            switch result {
            case .Success(let response):
                self.battleList = response
                self.tableView.reloadData()
            case .Failure(let error):
                print("error: \(error)")
            }
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
        cell!.nameLabel?.text = String(battleList![indexPath.row].player1.screenName)

        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = battleList![indexPath.row]

        let kyouenStoryboard: UIStoryboard = UIStoryboard(name:"BattleStoryboard", bundle:NSBundle.mainBundle())
        let kyouenViewController: UIViewController? = kyouenStoryboard.instantiateInitialViewController()
        if let vc = kyouenViewController as? BattleViewController {
            vc.currentModel = model
            self.navigationController?.pushViewController(kyouenViewController!, animated: true)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
}
