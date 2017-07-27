// WARNING: THIS FILE IS AUTOGENERATED
//          BY ChickGen 🐥
// MORE INFO: github: cpageler93/ChickGen
//
//
//  ToDoListClient.swift
//  ToDo List
//
//  Created by Christoph Pageler on 27. Jul 2017, 20:02:08
//
//


import Foundation
import Quack


public class ToDoListClient: QuackClient {

    public let version: String = "v1"

    public func init(servicename: String)  {

        super.init(url: URL(string: "https://\(servicename).api.todolist.com/\(version)")!)

    }

    public func postTodoItem(body: TodoItem) -> QuackResult<TodoItem> {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respond(method: .post,
                       path: "/todoItem",
                       params: preparedParams,
                       model: TodoItem.self)

    }

    public func postTodoItem(body: TodoItem, completion: @escaping (QuackResult<TodoItem> -> ()) -> QuackVoid {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respondAsync(method: .post,
                            path: "/todoItem",
                            params: preparedParams,
                            model: TodoItem.self,
                            completion: completion)

    }

    public func getTodoItem() -> QuackResult<[TodoItem]> {

        return respondWithArray(method: .get,
                                path: "/todoItem",
                                model: TodoItem.self)

    }

    public func getTodoItem(completion: @escaping (QuackResult<[TodoItem]> -> ()) -> QuackVoid {

        return respondWithArrayAsync(method: .get,
                                     path: "/todoItem",
                                     model: TodoItem.self,
                                     completion: completion)

    }

    public func deleteTodoItemWithId(id: String) -> QuackVoid {

        return respond(method: .delete,
                       path: "/todoItem/\(id)",
                       model: Any.self)

    }

    public func deleteTodoItemWithId(id: String, completion: @escaping (QuackVoid -> ()) -> QuackVoid {

        return respondAsync(method: .delete,
                            path: "/todoItem/\(id)",
                            model: Any.self,
                            completion: completion)

    }

    public func patchTodoItemWithId(id: String, body: TodoItem) -> QuackResult<TodoItem> {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respond(method: .patch,
                       path: "/todoItem/\(id)",
                       params: preparedParams,
                       model: TodoItem.self)

    }

    public func patchTodoItemWithId(id: String, body: TodoItem, completion: @escaping (QuackResult<TodoItem> -> ()) -> QuackVoid {

        var map: [String: QuackModel] = [:]
        map["body"] = body
        let preparedParams = preparedParamsWith(map)

        return respondAsync(method: .patch,
                            path: "/todoItem/\(id)",
                            params: preparedParams,
                            model: TodoItem.self,
                            completion: completion)

    }

    public func getTodoItemWithId(id: String) -> QuackResult<TodoItem> {

        return respond(method: .get,
                       path: "/todoItem/\(id)",
                       model: TodoItem.self)

    }

    public func getTodoItemWithId(id: String, completion: @escaping (QuackResult<TodoItem> -> ()) -> QuackVoid {

        return respondAsync(method: .get,
                            path: "/todoItem/\(id)",
                            model: TodoItem.self,
                            completion: completion)

    }

}