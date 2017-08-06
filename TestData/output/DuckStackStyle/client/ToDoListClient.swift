// WARNING: THIS FILE IS AUTOGENERATED
//          BY ChickGen 🐥
// MORE INFO: github: cpageler93/ChickGen
//
//
//  ToDoListClient.swift
//  ToDo List
//
//  Created by Christoph Pageler on 6. Aug 2017, 20:16:52
//
//


import Foundation
import Quack

public class ToDoListClient: QuackClient {

    public let version: String = "v1"

    public init(servicename: String)  {

        super.init(url: URL(string: "https://\(servicename).api.todolist.com/\(version)")!)

    }

    public func getTodoItems() -> QuackResult<[TodoItem]> {

        return respondWithArray(method: .get,
                                path: "/todoItems",
                                model: TodoItem.self)

    }

    public func getTodoItems(completion: @escaping (QuackResult<[TodoItem]> -> ())) -> QuackVoid {

        return respondWithArrayAsync(method: .get,
                                     path: "/todoItems",
                                     model: TodoItem.self,
                                     completion: completion)

    }

    public func postTodoItems(body: TodoItem) -> QuackResult<TodoItem> {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respond(method: .post,
                       path: "/todoItems",
                       params: preparedParams,
                       model: TodoItem.self)

    }

    public func postTodoItems(body: TodoItem, completion: @escaping (QuackResult<TodoItem> -> ())) -> QuackVoid {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respondAsync(method: .post,
                            path: "/todoItems",
                            params: preparedParams,
                            model: TodoItem.self,
                            completion: completion)

    }

    public func getTodoItemsWithId(id: Int) -> QuackResult<TodoItem> {

        return respond(method: .get,
                       path: "/todoItems/\(id)",
                       model: TodoItem.self)

    }

    public func getTodoItemsWithId(id: Int, completion: @escaping (QuackResult<TodoItem> -> ())) -> QuackVoid {

        return respondAsync(method: .get,
                            path: "/todoItems/\(id)",
                            model: TodoItem.self,
                            completion: completion)

    }

    public func patchTodoItemsWithId(id: Int, body: TodoItem) -> QuackResult<TodoItem> {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respond(method: .patch,
                       path: "/todoItems/\(id)",
                       params: preparedParams,
                       model: TodoItem.self)

    }

    public func patchTodoItemsWithId(id: Int, body: TodoItem, completion: @escaping (QuackResult<TodoItem> -> ())) -> QuackVoid {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respondAsync(method: .patch,
                            path: "/todoItems/\(id)",
                            params: preparedParams,
                            model: TodoItem.self,
                            completion: completion)

    }

}