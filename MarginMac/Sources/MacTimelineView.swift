import SwiftUI

struct MacTimelineView: View {
    let moments: [Moment]
    let onSelect: (Moment) -> Void

    @State private var selectedDate: Date = Date()

    private var calendar: Calendar { Calendar.current }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))
        else { return [] }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    private var momentsByDate: [Date: [Moment]] {
        Dictionary(grouping: moments) { moment in
            calendar.startOfDay(for: moment.timestamp)
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private var firstWeekday: Int {
        guard let first = daysInMonth.first else { return 1 }
        return calendar.component(.weekday, from: first)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                        .foregroundColor(MarginColors.accent)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(monthYearString)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)

                Spacer()

                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(MarginColors.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(MarginColors.surface)

            Divider()
                .background(MarginColors.divider)

            // Calendar grid
            VStack(spacing: 12) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)

                // Calendar days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                    // Padding for first week
                    ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                        Color.clear
                            .frame(height: 44)
                    }

                    // Days
                    ForEach(daysInMonth, id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            momentCount: momentsByDate[calendar.startOfDay(for: date)]?.count ?? 0,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            selectedDate = date
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 16)

            Divider()
                .background(MarginColors.divider)

            // Selected day reflections
            VStack(alignment: .leading, spacing: 8) {
                Text(formattedSelectedDate)
                    .font(MarginFonts.subheading)
                    .foregroundColor(MarginColors.primaryText)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                let dayMoments = momentsByDate[calendar.startOfDay(for: selectedDate)] ?? []
                if dayMoments.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 24))
                            .foregroundColor(MarginColors.divider)
                        Text("No moments on this day")
                            .font(MarginFonts.caption)
                            .foregroundColor(MarginColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(dayMoments) { moment in
                                Button(action: { onSelect(moment) }) {
                                    HStack(alignment: .top, spacing: 12) {
                                        Text(moment.formattedTime)
                                            .font(MarginFonts.caption)
                                            .foregroundColor(MarginColors.accent)
                                            .frame(width: 60, alignment: .leading)

                                        Text(moment.text)
                                            .font(MarginFonts.body)
                                            .foregroundColor(MarginColors.primaryText)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)

                                        Spacer()

                                        if let tag = moment.moodTag {
                                            Text(tag.emoji)
                                                .font(.system(size: 12))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(MarginColors.surface)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MarginColors.background)
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    private func changeMonth(_ delta: Int) {
        if let new = calendar.date(byAdding: .month, value: delta, to: selectedDate) {
            selectedDate = new
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let momentCount: Int
    let isSelected: Bool
    let action: () -> Void

    private var calendar: Calendar { Calendar.current }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(MarginFonts.body)
                    .foregroundColor(isSelected ? MarginColors.surface : MarginColors.primaryText)

                // Dots for moments
                HStack(spacing: 2) {
                    if momentCount > 0 {
                        ForEach(0..<min(momentCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? MarginColors.surface : MarginColors.accent)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 36, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? MarginColors.accent : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MacTimelineView(moments: [], onSelect: { _ in })
}
