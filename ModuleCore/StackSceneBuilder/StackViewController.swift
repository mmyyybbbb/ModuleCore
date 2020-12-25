//
//  StackScrollViewController.swift
//  BrokerOpenAccountModule
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
// 
import RxSwift

public final class StackViewController: UIViewController, DisposeBagHolder {
    
    public let disposeBag = DisposeBag()
    
    var reactor: AnyObject?
    var onViewDidLoad: () -> () = {}
    var onViewDidAppear: () -> () = {}
    var onViewDidDisappear: () -> () = {}
    var onViewWillAppear: () -> () = {}
    var onViewWillDisappear: () -> () = {}
    var constraints: [NSLayoutConstraint] = []
    
    public lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    public lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()
    
    public enum ContentMode {
        case center
        case scrollable
        case selfHeight
    }
    
    public enum HeaderTopLayout {
        case upToNavBarOrSafeArea
        case upToDeviceTopEdge
    }
    
    public enum ScrollViewTopLayout {
        case toHeaderIfHas
        case toSafeArea
    }
    
    public var navigationBar: UIViewController? // если задан, то перезатрет headerView
    public var headerView: UIView?
    public var footerView: UIView?
    public var scrollableContent: Bool { return scrollView.contentSize.height > scrollView.frame.height }
    
    private var isFooterHeaderConstrainted: Bool = false
    private let stackContainer: UIView
    private let contentMode: ContentMode
    public var backgroundColor: UIColor
    
    public var contentInset: UIEdgeInsets = .zero
    public var headerTopLayout: HeaderTopLayout = .upToNavBarOrSafeArea
    public var scrollViewTopLayout: ScrollViewTopLayout = .toHeaderIfHas
    
    init(contentMode: ContentMode, stackContainerType: UIView.Type, backgroundColor: UIColor) {
        self.stackContainer = stackContainerType.init()
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViewAndConstraints()
        onViewDidLoad()
        
        scrollView.backgroundColor = backgroundColor
        stackView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        onViewWillAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        onViewWillDisappear()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onViewDidAppear()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        onViewDidDisappear()
    }
 
    private func setupViewAndConstraints() {
        view.backgroundColor = backgroundColor
        scrollView.backgroundColor = backgroundColor
        stackView.backgroundColor = backgroundColor
        
        if contentMode == .scrollable {
            view.addSubview(scrollView)
        }
        
        if let navigationBar = navigationBar {
            addChild(navigationBar)
            headerView = navigationBar.view
        }
            
        if let headerView = headerView {
            view.addSubview(headerView)
            
            navigationBar?.didMove(toParent: self)
            
            headerView.translatesAutoresizingMaskIntoConstraints = false
            
            let headerTopAnchor: NSLayoutYAxisAnchor = headerTopLayout == .upToDeviceTopEdge ? view.topAnchor : view.safeAreaLayoutGuide.topAnchor
            let headerTopViewContant: CGFloat = headerTopLayout == .upToDeviceTopEdge ? 20 : 0
                
            constraints.append(contentsOf: [
                headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                headerView.topAnchor.constraint(equalTo: headerTopAnchor, constant: headerTopViewContant)
                ])
        }
        
        if let footerView = footerView {
            view.addSubview(footerView)
            footerView.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
        }
        
        stackContainer.addSubview(stackView)
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(contentsOf: [
            stackView.leftAnchor.constraint(equalTo: stackContainer.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: stackContainer.rightAnchor),
            stackView.topAnchor.constraint(equalTo: stackContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: stackContainer.bottomAnchor)
            ])
        
        
        if contentMode == .scrollable { 
            scrollView.addSubview(stackContainer)
            scrollView.contentInset = contentInset
            
            let topScrollViewAnchor: NSLayoutYAxisAnchor
            switch scrollViewTopLayout {
            case .toHeaderIfHas: topScrollViewAnchor = headerView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
            case .toSafeArea: topScrollViewAnchor = view.safeAreaLayoutGuide.topAnchor
            }
             
            constraints.append(contentsOf: [
                scrollView.bottomAnchor.constraint(equalTo: footerView?.topAnchor ?? view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.topAnchor.constraint(equalTo: topScrollViewAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                stackContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackContainer.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
                stackContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(scrollView.contentInset.left + scrollView.contentInset.right))
                ])
        } else if contentMode == .center {
            view.addSubview(stackContainer)
            constraints.append(contentsOf: [
                stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(contentInset.left + contentInset.right))
                ])
        } else {
            view.addSubview(stackContainer)
            constraints.append(contentsOf: [
                stackContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: contentInset.top),
                stackContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: contentInset.bottom),
                stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(contentInset.left + contentInset.right))
                ])
        } 
        NSLayoutConstraint.activate(constraints)
    }
}
