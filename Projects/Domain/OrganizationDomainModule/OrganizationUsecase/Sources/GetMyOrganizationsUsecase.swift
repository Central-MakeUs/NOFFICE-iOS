//
//  GetMyOrganizationsUsecase.swift
//  OrganizationUsecase
//
//  Created by DOYEON LEE on 7/22/24.
//

import OrganizationEntity

import RxSwift

public struct GetMyOrganizationsUsecase {
    
    public init() { }
    
    public func execute() -> Observable<[OrganizationEntity]> {
        let mock: [OrganizationEntity] = [
            .init(id: 1, name: "CMC 15th", categories: [1, 2, 3], leader: 1, member: 10),
            .init(id: 2, name: "멋진 동아리", categories: [1, 2, 3], leader: 1, member: 3),
            .init(id: 3, name: "즐거운 소모임", categories: [1, 2, 3], leader: 2, member: 15)
        ]
        
        return .just(mock)
    }
}
