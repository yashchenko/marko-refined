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
    
    init(teacher: Teacher) {
        self.teacher = teacher
        print("we init teacher in TeacherDetailVM for name \(teacher.name)")
    }
    
}
