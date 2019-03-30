//
//  CollectionSceneConfigurator.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 31/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public struct CollectionSceneConfigurator {
    let refreshControll: Bool
    let layout:UICollectionViewFlowLayout
    let selectedDelay: TimeInterval
    let loadDataOnViewDidLoad: Bool
    public weak var scrollDelegate: UIScrollViewDelegate?
    
    public init(canRefresh: Bool, layout: UICollectionViewFlowLayout, loadDataOnViewDidLoad: Bool = true, scrollDelegate: UIScrollViewDelegate? = nil, delayForSelecion: TimeInterval = 0) {
        self.refreshControll = canRefresh
        self.layout = layout
        self.selectedDelay = delayForSelecion
        self.scrollDelegate = scrollDelegate
        self.loadDataOnViewDidLoad = loadDataOnViewDidLoad
    }
}
