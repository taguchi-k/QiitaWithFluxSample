//
//  LoginViewModelCase.swift
//  QiitaWithFluxSample
//
//  Created by marty-suzuki on 2017/04/20.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import QiitaSession
@testable import QiitaWithFluxSample

private class RequestAccessTokenMockSession: QiitaSessionType {
    func send<T : QiitaRequest>(_ request: T) -> Observable<T.Response> {
        let element = AccessTokensResponse.testable.make(cliendId: "clientId",
                                                         scopes: [],
                                                         token: "accessToken") as! T.Response
        return Observable.just(element)
    }
}

class LoginViewModelCase: XCTestCase {
    var applicationAction: ApplicationAction!
    var applicationObserverDispatcherForAction: ApplicationDispatcher!
    var applicationObserverDispatcherForStore: ApplicationDispatcher!
    var applicationObservableDispatcherForStore: ApplicationDispatcher!
    var applicationStore: ApplicationStore!
    
    var loginViewModel: LoginViewModel!
    var requestAccessTokenWithCode: PublishSubject<String>!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let routeAction = RouteAction(dispatcher: RouteDispatcher.testable.make().dispatcher)
        let mockSession = RequestAccessTokenMockSession()
        let config = Config(baseUrl: "https://github.com",
                            redirectUrl: "https://github.com",
                            clientId: "clientId",
                            clientSecret: "secret")
        applicationObserverDispatcherForAction = ApplicationDispatcher.testable.make()
        applicationAction = ApplicationAction(dispatcher: applicationObserverDispatcherForAction.dispatcher,
                                              routeAction: routeAction,
                                              session: mockSession,
                                              config: config)
        let applicationDispatcher = ApplicationDispatcher.testable.make()
        applicationObserverDispatcherForStore = applicationDispatcher
        applicationObservableDispatcherForStore = applicationDispatcher
        applicationStore = ApplicationStore(registrator: applicationObservableDispatcherForStore.registrator)
        requestAccessTokenWithCode = PublishSubject<String>()
        loginViewModel = LoginViewModel(applicationStore: applicationStore,
                                        applicationAction: applicationAction,
                                        config: config,
                                        requestAccessTokenWithCode: requestAccessTokenWithCode)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsLoading() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        requestAccessTokenWithCode.onNext("code")
        XCTAssertTrue(loginViewModel.isLoading.value)
        
        applicationObserverDispatcherForStore.dispatcher.accessToken.onNext("accessToken2")
        XCTAssertFalse(loginViewModel.isLoading.value)
    }
    
    func testAuthorizeUrl() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertTrue(loginViewModel.authorizeUrl.absoluteString.hasPrefix("https://github.com/v2/oauth/authorize?client_id=clientId&scope=read_qiita+write_qiita&state="))
    }
}
