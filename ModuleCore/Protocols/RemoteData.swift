//
//  DataProcessState.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public enum RemoteData<T> {
    case initial
    case loading
    case loaded(T)
    case loadingError(Error)
}
