//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			do {
				let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				request.returnsObjectsAsFaults = false
				if let cache = try context.fetch(request).first {
					completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			do {
				let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
				_ = try context.fetch(request).first.map(context.delete)

				let cache = ManagedCache(context: context)

				cache.timestamp = timestamp
				cache.feed = NSOrderedSet(array: feed.map({ local in
					let managedFeedImage = ManagedFeedImage(context: context)
					managedFeedImage.id = local.id
					managedFeedImage.imageDescription = local.description
					managedFeedImage.location = local.location
					managedFeedImage.url = local.url
					return managedFeedImage
				}))

				try context.save()
				completion(nil)
			} catch {
				context.rollback()
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	var localFeed: [LocalFeedImage] {
		return feed.compactMap({ ($0 as? ManagedFeedImage)?.local })
	}
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache

	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
