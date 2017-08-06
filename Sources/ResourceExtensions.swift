//
//  ResourceExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 06.08.17.
//

import Foundation
import RAML

public extension Resource {
    
    public func vaporRoutePathName() -> String? {
        var routePath = self.path
        routePath = routePath.replacingParams { _ in "" }
        routePath = routePath.withRemovedPrefix("/")
        routePath = routePath.withRemovedSuffix("/")
        
        if routePath.characters.count > 0 {
            return routePath
        } else {
            return nil
        }
    }
    
    public func vaporRoutePathParams() -> String {
        var params: [String] = []
        params.append("\"/\"")
        for uriParameter in uriParameters ?? [] {
            params.append("\":\(uriParameter.identifier)\"")
        }
        return params.joined(separator: ", ")
    }
    
    public func resourceOfType() -> String? {
        guard let annotation = annotationWith(name: "resourceOfType") else { return nil }
        guard let singleValue = annotation.singleValue else { return nil }
        return singleValue
    }
    
    public func isResourceOfType() -> Bool {
        return resourceOfType() != nil
    }
    
    public func resourceMethodForGetList(inRaml raml: RAML, withType type: String) -> ResourceMethod {
        let method = ResourceMethod(type: .get)
        method.displayName = "Resource GET List"
        method.responses = [
            resourceResponse(type: DataType.array(ofType: DataType.custom(type: type)))
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    public func resourceMethodForPostItem(inRaml raml: RAML, withType type: String) -> ResourceMethod {
        let method = ResourceMethod(type: .post)
        method.displayName = "Resource POST New Item"
        let methodBody = Body()
        methodBody.type = DataType.custom(type: type)
        method.body = methodBody
        method.responses = [
            resourceResponse(code: 201,
                             type: DataType.custom(type: type))
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    public func addSingleItemResource() -> Resource {
        let singleItemResource = Resource(path: "/{id}")
        let idUriParameter = URIParameter(identifier: "id")
        idUriParameter.description = "ID of Single Item"
        idUriParameter.required = true
        idUriParameter.type = URIParameter.ParameterType.integer
        singleItemResource.uriParameters = [idUriParameter]
        
        if resources == nil { resources = [] }
        resources?.append(singleItemResource)
        return singleItemResource
    }
    
    public func resourceMethodForGetSingleItem(inRaml raml: RAML, withType type: String) -> ResourceMethod {
        let method = ResourceMethod(type: .get)
        method.displayName = "Resource GET Single Item"
        method.responses = [
            resourceResponse(type: DataType.custom(type: type))
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    public func resourceMethodForPatchSingleItem(inRaml raml: RAML, withType type: String) -> ResourceMethod {
        let method = ResourceMethod(type: .patch)
        method.displayName = "Resource PATCH Single Item"
        let methodBody = Body()
        methodBody.type = DataType.custom(type: type)
        method.body = methodBody
        method.responses = [
            resourceResponse(type: DataType.custom(type: type))
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    public func resourceMethodForDeleteSingleItem(inRaml raml: RAML, withType type: String) -> ResourceMethod {
        let method = ResourceMethod(type: .delete)
        method.displayName = "Resource DELETE Single Item"
        method.responses = [
            resourceResponse(code: 204,
                             type: DataType.any)
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    private func resourceResponse(code: Int = 200,
                                  type: DataType) -> MethodResponse {
        let response = MethodResponse(code: code)
        let responseBody = Body()
        responseBody.type = type
        response.body = responseBody
        return response
    }

    
}
