//
//  BottomRefreshControl.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

private let height = CGFloat(60)

private let maxHeight = height * 2

/// BottomRefreshControl
class BottomRefreshControl: UIControl {

    /// IndicatorView
    private let indicator = BottomRefreshIndicator()

    /// refreshing
    private var refreshing: Bool = false
    /// addedInsetBottom in scrollView
    private var addedInsetBottom = CGFloat(0)

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: height))
        backgroundColor = UIColor.clear
        addSubview(indicator)
        indicator.center = self.center
        isHidden = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var tintColor: UIColor! {
        get {
            return indicator.color
        }
        set {
            indicator.color = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var isRefreshing: Bool {
        return refreshing
    }

    private func setRefreshing(refreshing: Bool) {
        if self.refreshing != refreshing {
            self.refreshing = refreshing
            sendActions(for: .valueChanged)
            indicator.startAnimating()
        }
    }

    func beginRefreshing() {
        if refreshing {
            return
        }
        refreshing = true
        isHidden = false
        guard let scrollView = self.superview as? UIScrollView else { return }
        addedInsetBottom += height
        scrollView.contentInset.bottom += height
    }

    func endRefreshing() {
        if !refreshing {
            return
        }
        guard let scrollView = self.superview as? UIScrollView else { return }
        scrollView.contentInset.bottom -= addedInsetBottom
        addedInsetBottom = 0
        isHidden = true
        indicator.stopAnimating()
        refreshing = false
    }
}

extension BottomRefreshControl {
    func update(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let difference = maximumOffset - currentOffset
        if difference < -1 || refreshing {
            // 常にscrollViewのボトムに
            let frameHeight = difference >= 0 ? height : -difference
            var frame = self.frame
            frame.size.height = frameHeight
            frame.origin.x = scrollView.bounds.origin.x + offset.x
            frame.origin.y = scrollView.bounds.size.height - frame.size.height + offset.y
            self.frame = frame
            indicator.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        }
        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let canLoadFromBottom = contentSize > tableSize

        if canLoadFromBottom, difference < -1, !refreshing {
            isHidden = false
            let percent = (-difference - height / 2) / (maxHeight - height / 2)

            indicator.percent = percent >= 0 ? percent : 0
            if !refreshing, scrollView.isDragging, difference < -maxHeight {
                setRefreshing(refreshing: true)
            }
        } else {
            isHidden = !refreshing
        }
    }

    func scrollDidEndDraging(scrollView: UIScrollView, decelerate: Bool) {
        if refreshing {
            if addedInsetBottom > 0 { return }
            let previousScrollBottomInset = scrollView.contentInset.bottom
            scrollView.contentInset.bottom = previousScrollBottomInset + height
            addedInsetBottom += height
        }
    }
}
