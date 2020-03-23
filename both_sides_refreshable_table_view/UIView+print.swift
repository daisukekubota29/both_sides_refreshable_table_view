//
//  UIView+print.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

extension UIView {
    func printSuperviews() {
        guard let superview = self.superview else {
            debugPrint("no superview")
            return
        }
        var indent = 0
        debugPrint("superviews -----------------------")
        superview.lastParentview().forEach {
            debugPrint("\(spaces(indent: indent))\($0)")
            indent += 1
        }
        debugPrint("----------------------------------")
    }

    func printSubviews() {
        debugPrint("subviews -------------------------")
        printSubviews(indent: 0)
        debugPrint("----------------------------------")
    }

    private func printSubviews(indent: Int) {
        debugPrint("\(spaces(indent: indent))\(self)")
        guard self.subviews.count > 0 else { return }
        self.subviews.forEach { $0.printSubviews(indent: indent + 1) }
    }

    private func lastParentview() -> [UIView] {
        guard let superview = self.superview else {
            return [self, ]
        }
        return superview.lastParentview() + [self]
    }

    private func spaces(indent: Int) -> String {
        (0..<indent).map { _ in "    " }.joined()
    }
}
