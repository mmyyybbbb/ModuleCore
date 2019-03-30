//
//  DataState.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public enum DataState {
    case none
    case error(Error)
    case hasData
    case dataIsEmpty
}
