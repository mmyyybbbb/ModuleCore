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
    
    public enum Direction: String {
        case nothing
        case up
        case down
    }
}

public protocol MainScrollSceneDelegate: UIScrollViewDelegate {
    func isCanScroll() -> Bool
    func scrollTo(_ contentOffset: CGPoint)
    func scrollToTop()
    func scrollStoped(_ contentOffset: CGPoint, decelerate: Bool, direction: MainScrollScene.Direction)
    
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
        
        var newY = mainScrollView.contentOffset.y + contentOffset.y
        
//        debugPrint("SCROLL scrollTo contentOffset.y", contentOffset.y)
//        debugPrint("SCROLL scrollTo mainScrollView.contentOffset.y", mainScrollView.contentOffset.y)
//        debugPrint("SCROLL scrollTo newY", newY)
        
        let maxY = embedSceneScrollOffset - hackOffsetScroll
        let minY: CGFloat = 0
//        debugPrint("SCROLL scrollTo maxY", maxY)

        if newY > maxY {
            newY = maxY
        }
        if newY < minY {
            newY = minY
        }
//        debugPrint("SCROLL scrollTo newY_", newY)

        mainScrollView.setContentOffset(CGPoint(x: 0, y: newY), animated: false)
    }
    
    // остановка скрола при свайпе
    public func scrollStoped(_ contentOffset: CGPoint, decelerate: Bool, direction: MainScrollScene.Direction) {
        guard let mainScrollView = mainScrollView else { return }
        
//        debugPrint("SCROLL scrollStoped contentOffset.y", contentOffset.y, "decelerate", decelerate, "direction", direction)
//        debugPrint("SCROLL scrollStoped mainScrollView.contentOffset.y", mainScrollView.contentOffset.y)
        
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
        
//        debugPrint("SCROLL scrollStoped embedSceneScrollOffset / 2", embedSceneScrollOffset / 2)
//        debugPrint("SCROLL scrollStoped сссс", (mainScrollView.contentOffset.y > (embedSceneScrollOffset / 2)))

        
        let minY: CGFloat = 0
        let maxY = (embedSceneScrollOffset - hackOffsetScroll)
        
        var newY = mainScrollView.contentOffset.y > (embedSceneScrollOffset / 2) ? maxY : minY

//        debugPrint("SCROLL scrollStoped decelerate", decelerate, "maxY", maxY)

        switch direction {
        case .down:
            
            if mainScrollView.contentOffset.y > decelerateScrollOffset {
//                debugPrint("SCROLL scrollStoped свайпнули вниз БОЛЬШЕ чем на 50")
                newY = maxY
            } else {
//                debugPrint("SCROLL scrollStoped свайпнули вниз МЕНЬШЕ чем на 50")
            }
            
        case .up:
            
            if abs(maxY - mainScrollView.contentOffset.y) > decelerateScrollOffset {
//                debugPrint("SCROLL scrollStoped свайпнули вверх БОЛЬШЕ чем на 50")
                newY = minY
            } else {
//                debugPrint("SCROLL scrollStoped свайпнули вверх МЕНЬШЕ чем на 50")
            }
            
        case .nothing:
            
            if mainScrollView.contentOffset.y > (embedSceneScrollOffset / 2) {

                if abs(maxY - mainScrollView.contentOffset.y) > decelerateScrollOffset {

//                    debugPrint("SCROLL scrollStoped отпустили снизу наверх больше чем на 50")

                    newY = minY
                }

            } else {
                if mainScrollView.contentOffset.y > decelerateScrollOffset {

//                    debugPrint("SCROLL scrollStoped отпустили сверзу вниз больше чем на 50")

                    newY = maxY
                }
            }
        }
        
//        debugPrint("SCROLL scrollStoped newY", newY)
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
        
//        debugPrint("SCROLL scrollViewDidScroll y", contentOffset.y, "embedSceneScrollOffset", embedSceneScrollOffset)
        
        if contentOffset.y > embedSceneScrollOffset {
//            debugPrint("SCROLL scrollViewDidScroll setContentOffset", embedSceneScrollOffset)
            scrollView.setContentOffset(CGPoint(x: 0, y: embedSceneScrollOffset), animated: false)
        }
        
        let isHidden = contentOffset.y > (embedSceneScrollOffset - 8)
        changedHeader(isHidden: isHidden)
    }
}
