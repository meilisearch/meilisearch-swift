//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import MeiliSearch
import Foundation

private let client = try! MeiliSearch(Config.default(apiKey: "masterKey"))

private struct Movie: Codable, Equatable {

    let id: Int
    let title: String
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case comment
    }

    init(id: Int, title: String, comment: String? = nil) {
        self.id = id
        self.title = title
        self.comment = comment
    }

}

// 127.0.0.1:8181/index?uid=books_test
func index(request: HTTPRequest, response: HTTPResponse) {

  guard let uid: String = request.param(name: "uid") else {
    response.setHeader(.contentType, value: "application/json")
    let body = """
    {
      "error":0,
      "message":"Missing uid"
    }
    """
    response.appendBody(string: body)
    response.completed()
    return
  }

  client.getIndex(UID: uid) { result in

    switch result {
    case .success(let index):

      let encoder: JSONEncoder = JSONEncoder()
      let data: Data = try! encoder.encode(index)
      let body: String = String(decoding: data, as: UTF8.self)

      response.setHeader(.contentType, value: "application/json")
      response.appendBody(string: body)

    case .failure:

      let body = """
      {
        "error": 1,
        "message": "Failed to get Index for uid: \(uid)"
      }
      """

      response.setHeader(.contentType, value: "application/json")
      response.appendBody(string: body)

    }

    response.completed()

  }

}

// 127.0.0.1:8181/search?query=botman
func search(request: HTTPRequest, response: HTTPResponse) {

  guard let query: String = request.param(name: "query") else {
    response.setHeader(.contentType, value: "application/json")
    let body = """
    {
      "error":0,
      "message":"Missing query"
    }
    """
    response.appendBody(string: body)
    response.completed()
    return
  }

  let searchParameters = SearchParameters.query(query)

  client.search(UID: "books_test", searchParameters) { (result: Result<SearchResult<Movie>, Swift.Error>) in

    switch result {
    case .success(let searchResult):

      let jsonData = try! JSONSerialization.data(
        withJSONObject: searchResult.hits,
        options: [])
      let body: String = String(decoding: jsonData, as: UTF8.self)

      response.setHeader(.contentType, value: "application/json")
      response.appendBody(string: body)

    case .failure:

      let body = """
      {
        "error": 1,
        "message": "Failed to get Document for query: \(query)"
      }
      """

      response.setHeader(.contentType, value: "application/json")
      response.appendBody(string: body)

    }

    response.completed()

  }

}

var routes = Routes()
routes.add(method: .get, uri: "/index", handler: index)
routes.add(method: .get, uri: "/search", handler: search)
try HTTPServer.launch(name: "localhost",
					  port: 8181,
					  routes: routes,
					  responseFilters: [
						(PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])
