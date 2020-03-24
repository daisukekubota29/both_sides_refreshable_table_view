//
//  ViewController.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

class Items {
    enum AddType {
        case top
        case bottom
    }
    static let fetchCount: Int = 20
    private static let startIndex: Int = 1000
    private static let endIndex: Int = 2000
    var titles: [String]
    private var start: Int
    private var end: Int

    init() {
        start = Items.startIndex
        end = start + Items.fetchCount
        titles = (start..<start + Items.fetchCount).map { "\($0)" }
    }

    func add(type: AddType) {
        debugPrint(type)
        switch type {
        case .top:
            let items = (start - Items.fetchCount..<start).map { "\($0)" }
            start -= Items.fetchCount
            titles.insert(contentsOf: items, at: 0)
        case .bottom:
            let items = (end..<end + Items.fetchCount).map { "\($0)" }
            end += Items.fetchCount
            titles.append(contentsOf: items)
        }
    }

    var count: Int {
        return titles.count
    }

    func title(index: Int) -> String? {
        return titles.getSafely(index: index)
    }

    var hasNext: Bool {
        return end < Items.endIndex
    }

    var hasPrevious: Bool {
        return start > 0
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: BothSidesRefreshableTableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.tintColor = UIColor.blue
            tableView.refreshControl?.addTarget(self, action: #selector(refreshPrevious), for: .valueChanged)

            tableView.bottomRefreshControl = BottomRefreshControl()
            tableView.bottomRefreshControl?.tintColor = UIColor.blue
            tableView.bottomRefreshControl?.addTarget(self, action: #selector(refreshNext), for: .valueChanged)
        }
    }

    private let items = Items()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController {
    @objc func refreshPrevious() {
        DispatchQueue.global().async {
            sleep(1)
            self.items.add(type: .top)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    @objc func refreshNext() {
        debugPrint(#function)
        DispatchQueue.global().async {
            sleep(1)
            self.items.add(type: .bottom)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.bottomRefreshControl?.endRefreshing()
            }
        }

    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            tableView.refreshControl?.beginRefreshing()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath) as? SimpleCell else {
            fatalError()
        }
        guard let item = items.title(index: indexPath.row) else { fatalError() }
        cell.bind(title: item)
        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        debugPrint(items.count)
        return items.count
    }
}

extension Array {
    func getSafely(index: Int) -> Element? {
        guard index >= 0, index < self.count else { return nil }
        return self[index]
    }
}
