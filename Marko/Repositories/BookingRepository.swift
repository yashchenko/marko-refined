//
//  BookingRepository.swift
//  Marko
//
//  Created by Ivan on 23.12.2025.
//

import Foundation
import FirebaseFirestore

class BookingRepository {
    
    private let db = Firestore.firestore()
    
    // STRICT B2B MODEL
    // Teacher is an independent contractor (FOP).
    // Platform calculates payouts based on Lesson Price - Fees.
    func createBooking(teacher: Teacher,
                       timeSlot: TimeSlot,
                       studentId: String,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        
        // 1. References
        let timeSlotRef = db.collection("timeSlots").document(timeSlot.id)
        let newLessonRef = db.collection("lessons").document()
        let ledgerRef = db.collection("payout_ledger").document()
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            // A. Check Availability (Atomic check)
            let slotDocument: DocumentSnapshot
            do {
                try slotDocument = transaction.getDocument(timeSlotRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if let isBooked = slotDocument.data()?["isBooked"] as? Bool, isBooked == true {
                let error = NSError(domain: "MarkoApp", code: 409, userInfo: [NSLocalizedDescriptionKey: "Slot already booked"])
                errorPointer?.pointee = error
                return nil
            }
            
            // B. Financial Calculation (B2B Model / UAH)
            
            // Renaming for semantic hygiene:
            let lessonPrice = Double(teacher.hourlyRate)
            let grossAmount = lessonPrice
            
            // Rates configuration (Hardcoded for MVP, usually comes from Config)
            let bankFeeRate = 0.02      // 2%
            let commissionRate = 0.20   // 20%
            
            // Calculations
            let bankFeeAmount = grossAmount * bankFeeRate
            let commissionAmount = grossAmount * commissionRate
            
            // Bank acquiring fee (~2%) is deducted from the gross amount
            // and effectively reduces the teacher payout.
            let netPayout = grossAmount - bankFeeAmount - commissionAmount
            
            // SAFETY GUARD: Prevent negative payouts
            if netPayout <= 0 {
                let error = NSError(
                    domain: "MarkoApp",
                    code: 422,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid pricing configuration: Net payout is zero or negative."]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            
            // C. Prepare Data
            
            // Lesson Document
            let lessonData: [String: Any] = [
                "teacherId": teacher.id,
                "studentId": studentId,
                "timeSlotId": timeSlot.id,
                "teacherName": teacher.name,
                "teacherProfileImageURL": teacher.profileImageURL,
                "subject": teacher.headline,
                "startTime": timeSlot.startTime,
                "endTime": timeSlot.endTime,
                "pricePaid": grossAmount,
                "currency": "UAH",
                "status": "upcoming",
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            // Ledger Document (Financial Record)
            let ledgerData: [String: Any] = [
                "lessonId": newLessonRef.documentID,
                "teacherId": teacher.id,
                "transactionDate": FieldValue.serverTimestamp(),
                "type": "b2b_service_payout",
                
                // Detailed breakdown for accounting
                "grossAmount": grossAmount,
                "bankProcessingFee": bankFeeAmount,
                "platformCommission": commissionAmount,
                "netPayout": netPayout,
                
                // AUDIT TRAIL: Store rates to know WHY numbers are like this
                "appliedRates": [
                    "bankFeeRate": bankFeeRate,
                    "commissionRate": commissionRate
                ],
                
                "currency": "UAH",
                "status": "pending"
            ]
            
            // D. Write (Atomic Commit)
            transaction.setData(lessonData, forDocument: newLessonRef)
            transaction.setData(ledgerData, forDocument: ledgerRef)
            transaction.updateData([
                "isBooked": true,
                "bookedByUserId": studentId
            ], forDocument: timeSlotRef)
            
            return nil
            
        }) { (_, error) in
            if let error = error {
                print("Booking transaction failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Booking transaction successful. Ledger created.")
                completion(.success(()))
            }
        }
    }
}
