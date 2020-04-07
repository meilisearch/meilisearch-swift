//
//  File.swift
//  
//
//  Created by Pedro Paulo de Amorim on 07/04/2020.
//

import Foundation

public extension MeiliSearch {

  enum Error: Swift.Error {
    case serverNotFound
    case dataNotFound
  }

}

extension MeiliSearch.Error: Equatable {}
