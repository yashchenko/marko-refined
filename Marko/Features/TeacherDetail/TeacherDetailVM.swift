    //
    //  TeacherDetalVM.swift
    //  Marko
    //
    //  Created by Ivan on 13.09.2025.
    //

    import Foundation
    
    class TeacherDetailVM {
        
        let teacher: Teacher
        private let timeSlotRepo: TimeSlotRepository
        private let bookingRepo = BookingRepository()
        private var selectedDate: Date = Date()
        var didAuthNeeded: (() -> Void)?
        
        // this var will holds the state, the View will be read from this array
        private(set) var availableTimeSlots: [TimeSlot] = []
        
        // notification closure to tell view to update
        var didTimeSlotsUpdate: (() -> Void)?
        
        init(teacher: Teacher, timeSlotRepo: TimeSlotRepository = TimeSlotRepository()) {
            self.teacher = teacher
            self.timeSlotRepo = timeSlotRepo
            print("we init teacher in TeacherDetailVM for name \(teacher.name)")
        }
        
        func loadTimeSlots(for date: Date) {
            
            print("TeacherDetailViewModel: Date \(date) was selected. Fetching time slots...")
            
            self.selectedDate = date
            
            self.timeSlotRepo.fetchTimeSlots(for: self.teacher.id, on: selectedDate) { [weak self] result in
                
            guard let self = self else { return }
                
            switch result {
            case .failure(let error):
                print("TeacherDetailVM: there error: \(error.localizedDescription)")
                self.availableTimeSlots = []
            case .success(let timeslots):
                self.availableTimeSlots = timeslots
                    .filter { !$0.isBooked && $0.startTime > Date() }
                    .sorted { $0.startTime < $1.startTime }
                
                print("TeacherDetailViewModel: found \(self.availableTimeSlots.count) available slots")

                    }
                
                DispatchQueue.main.async {
                  
                    self.didTimeSlotsUpdate?()

                }
                
            }
        }
        
        func bookSlot(_ slot: TimeSlot, completion: @escaping (Result<Void, Error>) -> Void) {
            
            print("DEBUG: Checking login status. isLoggedIn = \(AuthService.shared.isLoggedIn)")
            print("DEBUG: Current User ID = \(AuthService.shared.currentUserId)")
            
            guard AuthService.shared.isLoggedIn else {
                self.didAuthNeeded?()
                return
            }
            
            // get mock student id
            let studentId = AuthService.shared.currentUserId
            
            print("ViewModel: Attempting to book slot \(slot.id) for student \(studentId)")
            
            // call repository
            bookingRepo.createBooking(teacher: teacher, timeSlot: slot, studentId: studentId) { [weak self] result in
                if case .success = result {
                    self?.loadTimeSlots(for: self?.selectedDate ?? Date())
                }
                completion(result)
            }
            
        }
    }
