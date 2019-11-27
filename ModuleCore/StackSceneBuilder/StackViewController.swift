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
    
    public var navigationBar: UIViewController?
    public var headerView: UIView?
    public var footerView: UIView?
    public var scrollableContent: Bool { return scrollView.contentSize.height > scrollView.frame.height }
    
    private var isFooterHeaderConstrainted: Bool = false
    private let stackContainer: UIView
    private let contentMode: ContentMode
    public var backgroundColor: UIColor
    
    public var contentInset: UIEdgeInsets = .zero
    public var headerTopLayout: HeaderTopLayout = .upToNavBarOrSafeArea
    
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
 
    private var viewBottomAnchor: NSLayoutYAxisAnchor  {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return view.bottomAnchor
        }
    }
    
    private var viewTopAnchor: NSLayoutYAxisAnchor  {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return view.topAnchor
        }
    }
     
    private func setupViewAndConstraints() {
        view.backgroundColor = backgroundColor
        scrollView.backgroundColor = backgroundColor
        stackView.backgroundColor = backgroundColor
        
        if let navigationBar = navigationBar {
            
            addChild(navigationBar)
            view.addSubview(navigationBar.view)
            navigationBar.view.translatesAutoresizingMaskIntoConstraints = false
            
            let headerTopAnchor: NSLayoutYAxisAnchor = headerTopLayout == .upToDeviceTopEdge ? view.topAnchor : viewTopAnchor
            let headerTopViewContant: CGFloat = headerTopLayout == .upToDeviceTopEdge ? 20 : 0
                
            constraints.append(contentsOf: [
                navigationBar.view.leftAnchor.constraint(equalTo: view.leftAnchor),
                navigationBar.view.rightAnchor.constraint(equalTo: view.rightAnchor),
                navigationBar.view.topAnchor.constraint(equalTo: headerTopAnchor, constant: headerTopViewContant)
                ])
            
            navigationBar.didMove(toParent: self)
            
        } else if let headerView = headerView {
            view.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            
            let headerTopAnchor: NSLayoutYAxisAnchor = headerTopLayout == .upToDeviceTopEdge ? view.topAnchor : viewTopAnchor
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
                footerView.bottomAnchor.constraint(equalTo: viewBottomAnchor)
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
            
            let navigationBarIsHidden = navigationController?.navigationBar.isHidden ?? true
            var topOffset: CGFloat = 0
            if #available(iOS 11.0, *) {} else if navigationBarIsHidden { topOffset = 20 }
            
            view.addSubview(scrollView)
            scrollView.addSubview(stackContainer)
            scrollView.contentInset = contentInset
            constraints.append(contentsOf: [
                scrollView.bottomAnchor.constraint(equalTo: footerView?.topAnchor ?? viewBottomAnchor),
                scrollView.topAnchor.constraint(equalTo: headerView?.bottomAnchor ?? viewTopAnchor,
                                                constant: headerView == nil ? topOffset : 0),
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
