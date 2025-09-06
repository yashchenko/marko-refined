//
//  HomeViewModel.swift
//  Marko
//
//  Created by Ivan on 05.09.2025.
//

import Foundation

class HomeViewModel {

    private var db = TeacherRepository()

    private(set) var teachersArray: [Teacher] = []

    var closureOutlet: () -> () = { }

    init(teacherDatabase: TeacherRepository) {
        self.db = teacherDatabase

    }

    func fetchTeachers() {

        db.fetchTeachers { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let teachers):
                self.teachersArray = teachers
                print("success to fetch teachers in home view model")
                DispatchQueue.main.async {
                    self.closureOutlet()
                }
            }
        }
    }
}
