//
//  CollectionReactor.swift
//  BrokerNewsModule
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxDataSources

public struct ListPage {
    public let offset: Int
    public let count: Int
    
    public init(offset: Int, count: Int) {
        self.count = count
        self.offset = offset
    }
    
    public static var first20: ListPage {
        return .init(offset: 0, count: 20)
    }
    
    public var next: ListPage {
        return .init(offset: self.offset + self.count, count: self.count)
    }
}

public final class SectionedTableReactor<Section:IdentifiableType, Item: IdentifiableType & Equatable>: BaseReactor, SceneReactor {
    
    public struct Config {
        public let onItemSelected: ItemSelected?
        public let dataLoader: DataLoaderProvider
        public let sectionBuilder: SectionBuilder
        public let defaultPage: ListPage
        public let canLoadMore: Bool
        
        public init(onItemSelected: ItemSelected?,
                    dataLoader: @escaping DataLoaderProvider,
                    sectionBuilder: @escaping SectionBuilder,
                    defaultPage: ListPage = .first20,
                    canLoadMore: Bool = true) {
            self.onItemSelected = onItemSelected
            self.dataLoader = dataLoader
            self.sectionBuilder = sectionBuilder
            self.defaultPage = defaultPage
            self.canLoadMore = canLoadMore
        }
    }
    
    public typealias SectionData = AnimatableSectionModel<Section, Item>
    public typealias SectionBuilder = ([Item]) -> [SectionData]
    public typealias DataLoaderProvider = (ListPage) -> Single<[Item]>
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
        public fileprivate(set) var currentPage: ListPage
    }
    
    var canSelectItem: Bool  { return config.onItemSelected != nil }
    
    public let config: Config
    public let initialState: State
    
    public init(config: Config) {
        self.config = config
        self.initialState = State(currentPage: config.defaultPage)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .loadData:
            guard currentState.inProgressLoad == false else  { break }
            reloadData()
        case .loadMore:
            guard config.canLoadMore && currentState.inProgressLoadMore == false && currentState.endOfData == false else { break }
            loadMore()
        case let .selected(indexPath):
            guard canSelectItem else { break }
            let item = currentState.sections[indexPath.section].items[indexPath.row]
            config.onItemSelected?(item, indexPath)
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
            state.currentPage = config.defaultPage
            state.sections = config.sectionBuilder(items)
            state.endOfData = false
            state.firstLoading = false
            state.dataState = items.count > 0 ? .hasData : .dataIsEmpty
            
        case let .moreDataLoaded(items):
            state.currentPage = currentState.currentPage.next
            let newSections = config.sectionBuilder(items)
            var sections = state.sections
            SectionData.merge(new: newSections, to: &sections)
            state.sections = sections
            state.endOfData = items.count < state.currentPage.count
            state.firstLoading = false
            
        case let .dataLoadError(error):
            state.dataState = .error(error)
        }
        
        return state
    }
}


fileprivate extension SectionedTableReactor {
    func reloadData() {
        interact(config.dataLoader(config.defaultPage),
                 complete: SectionedTableReactor<Section,Item>.dataReloaded,
                 error: SectionedTableReactor<Section,Item>.loadingFailed,
                 inProgress: Mutation.inProgressLoad)
    }
    
    func dataReloaded(items: [Item]) {
        make(.dataReloaded(items))
    }
    
    func loadMore() {
        interact(config.dataLoader(currentState.currentPage.next),
                 complete: SectionedTableReactor<Section,Item>.loadedMore,
                 error: SectionedTableReactor<Section,Item>.loadingFailed,
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
