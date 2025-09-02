//
//  TimeSlot.swift
//  Marko
//
//  Created by Ivan on 01.09.2025.
//


import Foundation

struct TimeSlot {
    let id: String
    let teacherId: String
    let startTime: Date
    let endTime: Date
    var isBooked: Bool
    var bookedByUserId: String?
}
