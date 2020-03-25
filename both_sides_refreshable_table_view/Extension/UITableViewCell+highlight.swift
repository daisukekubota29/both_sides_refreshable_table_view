//
//  UITableViewCell+highlight.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/25.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

private let animationDuration = TimeInterval(0.2)
private let animationKey = "hightlight.hide"

extension UITableViewCell {
    /// UITableViewCellのcontentViewを指定の色でハイライト
    /// - parameter duration: ハイライトする時間
    /// - parameter hightlightColor: ハイライトカラー
    /// - parameter animated: ハイライト終了時間にアニメーションして(Default: true)
    /// - parameter forced: すでにハイライト状態でも強制的にハイライトするか(Default: false)
    func highlight(duration: TimeInterval, highlightColor: UIColor, animated: Bool = true, forced: Bool = false) {
        let layer = self.contentView.layer
        if layer.animationKeys()?.contains(animationKey) == true {
            if !forced {
                return
            }
            layer.removeAnimation(forKey: animationKey)
        }
        let originalColor = self.contentView.backgroundColor ?? UIColor.clear
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.isRemovedOnCompletion = true
        animation.fromValue = highlightColor.cgColor
        animation.toValue = originalColor.cgColor
        animation.duration = animated ? animationDuration : 0
        animation.beginTime = CACurrentMediaTime() + duration

        layer.add(animation, forKey: animationKey)
    }

    /// UITableViewのcontenerViewのhighlightが存在すれば削除
    func removeHighlight() {
        let layer = self.contentView.layer
        if layer.animationKeys()?.contains(animationKey) == true {
            layer.removeAnimation(forKey: animationKey)
        }
    }
}
