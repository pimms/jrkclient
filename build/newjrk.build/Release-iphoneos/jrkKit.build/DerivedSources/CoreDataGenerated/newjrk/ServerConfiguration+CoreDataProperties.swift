//
//  ServerConfiguration+CoreDataProperties.swift
//  
//
//  Created by pimms on 10/02/2020.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ServerConfiguration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServerConfiguration> {
        return NSFetchRequest<ServerConfiguration>(entityName: "ServerConfiguration")
    }

    @NSManaged public var name: String?
    @NSManaged public var url: URL?

}
