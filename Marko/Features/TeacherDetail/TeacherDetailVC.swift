//
//  TeacherDetailVC.swift
//  Marko
//
//  Created by Ivan on 13.09.2025.
//

import UIKit
import FSCalendar
import SnapKit
import PassKit

class TeacherDetailVC: UIViewController {
    
    private let vm: TeacherDetailVM

    private var selectedSlotToBook: TimeSlot?
    
    private var isPaymentAuthorized = false
    
    // MARK: - UI
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupLayout()
        bindTeacherData()
        
        calendarView.delegate = self
        
        vm.didTimeSlotsUpdate = { [weak self] in
            
            self?.updateSlotsUI()
            
            
        }
        
        vm.loadTimeSlots(for: Date())
        
    }
    
    // MARK: - Setup
    
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
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(padding)
            make.width.equalTo(scrollView.snp.width).offset(-2 * padding)
        }
        
        teacherImageView.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
        
        calendarView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    // MARK: - Booking UI
    
    private func updateSlotsUI() {
        
        timeSlotsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if vm.availableTimeSlots.isEmpty {
            
            let noSlotsLabel = UILabel()
            noSlotsLabel.text = "No available slots for this date."
            noSlotsLabel.textColor = .secondaryLabel
            noSlotsLabel.textAlignment = .center
            timeSlotsStack.addArrangedSubview(noSlotsLabel)
        } else {
            for slot in vm.availableTimeSlots {
                let bookButton = UIButton(type: .system)
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let startTime = formatter.string(from: slot.startTime)
                let endTime = formatter.string(from: slot.endTime)
                
                bookButton.setTitle("Book \(startTime) - \(endTime) • \(vm.teacher.hourlyRate) UAH", for: .normal)
                bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
                
                bookButton.backgroundColor = .systemBlue
                bookButton.setTitleColor(.white, for: .normal)
                bookButton.layer.cornerRadius = 8
                
                bookButton.snp.makeConstraints { make in
                    make.height.equalTo(50)
                }
                
                // action
                let action = UIAction { [weak self] _ in
                    
                    self?.handleBookingTap(for: slot)
                }
                
                bookButton.addAction(action, for: .touchUpInside)
                timeSlotsStack.addArrangedSubview(bookButton)
            }
        }
    }
    
    // MARK: - Payment & Booking Logic
    
    private func handleBookingTap(for slot: TimeSlot) {
        
        guard AuthService.shared.isLoggedIn else {
            vm.bookSlot(slot) { _ in }
            return
        }
        
        self.selectedSlotToBook = slot
        self.isPaymentAuthorized = false
        
        let request  = PKPaymentRequest()
        
        // Use a dummy merchant ID if you don't have a real one.
        // On simulator, this might sometimes work for UI testing.
        request.merchantIdentifier = "merchant.com.marko.test"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "UA"
        request.currencyCode = "UAH"
        
        let amount = NSDecimalNumber(value: vm.teacher.hourlyRate)
        
        let item = PKPaymentSummaryItem(label: "Lesson with \(vm.teacher.name)", amount: amount)
        request.paymentSummaryItems = [item]
        
        
        // 2. Check if we can present the controller. Note: Without a paid account capability, init might fail or return nil
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        } else {
            // 3. FALLBACK: If Apple Pay fails to load (no certs), show a confirmation sheet. This ensures you can still test the DB logic.
            print("⚠️ Apple Pay not available (Missing Entitlements). Using Fallback Sheet.")
            presentFallbackPaymentSheet(amount: amount)
        }
    }
    
    //  Fallback UI for testing without Paid Account
    func presentFallbackPaymentSheet(amount: NSDecimalNumber) {
        let alert = UIAlertController(title: "Confirm Payment", message: "Apple Pay is not configured. Simulate payment of \(amount) UAH?", preferredStyle: .actionSheet)
        
        let payAction = UIAlertAction(title: "Pay \(amount) UAH", style: .default) { [weak self] _ in
            guard let self = self, let slot = self.selectedSlotToBook else { return }
            self.performDatabaseBooking(for: slot)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(payAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    // actual DB call
    private func performDatabaseBooking(for slot: TimeSlot) {
        
        vm.bookSlot(slot) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showAlert(title: "Success! 🎉", message: "Lesson booked successfully.")
                case .failure(let error):
                    self?.showAlert(title: "Booking Failed", message: error.localizedDescription)
                }
            }
        }
        
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
}


// MARK: - FSCalendar Delegate

extension TeacherDetailVC: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        vm.loadTimeSlots(for: date)
    }
}

// MARK: - Apple Pay Delegate
extension TeacherDetailVC: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        self.isPaymentAuthorized = true
        
        // User tapped "Pay" with TouchID/FaceID in Simulator. We simulate success
        handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // sheet dismissed

        controller.dismiss(animated: true) { [weak self] in
            guard let self = self, let slot = self.selectedSlotToBook else { return}
            
            if self.isPaymentAuthorized {
                
                self.performDatabaseBooking(for: slot)
                
            } else {
                
                print("Payment cancelled by user. No booking created.")
            }
        }
    } 
}




 // -------------------------

// reference below

//
//import UIKit
//import FSCalendar
//import SnapKit
//import PassKit // [MRK-21] Apple Pay Framework
//
//class TeacherDetailVC: UIViewController {
//
//    private let vm: TeacherDetailVM
//
//    // [MRK-21] Holds the slot user intends to book
//    private var selectedSlotToBook: TimeSlot?
//
//    // MARK: - UI Elements
//
//    private let headlineLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private var scrollView: UIScrollView = {
//        let scroll = UIScrollView()
//        scroll.translatesAutoresizingMaskIntoConstraints = false
//        return scroll
//    }()
//
//    private var contentStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.spacing = 20
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//
//    private let teacherImageView: UIImageView = {
//        let image = UIImageView()
//        image.contentMode = .scaleAspectFit
//        image.clipsToBounds = true
//        image.layer.cornerRadius = 12
//        image.backgroundColor = .systemGray5
//        image.translatesAutoresizingMaskIntoConstraints = false
//        return image
//    }()
//
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
//        label.numberOfLines = 0
//        return label
//    }()
//
//    private let descriptionLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .label
//        label.numberOfLines = 0
//        return label
//    }()
//
//    private let calendarView: FSCalendar = {
//        let calendar = FSCalendar()
//        calendar.translatesAutoresizingMaskIntoConstraints = false
//        return calendar
//    }()
//
//    private let timeSlotsStack: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.spacing = 10
//        return stack
//    }()
//
//    // MARK: - Init
//
//    init(vm: TeacherDetailVM) {
//        self.vm = vm
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = .systemBackground
//
//        setupViews()
//        setupLayout()
//        bindTeacherData()
//
//        calendarView.delegate = self
//
//        // Subscribe to ViewModel updates
//        vm.didTimeSlotsUpdate = { [weak self] in
//            self?.updateSlotsUI()
//        }
//
//        // Trigger the initial fetch
//        vm.loadTimeSlots(for: Date())
//    }
//
//    // MARK: - Setup
//
//    private func setupViews() {
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentStackView)
//
//        contentStackView.addArrangedSubviews(view: [
//            teacherImageView,
//            nameLabel,
//            headlineLabel,
//            descriptionLabel,
//            calendarView,
//            timeSlotsStack
//        ])
//    }
//
//    private func bindTeacherData() {
//        let teacher = vm.teacher
//        title = teacher.name
//
//        if let teacherPhotoUrl = URL(string: teacher.profileImageURL) {
//            teacherImageView.kf.setImage(with: teacherPhotoUrl)
//        }
//
//        headlineLabel.text = teacher.headline
//        nameLabel.text = teacher.name
//        descriptionLabel.text = teacher.fullDescription
//    }
//
//    private func setupLayout() {
//        let padding: CGFloat = 20
//
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalTo(view.safeAreaLayoutGuide)
//        }
//
//        contentStackView.snp.makeConstraints { make in
//            make.edges.equalTo(scrollView.contentLayoutGuide).inset(padding)
//            make.width.equalTo(scrollView.snp.width).offset(-2 * padding)
//        }
//
//        teacherImageView.snp.makeConstraints { make in
//            make.height.equalTo(250)
//        }
//
//        calendarView.snp.makeConstraints { make in
//            make.height.equalTo(300)
//        }
//    }
//
//    // MARK: - Booking UI
//
//    private func updateSlotsUI() {
//        timeSlotsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//        if vm.availableTimeSlots.isEmpty {
//            let noSlotsLabel = UILabel()
//            noSlotsLabel.text = "No available slots for this date."
//            noSlotsLabel.textColor = .secondaryLabel
//            noSlotsLabel.textAlignment = .center
//            timeSlotsStack.addArrangedSubview(noSlotsLabel)
//        } else {
//            for slot in vm.availableTimeSlots {
//
//                // [MRK-21] Using Button
//                let bookButton = UIButton(type: .system)
//
//                let formatter = DateFormatter()
//                formatter.timeStyle = .short
//                let startTime = formatter.string(from: slot.startTime)
//                let endTime = formatter.string(from: slot.endTime)
//
//                bookButton.setTitle("Book \(startTime) - \(endTime) • \(vm.teacher.hourlyRate) UAH", for: .normal)
//                bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//
//                bookButton.backgroundColor = .systemBlue
//                bookButton.setTitleColor(.white, for: .normal)
//                bookButton.layer.cornerRadius = 8
//
//                bookButton.snp.makeConstraints { make in
//                    make.height.equalTo(50)
//                }
//
//                // Action
//                let action = UIAction { [weak self] _ in
//                    self?.handleBookingTap(for: slot)
//                }
//                bookButton.addAction(action, for: .touchUpInside)
//
//                timeSlotsStack.addArrangedSubview(bookButton)
//            }
//        }
//    }
//
//    // MARK: - [MRK-21] Payment & Booking Logic
//
//    private func handleBookingTap(for slot: TimeSlot) {
//        self.selectedSlotToBook = slot
//
//        // 1. Try to initiate Apple Pay
//        let request = PKPaymentRequest()
//        // Use a dummy merchant ID if you don't have a real one.
//        // On simulator, this might sometimes work for UI testing.
//        request.merchantIdentifier = "merchant.com.marko.test"
//        request.supportedNetworks = [.visa, .masterCard, .amex]
//        request.merchantCapabilities = .capability3DS
//        request.countryCode = "UA"
//        request.currencyCode = "UAH"
//
//        let amount = NSDecimalNumber(value: vm.teacher.hourlyRate)
//        let item = PKPaymentSummaryItem(label: "Lesson with \(vm.teacher.name)", amount: amount)
//        request.paymentSummaryItems = [item]
//
//        // 2. Check if we can present the controller
//        // Note: Without a paid account capability, init might fail or return nil
//        if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
//            controller.delegate = self
//            present(controller, animated: true, completion: nil)
//        } else {
//            // 3. FALLBACK: If Apple Pay fails to load (no certs), show a confirmation sheet
//            // This ensures you can still test the DB logic.
//            print("⚠️ Apple Pay not available (Missing Entitlements). Using Fallback Sheet.")
//            presentFallbackPaymentSheet(amount: amount)
//        }
//    }
//
//    // Fallback UI for testing without Paid Account
//    private func presentFallbackPaymentSheet(amount: NSDecimalNumber) {
//        let alert = UIAlertController(
//            title: "Confirm Payment",
//            message: "Apple Pay is not configured. Simulate payment of \(amount) UAH?",
//            preferredStyle: .actionSheet
//        )
//
//        let payAction = UIAlertAction(title: "Pay \(amount) UAH", style: .default) { [weak self] _ in
//            guard let self = self, let slot = self.selectedSlotToBook else { return }
//            self.performDatabaseBooking(for: slot)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        alert.addAction(payAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true)
//    }
//
//    // Actual DB Call
//    private func performDatabaseBooking(for slot: TimeSlot) {
//        vm.bookSlot(slot) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self?.showAlert(title: "Success! 🎉", message: "Lesson booked successfully.")
//                case .failure(let error):
//                    self?.showAlert(title: "Booking Failed", message: error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//
//
//// MARK: - FSCalendar Delegate
//extension TeacherDetailVC: FSCalendarDelegate {
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        vm.loadTimeSlots(for: date)
//    }
//}
//
//
//
//// MARK: - [MRK-21] Apple Pay Delegate
//extension TeacherDetailVC: PKPaymentAuthorizationViewControllerDelegate {
//
//    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
//
//        // User tapped "Pay" with TouchID/FaceID in Simulator
//        // We simulate success
//        handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
//    }
//
//    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
//
//        // Sheet dismissed
//        controller.dismiss(animated: true) { [weak self] in
//            // Trigger the DB write
//            guard let self = self, let slot = self.selectedSlotToBook else { return }
//            self.performDatabaseBooking(for: slot)
//        }
//    }
//}
//
//
//
//
