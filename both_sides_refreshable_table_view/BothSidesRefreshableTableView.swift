//
//  BothSidesRefreshableTableView.swift
//  both_sides_refreshable_table_view
//
//  Created by Daisuke Kubota on 2020/03/23.
//  Copyright © 2020 d-kubota.com. All rights reserved.
//

import UIKit

class BothSidesRefreshableTableView: UITableView {
    var bottomRefreshControl: BottomRefreshControl? {
        didSet {
            if let oldValue = oldValue {
                oldValue.removeFromSuperview()
            }
            if let bottomRefreshControl = bottomRefreshControl {
                addSubview(bottomRefreshControl)
                sendSubviewToBack(bottomRefreshControl)
                var frame = bottomRefreshControl.frame
                frame.origin = CGPoint(x: 0, y: self.bounds.size.height - frame.size.height)
                frame.size.width = self.bounds.size.width
                bottomRefreshControl.frame = frame
                self.printSuperviews()
                self.printSubviews()
            }
        }
    }

    private var _delegate: UITableViewDelegate?

    override var delegate: UITableViewDelegate? {
        get {
            return _delegate
        }
        set {
            self._delegate = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint(#function)
        super.delegate = self
    }
}

extension BothSidesRefreshableTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidScroll?(scrollView)
        bottomRefreshControl?.update(scrollView: scrollView)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        _delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        _delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        _delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return _delegate?.viewForZooming?(in: scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        _delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        _delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        _delegate?.scrollViewShouldScrollToTop?(scrollView) ?? scrollView.scrollsToTop
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidScrollToTop?(scrollView)
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        _delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }

}

extension BothSidesRefreshableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        _delegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        _delegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        _delegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }

    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        _delegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = _delegate?.tableView?(tableView, heightForRowAt: indexPath) else { return tableView.estimatedRowHeight }
        return height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let height = _delegate?.tableView?(tableView, heightForFooterInSection: section) else { return tableView.estimatedSectionFooterHeight }
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = _delegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) else { return tableView.estimatedRowHeight }
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard let height = _delegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) else { return tableView.estimatedSectionHeaderHeight }
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        guard let height = _delegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) else { return tableView.estimatedSectionFooterHeight }
        return height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return _delegate?.tableView?(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return _delegate?.tableView?(tableView, viewForFooterInSection: section)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        _delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return _delegate?.tableView?(tableView, shouldHighlightRowAt: indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, didHighlightRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, didUnhighlightRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return _delegate?.tableView?(tableView, willSelectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return _delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        _delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
    }
}
