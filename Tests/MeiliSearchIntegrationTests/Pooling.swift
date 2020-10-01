//
//  File.swift
//
//
//  Created by Pedro Paulo de Amorim on 23/09/2020.
//

import Foundation
@testable import MeiliSearch


public func pool(_ client: MeiliSearch) {

    let semaphore = DispatchSemaphore(value: 1)
    var success: Bool = false

    while true {
        client.health { result in
            switch result {
            case .success:
                success = true
            case .failure:
                Thread.sleep(forTimeInterval: 0.5)
                success = false
            }
            semaphore.signal()
        }
        if !success {
            semaphore.wait()
            continue
        }
        break
    }

}
