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

let client = try! MeiliSearch()

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

  client.getIndex(uid: uid) { result in

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

  client.search(uid: "movies", searchParameters) { result in

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
