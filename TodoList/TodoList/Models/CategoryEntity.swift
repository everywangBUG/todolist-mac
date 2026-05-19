import CoreData
import Foundation

@objc(Category)
public class CategoryEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "Category")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var tasks: NSSet?
}

extension CategoryEntity: Identifiable {}
