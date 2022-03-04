//
//  ContentView.swift
//  WeeklyCalendarClone
//
//  Created by Kyungyun Lee on 04/03/2022.
//

import SwiftUI

struct ContentView: View {
    
    private let calendar : Calendar
    private let monthDayFormatter : DateFormatter
    private let dayFormatter : DateFormatter
    private let weekDayFormatter : DateFormatter
    
    private static var now = Date()
    @State var selectedDate = Self.now
    
    public init(calendar : Calendar) {
        self.calendar = calendar
        self.monthDayFormatter = DateFormatter(dateFormat: "MM/dd", calendar : calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar : calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar : calendar)
    }
    
    var body: some View {
        VStack {
            WeeklyCalenderView(
                calendar: calendar,
                date: $selectedDate,
                content: {date in
                    Button(action: {
                        selectedDate = date
                    }, label: {
                        Text("00")
                            .font(.headline)
                            .foregroundColor(.clear)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(
                                        calendar.isDate(date, inSameDayAs: selectedDate) ?
                                        Color.black : calendar.isDateInToday(date) ? .green : .gray
                                    
                                    )
                            )
                    })
                },
                header: {date in
                    Text(weekDayFormatter.string(from: date))
                        .font(.headline)
                },
                title: {date in
                    HStack {
                        Text(monthDayFormatter.string(from: selectedDate))
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                    .padding()
                },
                switcher: {date in
                    Button(action: {
                        withAnimation {
                            guard let newDate = calendar.date(byAdding: .weekOfMonth, value: -1,  to: selectedDate)
                            else {
                                return
                            }
                            selectedDate = newDate
                        }
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    
                    Button(action: {
                        withAnimation {
                            guard let newDate = calendar.date(byAdding: .weekOfMonth, value: 1,  to: selectedDate)
                            else {
                                return
                            }
                            selectedDate = newDate
                        }
                    }, label: {
                        Image(systemName: "chevron.right")
                    })
                })
        }
    }
}

struct WeeklyCalenderView<Day: View, Header: View, Title: View, Switcher: View>: View {
    
    private var calendar : Calendar
    @Binding private var date : Date
    private let content : (Date) -> Day
    private let header : (Date) -> Header
    private let title : (Date) -> Title
    private let switcher : (Date) -> Switcher
    
    private let daysInweek = 7
    
    public init(
        calendar: Calendar,
        date : Binding<Date>,
        @ViewBuilder content : @escaping (Date) -> Day,
        @ViewBuilder header : @escaping (Date) -> Header,
        @ViewBuilder title : @escaping (Date)-> Title,
        @ViewBuilder switcher : @escaping (Date) -> Switcher
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.header = header
        self.title = title
        self.switcher = switcher
    }
    
    var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        
        VStack{
            HStack {
                title(month)
                switcher(month)
            }
            HStack{
                ForEach(days.prefix(daysInweek), id: \.self, content: header)
            }
            HStack {
                ForEach(days, id: \.self) {date in
                    content(date)
                }
            }
        }
    }
}

private extension WeeklyCalenderView {
    func makeDays() -> [Date] {
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: date),
                let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else {
            return[]
        }
        let dateInterval = DateInterval(start: firstWeek.start, end: firstWeek.end)
        
        return calendar.generateDays(for: dateInterval)
    }
}

private extension DateFormatter {
    convenience init(dateFormat : String, calendar : Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "en-US")
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }
}

private extension Calendar {
    
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else {return}
            guard date < dateInterval.end else {
                stop = true
                return
            }
            dates.append(date)
        }
        return dates
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(for: dateInterval , matching: dateComponents([.hour, .minute, .second], from: dateInterval.start))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(calendar: Calendar(identifier: .gregorian))
    }
}
