//
//  TableSceneConfigurator.swift
//  ModuleCore
//
//  Created by Ponomarev Vasiliy on 02/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public struct TableSceneConfigurator {
    let refreshControll: Bool
    public weak var scrollDelegate: UIScrollViewDelegate?

    public init(canRefresh: Bool, scrollDelegate: UIScrollViewDelegate? = nil) {
        self.refreshControll = canRefresh
        self.scrollDelegate = scrollDelegate
    }
}
