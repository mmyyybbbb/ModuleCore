//
//  FixedHeightView.swift
//  BrokerOpenAccountModule
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
public final class FixedHeightView: UIView {
    private let height: CGFloat
    
    public init(height: CGFloat, backgroundColor: UIColor? = nil) {
        self.height = height
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

