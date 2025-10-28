//
//  TeacherDetailVC.swift
//  Marko
//
//  Created by Ivan on 13.09.2025.
//

import UIKit
import FSCalendar
import SnapKit

class TeacherDetailVC: UIViewController {
    
    private let vm: TeacherDetailVM
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let teacherImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 12
        image.backgroundColor = .systemGray5
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        return calendar
    }()
    
    private let timeSlotsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()

    init(vm: TeacherDetailVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupLayout()
        bindTeacherData()
        
        // Make the calendar interactive
        calendarView.delegate = self
        
        // Subscribe to ViewModel updates
        vm.didTimeSlotsUpdate = { [weak self] in
            
            self?.updateSlotsUI()
        }

        // Trigger the initial fetch for today's date
        vm.loadTimeSlots(for: Date())
    }
    

    
    private func setupViews() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubviews(view: [
            
            teacherImageView,
            nameLabel,
            headlineLabel,
            descriptionLabel,
            calendarView,
            timeSlotsStack
            
        ])
        
        
        
    }
    
    private func bindTeacherData() {
        
        let teacher = vm.teacher
        
        title = teacher.name
        
        if let teacherPhotoUrl = URL(string: teacher.profileImageURL) {
            
            teacherImageView.kf.setImage(with: teacherPhotoUrl)
        }
        
        headlineLabel.text = teacher.headline
        nameLabel.text = teacher.name
        descriptionLabel.text = teacher.fullDescription
    }
    
    
    private func setupLayout() {
        
        let padding: CGFloat = 20
        
        // scroll view constraints
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // stack view constraints
        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(padding)
            
            //width should match the scroll view frame width
            make.width.equalTo(scrollView.snp.width).offset(-2 * padding)
        }
        
        // we only need to set the height, because the width is handled by the stack view
        teacherImageView.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
        
        //fscalendar need explicit height to render correctly
        calendarView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    private func updateSlotsUI() {
        // Clear out any old slot views
        timeSlotsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if vm.availableTimeSlots.isEmpty {
            let noSlotsLabel = UILabel()
            noSlotsLabel.text = "No available slots for this date."
            noSlotsLabel.textColor = .secondaryLabel
            noSlotsLabel.textAlignment = .center
            timeSlotsStack.addArrangedSubview(noSlotsLabel)
        } else {
            for slot in vm.availableTimeSlots {
                // For now, we'll just display the time. A future ticket will add a "Book" button.
                let slotLabel = UILabel()
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let startTime = formatter.string(from: slot.startTime)
                let endTime = formatter.string(from: slot.endTime)
                slotLabel.text = "  \(startTime) - \(endTime)  "
                slotLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                slotLabel.textAlignment = .center
                slotLabel.layer.borderColor = UIColor.systemBlue.cgColor
                slotLabel.layer.borderWidth = 1.5
                slotLabel.layer.cornerRadius = 8
                slotLabel.snp.makeConstraints { make in
                    make.height.equalTo(50)
                }
                
                timeSlotsStack.addArrangedSubview(slotLabel)
            }
        }
    }
}


extension TeacherDetailVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // The View's only job is to report the action to the ViewModel.
        vm.loadTimeSlots(for: date)
    }
    
}
