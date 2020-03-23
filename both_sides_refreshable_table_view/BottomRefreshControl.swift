//
//  BottomRefreshControl.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

private let height = CGFloat(60)

class BottomRefreshControl: UIControl {

    private let indicator = BottomRefreshIndicator()

    private var refreshing: Bool = false

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: height))
        backgroundColor = UIColor.red.withAlphaComponent(0.5)
        addSubview(indicator)
        indicator.center = self.center
        indicator.hidesWhenStopped = true
//        isHidden = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var tintColor: UIColor! {
        get {
            return indicator.tintColor
        }
        set {
            indicator.tintColor = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint(#function)
    }

    var isRefreshing: Bool {
        return refreshing
    }

    private func setRefreshing(refreshing: Bool) {
        debugPrint("setRefreshing(refresing: \(refreshing)), [\(self.refreshing)]")
        if self.refreshing != refreshing {
            self.refreshing = refreshing
            sendActions(for: .valueChanged)
        }
    }

    func beginRefreshing() {
        if refreshing {
            return
        }
        refreshing = true
        isHidden = false
        guard let scrollView = self.superview as? UIScrollView else { return }
        scrollView.contentInset.bottom += self.bounds.size.height
    }

    func endRefreshing() {
        if !refreshing {
            return
        }
        guard let scrollView = self.superview as? UIScrollView else { return }
        scrollView.contentInset.bottom -= self.bounds.size.height
        isHidden = true
        refreshing = false
    }
}

extension BottomRefreshControl {
    func update(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 常にscrollViewのボトムに
        var frame = self.frame
        frame.origin.x = scrollView.bounds.origin.x + offset.x
        frame.origin.y = scrollView.bounds.size.height - frame.size.height + offset.y
        self.frame = frame

        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let canLoadFromBottom = contentSize > tableSize

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let difference = maximumOffset - currentOffset
//        debugPrint("difference: \(difference)")

        if canLoadFromBottom, difference < -1, !refreshing {
            isHidden = false
            let percent = -difference / self.bounds.size.height
            indicator.percent = percent
            
            if !refreshing, scrollView.isDragging, difference < -self.bounds.size.height {
                setRefreshing(refreshing: true)
                let previousScrollBottomInset = scrollView.contentInset.bottom
                scrollView.contentInset.bottom = previousScrollBottomInset + self.bounds.size.height
            }
        } else {
            isHidden = !refreshing
        }
    }
}
