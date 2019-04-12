//
//  StackScrollViewController.swift
//  BrokerOpenAccountModule
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
// 
import RxSwift

public final class StackScrollViewController: UIViewController {
    
    public let disposeBag = DisposeBag()
    var reactor: AnyObject?
    var onViewDidLoad: () -> () = {}
    
    let scrollView = UIScrollView()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViewAndConstraints()
        onViewDidLoad()
    }
    
    private func setupViewAndConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(scrollView.contentInset.left + scrollView.contentInset.right))
            ])
    }
}
