//
//  TeacherDetalVM.swift
//  Marko
//
//  Created by Ivan on 13.09.2025.
//

import Foundation
import SpriteKit

class TeacherDetailVM {
    
    let teacher: Teacher
    private let timeSlotRepo: TimeSlotRepository
    
    // this var will holds the state. The View will be read from this array
    private(set) var availableTimeSlots: [TimeSlot] = []
    
    // notification closure to tell the View to update
    var didTimeSlotsUpdate: (() -> Void)?
    
    init(teacher: Teacher, timeSlotRepository: TimeSlotRepository = TimeSlotRepository()) {
        self.teacher = teacher
        self.timeSlotRepo = timeSlotRepository
        print("we init teacher in TeacherDetailVM for name \(teacher.name)")
    }
    
    func loadTimeSlots(for date: Date) {
        print("ViewModel: Date \(date) was selected. Fetching time slots...")
        
        timeSlotRepo.fetchTimeSlots(for: teacher.id, on: date) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Teacher Detail ViewModel say: error downloading slots \(error.localizedDescription)")
                    self.availableTimeSlots = [] // clear old data if error
                case .success(let fetchedSlots):
                    self.availableTimeSlots = fetchedSlots
                        .filter { !$0.isBooked && $0.startTime > Date() }
                        .sorted { $0.startTime < $1.startTime }
                    
                print("ViewModel: Found \(self.availableTimeSlots.count) available slots.")

                }
                
                self.didTimeSlotsUpdate?()
            
            }
        }
    }
    
}
