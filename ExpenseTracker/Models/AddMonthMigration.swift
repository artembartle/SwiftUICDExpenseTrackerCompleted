// Developed by Artem Bartle

import CoreData

class AddMonthMigration: NSEntityMigrationPolicy {
    
    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        try super.begin(mapping, with: manager)
    }
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                             in mapping: NSEntityMapping,
                                             manager: NSMigrationManager) throws {

        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        let dInstances = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
        for instance in dInstances {
            if let date = instance.value(forKey: "date") as? Date {
                instance.setValue(Month(date: date).rawValue, forKey: "month")
            }
        }
    }
    
}
