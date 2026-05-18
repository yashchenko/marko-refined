//
//  CoreData.swift
//  Marko
//
//  Created by Ivan on 05.05.2026.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() { }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let model = createManagedObjectModel()
        
        let container = NSPersistentContainer(name: "MarkoLocalDB", managedObjectModel: model)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData: Unresolved fatal error \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    private func createManagedObjectModel() -> NSManagedObjectModel {
        
        let model = NSManagedObjectModel()
        
        let lessonEntity = NSEntityDescription()
        lessonEntity.name = "LessonEntity"
        lessonEntity.managedObjectClassName = "NSManagedObject"
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false
        
        let teacherNameAttr = NSAttributeDescription()
        teacherNameAttr.name = "teacherName"
        teacherNameAttr.attributeType = .stringAttributeType
        
        let subjectAttr = NSAttributeDescription()
        subjectAttr.name = "subject"
        subjectAttr.attributeType = .stringAttributeType
        
        let imageURLAttr = NSAttributeDescription()
        imageURLAttr.name = "teacherProfileImageURL"
        imageURLAttr.attributeType = .stringAttributeType
        
        let startTimeAttr = NSAttributeDescription()
        startTimeAttr.name = "startTime"
        startTimeAttr.attributeType = .dateAttributeType
        
        let endTimeAttr = NSAttributeDescription()
        endTimeAttr.name = "endTime"
        endTimeAttr.attributeType = .dateAttributeType
        
        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .stringAttributeType // Status у нас Enum, в БД храним как String (его rawValue)
        
        let meetLinkAttr = NSAttributeDescription()
        meetLinkAttr.name = "zoomMeetingLink"
        meetLinkAttr.attributeType = .stringAttributeType
        meetLinkAttr.isOptional = true
        
        lessonEntity.properties = [
            
            idAttr, teacherNameAttr, subjectAttr, imageURLAttr,
            startTimeAttr, endTimeAttr, statusAttr, meetLinkAttr
            
        ]
        
        model.entities = [lessonEntity]
        
        
        return model
    }
    
    // MARK: - CRUD
    
    func saveLessons(domainLessons: [Lesson]) {
        
        for lesson in domainLessons {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "LessonEntity", into: context)
            
            entity.setValue(lesson.id, forKey: "id")
            entity.setValue(lesson.teacherName, forKey: "teacherName")
            entity.setValue(lesson.subject, forKey: "subject")
            entity.setValue(lesson.teacherProfileImageURL, forKey: "teacherProfileImageURL")
            entity.setValue(lesson.startTime, forKey: "startTime")
            entity.setValue(lesson.endTime, forKey: "endTime")
            entity.setValue(lesson.status.rawValue, forKey: "status") // saving as a text
            entity.setValue(lesson.meetingLink, forKey: "zoomMeetingLink")
                    
        }
        
        do {
            
            try context.save()
            print("💾 Core Data: Успешно закэшировано \(domainLessons.count) уроков.")
        } catch {
            
            print("❌ Core Data Save Error: \(error.localizedDescription)")
        }
        
    }
    
    
    func fetchCachedLessons() -> [Lesson] {
            let request = NSFetchRequest<NSManagedObject>(entityName: "LessonEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
            
            do {
                let results = try context.fetch(request)
                var cachedLessons: [Lesson] = []
                
                for item in results {
                    guard
                        let id = item.value(forKey: "id") as? String,
                        let teacherName = item.value(forKey: "teacherName") as? String,
                        let subject = item.value(forKey: "subject") as? String,
                        let imageURL = item.value(forKey: "teacherProfileImageURL") as? String,
                        let startTime = item.value(forKey: "startTime") as? Date,
                        let endTime = item.value(forKey: "endTime") as? Date,
                        let statusStr = item.value(forKey: "status") as? String,
                        let status = LessonStatus(rawValue: statusStr)
                    else { continue }
                    
                    let meetLink = item.value(forKey: "zoomMeetingLink") as? String
                    
                    // Собираем Lesson из локальных данных.
                    // Недостающие поля заполняем "заглушками", т.к. экран списка их не использует.
                    let lesson = Lesson(
                        id: id,
                        userId: "cached",
                        teacherId: "cached",
                        timeSlotId: "cached",
                        teacherName: teacherName,
                        teacherProfileImageURL: imageURL,
                        subject: subject,
                        studentInitials: "Me",
                        startTime: startTime,
                        endTime: endTime,
                        pricePaidByStudent: 0.0,
                        currency: "UAH",
                        status: status,
                        meetingLink: meetLink
                    )
                    
                    cachedLessons.append(lesson)
                }
                print("📱 Core Data: Загружено \(cachedLessons.count) уроков из кэша.")
                return cachedLessons
                
            } catch {
                print("❌ Core Data Fetch Error: \(error.localizedDescription)")
                return []
            }
        }
        
        private func clearCache() {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                print("❌ Core Data Clear Error: \(error.localizedDescription)")
        }
    }
}
