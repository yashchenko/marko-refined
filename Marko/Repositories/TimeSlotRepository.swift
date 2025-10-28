//
//  TimeSlotRepository.swift
//  Marko
//
//  Created by Ivan on 26.10.2025.
//

import Foundation
import FirebaseFirestore

class TimeSlotRepository {
    
    private let db = Firestore.firestore()
    private let collectionName = "timeSlots"
    
    func fetchTimeSlots(for teacherID: String, on date: Date, completion: @escaping (Result<[TimeSlot], Error>) -> Void) {
        
        // define the date range, from the start of day to the end of the day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            
            completion(.failure(NSError(domain: "TimeSlotRepo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't calculate end of day"])))
            return
        }
        
        print("TimeSlotRepo: Fetching slots for teacher '\(teacherID)' between \(startOfDay) and \(endOfDay)")
        
        db.collection(collectionName)
            .whereField("teacherId", isEqualTo: teacherID)
            .whereField("startTime", isGreaterThanOrEqualTo: startOfDay)
            .whereField("startTime", isLessThan: endOfDay)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("TimeSlotRepo say: Error fetching time slots: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    
                    print("TimeslotRepo say: no documents found")
                    completion(.success([]))
                    return
                }
                
                let timeslots = documents.compactMap { doc -> TimeSlot? in
                    let data = doc.data()
                    let id = doc.documentID
                    
                    guard
                        let teacherId = data["teacherId"] as? String, // this is fragile place, can be TeacherID with capital D
                        let startTimestamp = data["startTime"] as? Timestamp,
                        let endTimestamp = data["endTime"] as? Timestamp
                    
                    else {
                        
                        print("TimeSlotRepo say: skipping document \(id) due to missing fields")
                        return nil
                    }
                    
                    return TimeSlot(id: id, teacherId: teacherId, startTime: startTimestamp.dateValue(), endTime: endTimestamp.dateValue(), isBooked: data["isBooked"] as? Bool ?? false, bookedByUserId: data["bookedByUserId"] as? String)
                }
                
                print("TimeSlotRepo say: Successfully fetched and mapped \(timeslots.count) time slots")
                completion(.success(timeslots))
            }
    }
    
}
