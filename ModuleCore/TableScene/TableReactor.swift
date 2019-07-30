//
//  CollectionReactor.swift
//  BrokerNewsModule
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxDataSources


public final class TableReactor<Section:IdentifiableType, Item: IdentifiableType & Equatable>: BaseReactor, SceneReactor {
 
    public typealias SectionData = AnimatableSectionModel<Section, Item>
    public typealias SectionBuilder = ([Item]) -> [SectionData]
    public typealias DataLoaderProvider = () -> Single<[Item]>
    public typealias MoreDataLoaderProvider = (_ offset: Int) -> Single<[Item]>
    public typealias ItemSelected = (Item, IndexPath) -> Void
    
    public enum Action {
        case loadData
        case loadMore
        case selected(IndexPath)
    }
    
    public enum Mutation {
        case inProgressLoad(Bool)
        case inProgressLoadMore(Bool)
        
        case dataReloaded([Item])
        case moreDataLoaded([Item])
        case dataLoadError(Error)
    }
    
    public struct State {
        public var inProgressFirstLoading: Bool { return inProgressLoad && firstLoading }
        public var inProgressRefreshLoading: Bool { return inProgressLoad && !firstLoading }
        public var inProgressLoad = false
        public var inProgressLoadMore = false
        
        public var firstLoading = true
        public var endOfData = false
        public var dataState: DataState = .none
        public var sections: [SectionData] = []
    }
    var canSelectItem: Bool  { return onItemSelected != nil }
    var canLoadMore: Bool { return moreDataLoaderProvider != nil }
    
    let onItemSelected: ItemSelected?
    let dataLoaderProvider: DataLoaderProvider
    let moreDataLoaderProvider: MoreDataLoaderProvider?
    let sectionBuilder: SectionBuilder
    let maxCount: Int?
    
    public init(loader: @escaping DataLoaderProvider,
                sectionBuilder: @escaping SectionBuilder,
                moreDataLoader: MoreDataLoaderProvider? = nil,
                onItemSelected: ItemSelected? = nil,
                maxCount: Int? = nil) {
        self.dataLoaderProvider = loader
        self.moreDataLoaderProvider = moreDataLoader
        self.onItemSelected = onItemSelected
        self.maxCount = maxCount
        self.sectionBuilder = sectionBuilder
    }
    
    public var initialState = State()

    public func mutate(action: Action) -> Observable<Mutation> {

        switch action {
        case .loadData:
            guard currentState.inProgressLoad == false else  { break }
            reloadData()
        case .loadMore:
            guard canLoadMore && currentState.inProgressLoadMore == false && currentState.endOfData == false else { break }
            loadMore()
        case let .selected(indexPath):
            guard canSelectItem else { break }
            let item = currentState.sections[indexPath.section].items[indexPath.row]
            onItemSelected?(item, indexPath)
        }

        return .empty()
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .inProgressLoad(value):
            state.inProgressLoad = value

        case let .inProgressLoadMore(value):
            state.inProgressLoadMore = value

        case let .dataReloaded(items):
            var items = items
            if let maxCount = maxCount {
                items = Array(items.prefix(maxCount))
            }
            state.sections = sectionBuilder(items)
            state.endOfData = false
            state.firstLoading = false
            state.dataState = items.count > 0 ? .hasData : .dataIsEmpty
            
        case let .moreDataLoaded(items):
            var newSections = sectionBuilder(items)
            var oldSections = state.sections
            if let oldLast = oldSections.last, let newFirst = newSections.first, oldLast.identity == newFirst.identity   {
                let lastIndex = oldSections.count - 1
                oldSections[lastIndex].addItems(items: newFirst.items)
                newSections.removeFirst()
                state.sections = oldSections + newSections
            }
            state.endOfData = items.isEmpty
            state.firstLoading = false
            
        case let .dataLoadError(error):
            state.dataState = .error(error)
        }

        return state
    }
}


fileprivate extension TableReactor {
    func reloadData() {
        interact(dataLoaderProvider(),
                 complete: TableReactor<Section,Item>.dataReloaded,
                 error: TableReactor<Section,Item>.loadingFailed,
                 inProgress: Mutation.inProgressLoad)
    }
    
    func dataReloaded(items: [Item]) {
        make(.dataReloaded(items))
    }
    
    func loadMore() {
        guard let moreLoader = moreDataLoaderProvider,
              let offset = currentState.sections.first?.items.count  else { return }
        
        interact(moreLoader(offset),
                 complete: TableReactor<Section,Item>.loadedMore,
                 error: TableReactor<Section,Item>.loadingFailed,
                 inProgress: Mutation.inProgressLoadMore)
    }
    
    func loadedMore(items: [Item]) {
        make(.moreDataLoaded(items))
    }
    
    func loadingFailed(_ error: Error = InterruptedError()) {
        make(.dataLoadError(error))
                print("loadingFailed error = \(error)")
    }
}
