//
//  EmbeddedScrollScene.swift
//  ModuleCore
//
//  Created by Andrey Raevnev on 13.09.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

open class EmbeddedScrollScene: UIViewController {
    
    public weak var mainScrollSceneDelegate: MainScrollSceneDelegate?
    var scrollToTop = false
    open var embeddedScrollView: UIScrollView? { return nil }
    fileprivate var direction: MainScrollScene.Direction = .nothing
    
    public func canListScroll() -> Bool {
        guard let embeddedScrollView = embeddedScrollView else { return true }
        
        if embeddedScrollView.contentOffset.y.isZero {
            if scrollToTop {
                scrollToTop = false
                mainScrollSceneDelegate?.scrollToTop()
            }
            return false
        }
        
        mainScrollSceneDelegate?.scrollTo(embeddedScrollView.contentOffset)
        
        if mainScrollSceneDelegate?.isCanScroll() == false {
            embeddedScrollView.setContentOffset(.zero, animated: false)
            return false
        }
        
        return true
    }
}

extension EmbeddedScrollScene: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollToTop = true
        return true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
//        debugPrint("SCROLL_EMBED scrollViewWillEndDragging target.y", targetContentOffset.pointee.y)
//        debugPrint("SCROLL_EMBED scrollViewWillEndDragging contentOffset.y", scrollView.contentOffset.y)
        
        if targetContentOffset.pointee.y.isZero {
//            debugPrint("SCROLL_EMBED scrollViewWillEndDragging НИКУДА")

            direction = .nothing
            
        } else if targetContentOffset.pointee.y > scrollView.contentOffset.y {
//            debugPrint("SCROLL_EMBED scrollViewWillEndDragging ВНИЗ")
            
            direction = .down
            
        } else {
//            debugPrint("SCROLL_EMBED scrollViewWillEndDragging ВВЕРХ")
            
            direction = .up
        }
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
//        debugPrint("SCROLL_EMBED scrollViewDidEndDragging y", scrollView.contentOffset.y, "decelerate", decelerate, "direction ", direction)
        
        if !decelerate {
            mainScrollSceneDelegate?.scrollStoped(scrollView.contentOffset, decelerate: false, direction: direction)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
//        debugPrint("SCROLL_EMBED scrollViewDidEndDecelerating y", scrollView.contentOffset.y)
        
        mainScrollSceneDelegate?.scrollStoped(scrollView.contentOffset, decelerate: true, direction: direction)
    }
    
}
