//
//  TableVC.swift
//  ModuleCore
//
//  Created by Ponomarev Vasiliy on 02/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import RxDataSources

public typealias TableViewDataSource<Item> = RxTableViewSectionedReloadDataSource<DataSourceSection<Item>>

public final class TableVC<Item>: UIViewController, SceneView, UIScrollViewDelegate {

    public var disposeBag = DisposeBag()

    private var refreshControl: UIRefreshControl?
    public let tableView: UITableView
    private var footerActivityIndicator = UIActivityIndicatorView(style: .gray)
    private let dataSource: TableViewDataSource<Item>
    private let configurator: TableSceneConfigurator

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

    public init(dataSource: TableViewDataSource<Item>, configurator: TableSceneConfigurator) {
        self.dataSource = dataSource
        self.configurator = configurator
        self.tableView = UITableView(frame: .zero)

        if configurator.refreshControll {
            self.refreshControl = UIRefreshControl()
            tableView.refreshControl = refreshControl!
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func bind(reactor: CollectionReactor<Item>) {

        reactor.state
            .map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)


        tableView.rx.itemSelected
            .map(Reactor.Action.selected)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)


        if let delegate = configurator.scrollDelegate {
            tableView.rx.setDelegate(delegate).disposed(by: disposeBag)
        }

        if let refresher = refreshControl {
            refresher.rx.controlEvent(.valueChanged).asObservable()
                .subscribe(onNext: { [weak self] in self?.fire(action: .loadData) })
                .disposed(by: disposeBag)

            bindState(\.inProgressRefreshLoading, to: refresher.rx.isRefreshing)
        }

        if reactor.canLoadMore {
            tableView.rx.didScroll.subscribeNext(self, do: TableVC<Item>.loadMoreIfNeed, bag: disposeBag)
            subscribeNext(reactor.state.map { $0.inProgressLoadMore }, with: TableVC.setProgressMore)
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
}
