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
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { mainScrollSceneDelegate?.scrollStoped(scrollView.contentOffset, false) }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mainScrollSceneDelegate?.scrollStoped(scrollView.contentOffset, true)
    }
    
}
