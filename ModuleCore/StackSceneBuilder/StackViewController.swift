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
    var constraints: [NSLayoutConstraint] = []
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    lazy var stackView: UIStackView = {
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
    
    var footerView: UIView?
    var headerView: UIView?
    
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    private var isFooterHeaderConstrainted: Bool = false
    
    private let contentMode: ContentMode
    
    public var contentInset: UIEdgeInsets = .zero
    
    init(contentMode: ContentMode) {
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
 
    override public func updateViewConstraints() {
        if isFooterHeaderConstrainted == false  {
             isFooterHeaderConstrainted = true
            
            if let topConstraint = topConstraint, let headerHeight = headerView?.frame.height {
                topConstraint.constant = headerHeight
            }
            
            if let bottomConstraint = bottomConstraint, let bottomHeight = footerView?.frame.height {
                bottomConstraint.constant = bottomHeight
            }
        }
        
        super.updateViewConstraints()
    }
    
    private func setupViewAndConstraints() {
        if contentMode == .scrollable {
            view.addSubview(scrollView)
            scrollView.addSubview(stackView)
            scrollView.contentInset = contentInset
            topConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
            bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            NSLayoutConstraint.activate([
                topConstraint!,
                bottomConstraint!,
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(scrollView.contentInset.left + scrollView.contentInset.right))
                ])
        } else {
            view.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(contentInset.left + contentInset.right))
                ])
        }
        NSLayoutConstraint.activate(constraints)
        
        if let footerView = footerView {
            view.addSubview(footerView)
            footerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
        
        if let headerView = headerView {
            view.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
                headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
                headerView.topAnchor.constraint(equalTo: view.topAnchor)
                ])
        }
    }
}
