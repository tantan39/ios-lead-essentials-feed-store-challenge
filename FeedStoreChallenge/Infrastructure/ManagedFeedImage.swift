//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Tan Tan on 6/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache

	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
