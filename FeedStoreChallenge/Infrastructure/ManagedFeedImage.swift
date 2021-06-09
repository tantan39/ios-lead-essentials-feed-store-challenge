//
//  ManagedFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Tan Tan on 6/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)
final class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
	static func images(feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: feed.map({ local in
			let managedFeedImage = ManagedFeedImage(context: context)
			managedFeedImage.id = local.id
			managedFeedImage.imageDescription = local.description
			managedFeedImage.location = local.location
			managedFeedImage.url = local.url
			return managedFeedImage
		}))
	}

	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
