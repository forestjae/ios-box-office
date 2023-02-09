//
//  DateSelectionViewController.swift
//  BoxOffice
//
//  Created by kakao on 2023/02/09.
//

import UIKit

fileprivate extension Date {
    static var yesterDay: Date {
        return Date() - 3600 * 24
    }
}

protocol DateSelectionDelegate: AnyObject {
    func dateSelection(_ date: Date)
}

class DateSelectionViewController: UIViewController {
    weak var dateSelectionDelegate: DateSelectionDelegate?
    
    private let selectedDate: Date
    
    private let calendarView: UICalendarView = {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        return calendarView
    }()
    
    init(date: Date) {
        self.selectedDate = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureHierarchy()
        self.configureConstraint()
        self.configureCalendarView()
    }
    
    private func configureHierarchy() {
        self.view.addSubview(self.calendarView)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            self.calendarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.calendarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.calendarView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.calendarView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureCalendarView() {
        self.calendarView.availableDateRange = DateInterval(start: .distantPast, end: .yesterDay)
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        dateSelection.selectedDate = Calendar.current.dateComponents(in: .current, from: self.selectedDate)
        self.calendarView.selectionBehavior = dateSelection
    }
}

extension DateSelectionViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(
        _ selection: UICalendarSelectionSingleDate,
        didSelectDate dateComponents: DateComponents?
    ) {
        guard let date = dateComponents?.date else { return }
        self.dateSelectionDelegate?.dateSelection(date)
        self.dismiss(animated: true)
    }
}
