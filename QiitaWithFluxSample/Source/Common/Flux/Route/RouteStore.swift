//
//  RouteStore.swift
//  QiitaWithFluxSample
//
//  Created by marty-suzuki on 2017/04/12.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import RxSwift

enum LoginDisplayType {
    case root
    case webView
}

enum SearchDisplayType {
    case root
}

final class RouteStore {
    static let shared = RouteStore()
    
    let login: Observable<LoginDisplayType>
    private let _login = PublishSubject<LoginDisplayType>()
    
    let search: Observable<SearchDisplayType>
    private let _search = PublishSubject<SearchDisplayType>()
    
    private let disposeBag = DisposeBag()
    
    init(dispatcher: AnyObservableDispatcher<RouteDispatcher> = .init(.shared)) {
        self.login = _login.asObservable()
                        .shareReplayLatestWhileConnected()
        self.search = _search.asObservable()
                        .shareReplayLatestWhileConnected()
        
        dispatcher.login
            .bindTo(_login)
            .addDisposableTo(disposeBag)
        
        dispatcher.search
            .bindTo(_search)
            .addDisposableTo(disposeBag)
    }
}
