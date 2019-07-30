//
//  TableVC.swift
//  ModuleCore
//
//  Created by Ponomarev Vasiliy on 02/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import RxDataSources

public extension UITableView {
    static var staticDefault: UITableView { return configureDefault(StaticTableView(frame: .zero)) }
    
    static var `default`: UITableView { return configureDefault(UITableView(frame: .zero)) }
    
    private static func configureDefault(_ tv: UITableView) -> UITableView {
        tv.delaysContentTouches = false
        tv.tableFooterView = UIView()
        tv.showsVerticalScrollIndicator = false
        return tv
    }
}

public typealias SectionedTableViewDataSource<Section:IdentifiableType, Item: IdentifiableType & Equatable> = RxTableViewSectionedReloadDataSource<AnimatableSectionModel<Section, Item>>

public final class SectionedTableVC<Section:IdentifiableType, Item: IdentifiableType & Equatable>: UIViewController, SceneView, UIScrollViewDelegate {
    
    public var disposeBag = DisposeBag()
    
    private var refreshControl: UIRefreshControl?
    public let tableView: UITableView
    private var footerActivityIndicator = UIActivityIndicatorView(style: .gray)
    private let dataSource: SectionedTableViewDataSource<Section,Item>
    
    override public func loadView() {
        self.view = tableView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = vm.canSelectItem
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    public init(dataSource: SectionedTableViewDataSource<Section,Item>, tableView: UITableView, canRefresh: Bool) {
        self.dataSource = dataSource
        self.tableView = tableView
        
        if canRefresh {
            self.refreshControl = UIRefreshControl()
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl!
            } else {
                tableView.addSubview(refreshControl!)
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind(reactor: SectionedTableReactor<Section,Item>) {
        
        reactor.state
            .map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected
            .map(Reactor.Action.selected)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        if let refresher = refreshControl {
            refresher.rx.controlEvent(.valueChanged).asObservable()
                .subscribe(onNext: { [weak self] in self?.fire(action: .loadData) })
                .disposed(by: disposeBag)
            
            bindState(\.inProgressRefreshLoading, to: refresher.rx.isRefreshing)
        }
        
        if reactor.canLoadMore {
            tableView.rx.didScroll.subscribeNext(self, do: SectionedTableVC<Section,Item>.loadMoreIfNeed, bag: disposeBag)
            subscribeNext(reactor.state.map { $0.inProgressLoadMore }, with: SectionedTableVC.setProgressMore)
        }
        
    }
    
    func setRefreshInProgress(inProgress: Bool) {
        if !inProgress && (refreshControl?.isRefreshing ?? false) { refreshControl?.endRefreshing() }
    }
    
    func setProgressMore(inProgressMore: Bool) {
        if inProgressMore { footerActivityIndicator.startAnimating() }
        else { footerActivityIndicator.stopAnimating() }
        
        footerActivityIndicator.isHidden = !inProgressMore
    }
    
    public func loadMoreIfNeed() {
        
        let scrollView = tableView as UIScrollView
        
        if scrollView.contentSize.height < scrollView.frame.size.height { return }
        
        let currentOffset  = scrollView.contentOffset.y
        let maiximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset    = maiximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            fire(action: .loadMore)
        }
    }
    
    public func setReactor(loader: @escaping SectionedTableReactor<Section,Item>.DataLoaderProvider,
                           sectionBuilder: @escaping SectionedTableReactor<Section,Item>.SectionBuilder,
                           moreDataLoader: SectionedTableReactor<Section,Item>.MoreDataLoaderProvider? = nil,
                           onItemSelected: SectionedTableReactor<Section,Item>.ItemSelected? = nil,
                           maxCount: Int? = nil) -> SectionedTableReactor<Section,Item> {
        let reactor = SectionedTableReactor<Section,Item>(loader: loader,
                                                 sectionBuilder: sectionBuilder,
                                                 moreDataLoader: moreDataLoader,
                                                 onItemSelected: onItemSelected,
                                                 maxCount: maxCount)
        self.inject(reactor)
        return reactor
    }
}
