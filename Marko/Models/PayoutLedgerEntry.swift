//
//  PayoutLedgerEntry.swift
//  Marko
//
//  Created by Ivan on 01.09.2025.
//

import Foundation

struct PayoutLedgerEntry {
    let id: String
    let lessonId: String
    let teacherId: String
    let transactionDate: Date
    let grossRevenue: Double
    let schoolCommission: Double
    let processingFees: Double
    let netPayoutToTeacher: Double
    let payoutStatus: PayoutStatus
}

enum PayoutStatus: String { // Conforming to String for easy storage in Firestore
    case pending
    case paid
}
