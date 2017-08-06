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
            resourceResponse200WithType(type: DataType.array(ofType: DataType.custom(type: type)))
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
            resourceResponse200WithType(type: DataType.custom(type: type))
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
            resourceResponse200WithType(type: DataType.custom(type: type))
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
            resourceResponse200WithType(type: DataType.custom(type: type))
        ]
        let methodWithDefaults = method.applyDefaults(raml: raml)
        return methodWithDefaults
    }
    
    private func resourceResponse200WithType(type: DataType) -> MethodResponse {
        let response200 = MethodResponse(code: 200)
        let response200Body = Body()
        response200Body.type = type
        response200.body = response200Body
        
        return response200
    }

    
}
