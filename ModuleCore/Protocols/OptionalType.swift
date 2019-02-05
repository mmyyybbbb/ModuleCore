//
//  OptionalType.swift
//  MyBroker
//
//  Created by Alexej Nenastev on 28.04.2018.
//  Copyright © 2018 BCS. All rights reserved.
//

public protocol OptionalType {
    associatedtype Wrapped

    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}
