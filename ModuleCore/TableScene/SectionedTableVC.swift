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

public final class SectionedTableVC<Section:IdentifiableType, Item: IdentifiableType & Equatable>: UIViewController, SceneView, UITableViewDelegate {
    
    public typealias ViewForSectionBuilder = (_ tableView: UITableView, _ sectionIndex: Int,  _ model: Section) -> UIView?
    
    public var disposeBag = DisposeBag()
    private var refreshControl: UIRefreshControl?
    private var footerActivityIndicator = UIActivityIndicatorView(style: .gray)
    public var tableView: UITableView { return config.tableView }
    public weak var scrollDelegate: UIScrollViewDelegate?
 
    override public func viewDidLoad() {
        super.viewDidLoad()
        config.tableView.allowsSelection = vm.canSelectItem
        view.layoutMargins = .zero
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        if let customContraintsBuilder = config.customContraintsBuilder {
            customContraintsBuilder(self, tableView)
        } else {
            NSLayoutConstraint.activate([
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for indexPath in config.tableView.indexPathsForSelectedRows ?? [] {
            config.tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    private let config: Config
    
    public struct Config {
        public let dataSource: SectionedTableViewDataSource<Section,Item>
        public let tableView: UITableView
        public let customContraintsBuilder: ((UIViewController, UITableView) -> Void)?
        public let canRefresh: Bool
        public let viewForSection: ViewForSectionBuilder 
        
        public init(dataSource: SectionedTableViewDataSource<Section,Item>, tableView: UITableView, canRefresh: Bool, customContraintsBuilder: ((UIViewController, UITableView) -> Void)? = nil, sectionForView: @escaping ViewForSectionBuilder ) {
            self.dataSource = dataSource
            self.tableView = tableView
            self.viewForSection = sectionForView
            self.canRefresh = canRefresh
            self.customContraintsBuilder = customContraintsBuilder
        }
    }
    
    public init(config: Config) {
        self.config = config
        
        if config.canRefresh {
            self.refreshControl = UIRefreshControl()
            if #available(iOS 10.0, *) {
                config.tableView.refreshControl = refreshControl!
            } else {
                config.tableView.addSubview(refreshControl!)
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
            .bind(to: config.tableView.rx.items(dataSource: config.dataSource))
            .disposed(by: disposeBag)
        
        
        config.tableView.rx.itemSelected
            .map(Reactor.Action.selected)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        if let refresher = refreshControl {
            refresher.rx.controlEvent(.valueChanged).asObservable()
                .subscribe(onNext: { [weak self] in self?.fire(action: .loadData) })
                .disposed(by: disposeBag)
            
            bindState(\.inProgressRefreshLoading, to: refresher.rx.isRefreshing)
        }
        
        config.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        if reactor.config.canLoadMore {
            config.tableView.rx.didScroll.subscribeNext(self, do: SectionedTableVC<Section,Item>.loadMoreIfNeed, bag: disposeBag)
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
        
        let scrollView = config.tableView as UIScrollView
        
        if scrollView.contentSize.height < scrollView.frame.size.height { return }
        
        let currentOffset  = scrollView.contentOffset.y
        let maiximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset    = maiximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            fire(action: .loadMore)
        }
    }
    
    public func setReactor(config: SectionedTableReactor<Section, Item>.Config) -> SectionedTableReactor<Section,Item> {
        let reactor = SectionedTableReactor<Section,Item>(config: config)
        self.inject(reactor)
        return reactor
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = vm.currentState.sections[section]
        return config.viewForSection(tableView, section, sectionData.model)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
         scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
}
