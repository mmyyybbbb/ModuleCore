//
//  SceneBuilder.swift
//  BrokerOpenAccountModule
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
// 
public final class StackSceneBuilder {
    
    public enum ViewWidth {
        case `default`
        case `self`
        case insetted(CGFloat)
        case full
    }
 
    public let scene: StackViewController
    private var viewsWidthDefaultInset: CGFloat?
     
    public init(viewsWidthDefaultInset: CGFloat? = nil,
                stackViewSpacing: CGFloat = 0,
                contentMode: StackViewController.ContentMode = .scrollable,
                stackContainerType: UIView.Type = UIView.self,
                backgroundColor: UIColor = .white) {
        self.scene = StackViewController(contentMode: contentMode,
                                         stackContainerType: stackContainerType,
                                         backgroundColor: backgroundColor)
        self.viewsWidthDefaultInset = viewsWidthDefaultInset
        scene.stackView.spacing = stackViewSpacing
    }

    private func addWidthConstraintIfNeed(to view: UIView, type: ViewWidth)  {
        let inset: CGFloat?
        
        switch type {
        case .default:
            guard let viewsWidthDefaultInset = viewsWidthDefaultInset else { return }
            inset = viewsWidthDefaultInset
        case .full:
            inset = 0
        case .insetted(let inst):
            inset = inst
        case .self:
            inset = nil
        }
        
        guard let widthInset = inset, let superview = view.superview else { return }
        
        let constraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -widthInset)
        scene.constraints.append(constraint)
    }
}



public extension StackSceneBuilder {
    
    func build() -> StackViewController {
        return scene
    }
    
    func build<R: SceneReactor>(reactor: R,
                                viewDidLoadAction: R.Action? = nil,
                                viewWillAppearAction: R.Action? = nil,
                                viewWilDisappearAction: R.Action? = nil,
                                viewDidAppearAction: R.Action? = nil,
                                viewDidDisappearAction: R.Action? = nil) -> StackViewController {
        let scene = build()
        scene.reactor = reactor
        if let viewDidLoadAction = viewDidLoadAction {
            scene.onViewDidLoad = { [weak reactor] in reactor?.action.onNext(viewDidLoadAction) }
        }
        if let viewWillAppearAction = viewWillAppearAction {
            scene.onViewWillAppear = { [weak reactor] in reactor?.action.onNext(viewWillAppearAction) }
        }
        if let viewWilDisappearAction = viewWilDisappearAction {
            scene.onViewWillDisappear = { [weak reactor] in reactor?.action.onNext(viewWilDisappearAction) }
        }
        if let viewDidAppearAction = viewDidAppearAction {
            scene.onViewDidAppear = { [weak reactor] in reactor?.action.onNext(viewDidAppearAction) }
        }
        if let viewDidDisappearAction = viewDidDisappearAction {
            scene.onViewDidDisappear = { [weak reactor] in reactor?.action.onNext(viewDidDisappearAction) }
        }
        return scene
    }
    
    func set(stackAlignment: UIStackView.Alignment) {
        scene.stackView.alignment = stackAlignment
    }
    
    func set(backgroundColor: UIColor) {
        scene.backgroundColor = backgroundColor
    }
    
    func set(contentInset: UIEdgeInsets) {
        scene.contentInset = contentInset
    }
    
    func add(view: UIView, width: ViewWidth = .default) {
        scene.stackView.addArrangedSubview(view)
        addWidthConstraintIfNeed(to: view, type: width)
    }
    
    func addSpace(_ height: CGFloat) {
        add(view: FixedHeightView(height: height, backgroundColor: scene.backgroundColor))
    }
    
    func set(footer view: UIView) {
        scene.footerView = view
    }
    
    func set(header view: UIView) {
        scene.headerView = view
    }
    
    func set(navigationBar: UIViewController) {
        scene.navigationBar = navigationBar
    }
}
