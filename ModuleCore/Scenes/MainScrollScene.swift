//
//  MainScrollScene.swift
//  ModuleCore
//
//  Created by Andrey Raevnev on 13.09.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

open class MainScrollScene: UIViewController {
    open var mainScrollView: UIScrollView? { nil }
    open var embedSceneScrollOffset: CGFloat { 0 }
    open var hackScrollOffset: CGFloat { 3 }
    
    /// отступ с которого начинает работать свайп доводка
    open var decelerateScrollOffset: CGFloat { 50 }

    /// высота когда триггеться метод хидера
    open var changedHeaderOffset: CGFloat { 8 }
    /// метод когда показывать или скрыть хидер main скролла
    open func changedHeader(isHidden: Bool) {}

    open var searchBar: UIView? { nil }
    open var searchBarHeight: CGFloat? { nil }
    open func updateSearchBarHeight(_ newHeight: CGFloat) {}
}

public protocol MainScrollSceneDelegate: UIScrollViewDelegate {
    func isCanScroll() -> Bool
    func scrollTo(_ contentOffset: CGPoint)
    func scrollToTop()
    func scrollStoped(_ contentOffset: CGPoint)
}

extension MainScrollScene: MainScrollSceneDelegate {
    
    // можно ли скролить вложенный scrollView/tableView/collectionView (который в pageController)
    public func isCanScroll() -> Bool {
        guard let mainScrollView = mainScrollView else { return false }
        
        var hackOffsetScroll = self.hackScrollOffset
        if let searchBar = searchBar, let searchBarHeight = searchBarHeight {
            hackOffsetScroll = 0
            
            let height = searchBar.frame.height
            if height > 0 && height < searchBarHeight { return false }
        }
        
        if mainScrollView.contentOffset.y.isZero { return true }
        if mainScrollView.contentOffset.y >= (embedSceneScrollOffset - hackOffsetScroll) { return true }
        return false
    }
    
    // нажали на статус бар
    public func scrollToTop() {
        guard let mainScrollView = mainScrollView else { return }
        mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    // скролл
    public func scrollTo(_ contentOffset: CGPoint) {
        guard let mainScrollView = mainScrollView else { return }
        
        var hackOffsetScroll: CGFloat = 3
        if let searchBar = searchBar, let searchBarHeight = searchBarHeight {
            hackOffsetScroll = 0
            
            let height = searchBar.frame.height
            if mainScrollView.contentOffset.y.isZero && contentOffset.y < 0 && height < searchBarHeight {
                var newHeight = height - contentOffset.y
                if newHeight > searchBarHeight { newHeight = searchBarHeight }
                updateSearchBarHeight(newHeight)
                return
            }
            
            if mainScrollView.contentOffset.y.isZero && height > 0 && height <= searchBarHeight {
                var newHeight = height - contentOffset.y
                if newHeight < 0 { newHeight = 0 }
                if newHeight > searchBarHeight { newHeight = searchBarHeight }
                updateSearchBarHeight(newHeight)
                return
            }
        }
        
        let maxY = embedSceneScrollOffset - hackOffsetScroll
        let minY: CGFloat = 0
        var newY = mainScrollView.contentOffset.y + contentOffset.y

        if newY > maxY { newY = maxY }
        if newY < minY { newY = minY }

        mainScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
    }
    
    // остановка скрола при свайпе
    public func scrollStoped(_ contentOffset: CGPoint) {
        guard let mainScrollView = mainScrollView else { return }
        
        var hackOffsetScroll: CGFloat = 3
        if let searchBar = searchBar, let searchBarHeight = searchBarHeight {
            hackOffsetScroll = 0
            
            let height = searchBar.frame.height
            if height > 0 && height < searchBarHeight {
                let newHeight = height > (searchBarHeight / 2) ? searchBarHeight : 0
                UIView.animate(withDuration: 0.2) { self.updateSearchBarHeight(newHeight) }
                return
            }
        }
        
        let minY: CGFloat = 0
        let maxY = (embedSceneScrollOffset - hackOffsetScroll)
        var newY = mainScrollView.contentOffset.y > (embedSceneScrollOffset / 2) ? maxY : minY

        if mainScrollView.contentOffset.y > (embedSceneScrollOffset / 2) {
            if abs(maxY - mainScrollView.contentOffset.y) > decelerateScrollOffset {
                newY = minY
            }
            
        } else {
            if mainScrollView.contentOffset.y > decelerateScrollOffset {
                newY = maxY
            }
        }

        mainScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: true)
    }
    
}

extension MainScrollScene: UIScrollViewDelegate {
    
    // запрещаем нажатие на статус бар для главного scrollView
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    // изменение положения кастомного навбара
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !embedSceneScrollOffset.isZero else { return }
        
        let contentOffset = scrollView.contentOffset

        if contentOffset.y > embedSceneScrollOffset {
            scrollView.setContentOffset(CGPoint(x: 0, y: embedSceneScrollOffset), animated: false)
        }
        
        let isHidden = contentOffset.y > (embedSceneScrollOffset - 8)
        changedHeader(isHidden: isHidden)
    }
}
