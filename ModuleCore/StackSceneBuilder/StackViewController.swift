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
    
    var backgroundColor: UIColor = .white 
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
    }
    
    public var footerView: UIView?
    public var headerView: UIView?
    public var scrollableContent: Bool { return scrollView.contentSize.height > scrollView.frame.height }
    
    private var isFooterHeaderConstrainted: Bool = false
    private let stackContainer: UIView
    private let contentMode: ContentMode
    
    public var contentInset: UIEdgeInsets = .zero
    
    init(contentMode: ContentMode, stackContainerType: UIView.Type) {
        self.stackContainer = stackContainerType.init()
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
        
        if let footerView = footerView {
            view.addSubview(footerView)
            footerView.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.bottomAnchor.constraint(equalTo: viewBottomAnchor)
                ])
        }
        
        if let headerView = headerView {
            view.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                headerView.topAnchor.constraint(equalTo: viewTopAnchor)
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
            view.addSubview(scrollView)
            scrollView.addSubview(stackContainer)
            scrollView.contentInset = contentInset
 
            constraints.append(contentsOf: [
                scrollView.bottomAnchor.constraint(equalTo: footerView?.topAnchor ?? viewBottomAnchor),
                scrollView.topAnchor.constraint(equalTo: headerView?.bottomAnchor ?? viewTopAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                stackContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackContainer.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
                stackContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(scrollView.contentInset.left + scrollView.contentInset.right))
                ])
        } else {
            view.addSubview(stackContainer)
            constraints.append(contentsOf: [
                stackContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(contentInset.left + contentInset.right))
                ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}
