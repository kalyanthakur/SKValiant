//
//  CalendarListView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import SwiftUI
import SwiftUICalendar

struct CalendarListView: View {
    
    @StateObject var viewModel = EventViewModel()
    @ObservedObject var controller: CalendarController = CalendarController()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: YearMonthDay?
    @State private var selectedEventId = 0
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false

    
    // Check if events are for future date (not selected date)
    private var isShowingFutureDateEvents: Bool {
        guard let selectedDate = selectedDate else { return false }
        
        let calendar = Calendar.current
        guard let _ = calendar.date(from: DateComponents(year: selectedDate.year, month: selectedDate.month, day: selectedDate.day)) else {
            return false
        }
        
        // Check if selected date has events
        let eventsForSelectedDate = viewModel.arrSpogEvents.filter { event in
            if let eventDate = appSharedData.getDateFormatter(format: "yyyy-MM-dd").date(from: event.date) {
                let eventYear = calendar.component(.year, from: eventDate)
                let eventMonth = calendar.component(.month, from: eventDate)
                let eventDay = calendar.component(.day, from: eventDate)
                return eventYear == selectedDate.year && eventMonth == selectedDate.month && eventDay == selectedDate.day
            }
            return false
        }
        
        // If selected date has events, we're not showing future date events
        return eventsForSelectedDate.isEmpty
    }
    
    // Filter events for the selected date, or next future date if selected date has no events
    private var filteredEventsForDate: [SpogEvent] {
        guard let selectedDate = selectedDate else { return [] }
        
        // Convert selected date to Date for comparison
        let calendar = Calendar.current
        guard let selectedDateAsDate = calendar.date(from: DateComponents(year: selectedDate.year, month: selectedDate.month, day: selectedDate.day)) else {
            return []
        }
        
        // First, check if selected date has events
        let eventsForSelectedDate = viewModel.arrSpogEvents.filter { event in
            if let eventDate = appSharedData.getDateFormatter(format: "yyyy-MM-dd").date(from: event.date) {
                let eventYear = calendar.component(.year, from: eventDate)
                let eventMonth = calendar.component(.month, from: eventDate)
                let eventDay = calendar.component(.day, from: eventDate)
                return eventYear == selectedDate.year && eventMonth == selectedDate.month && eventDay == selectedDate.day
            }
            return false
        }
        
        // If selected date has events, return them
        if !eventsForSelectedDate.isEmpty {
            return eventsForSelectedDate
        }
        
        // Otherwise, find the next future date with events
        let futureEvents = viewModel.arrSpogEvents.compactMap { event -> (event: SpogEvent, date: Date)? in
            guard let eventDate = appSharedData.getDateFormatter(format: "yyyy-MM-dd").date(from: event.date),
                  eventDate > selectedDateAsDate else {
                return nil
            }
            return (event, eventDate)
        }
        
        // Sort by date and find the earliest future date
        let sortedFutureEvents = futureEvents.sorted { $0.date < $1.date }
        
        guard let earliestFutureDate = sortedFutureEvents.first?.date else {
            return []
        }
        
        // Return all events for the earliest future date
        return sortedFutureEvents
            .filter { calendar.isDate($0.date, inSameDayAs: earliestFutureDate) }
            .map { $0.event }
    }

    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {

                // Events list for the selected month
                ScrollView {
                                
                HStack(spacing: 10) {
                    let monthName = appSharedData.convertDateFormatFromForDate(fromFormat: "MMM", toFormat: "MMMM", stringDate: controller.yearMonth.monthShortString)
                    Text(monthName)
                        .font(.custom("HelveticaNeue-Bold", size: 18.0))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(String(controller.yearMonth.year))
                        .font(.custom("HelveticaNeue-Regular", size: 18.0))
                        .foregroundColor(Color("textColor"))
                        .multilineTextAlignment(.leading)
                    Spacer()
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(0..<7, id: \.self) { i in
                            Text(DateFormatter().shortWeekdaySymbols[(i + 1) % 7])
                                .font(.custom("HelveticaNeue-Regular", size: 12))
                                .foregroundColor(Color(white: 112.0 / 255.0))
                                .frame(maxWidth: .infinity)
                                .textCase(.uppercase)
                        }
                    }
                    .frame(height: 30)
                    
                    CalendarView(controller,startWithMonday: true, component: { date in
                        if date.isFocusYearMonth == true {
                            GeometryReader { geometry in
                                ZStack(alignment: .topLeading) {
                                    // Border
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(((selectedDate?.year == date.year && selectedDate?.month == date.month && selectedDate?.day == date.day) || date.isToday) ? Color.blue : Color(white: 200.0 / 255.0), lineWidth: selectedDate?.year == date.year && selectedDate?.month == date.month && selectedDate?.day == date.day ? 2.0 : 1.0)
                                    
                                    // Date number - always visible, positioned absolutely
                                    Text("\(date.day)")
                                        .font(.system(size: max(10, min(14, geometry.size.width * 0.25)), weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .padding(.horizontal, max(1, geometry.size.width * 0.05))
                                        .padding(.top, max(1, geometry.size.height * 0.05))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    
                                    // Event indicator - only if event exists and there's space
                                    if geometry.size.height > 30, let event = viewModel.arrSpogEvents.first(where: { event in
                                        if let eventDate = appSharedData.getDateFormatter(format: "yyyy-MM-dd").date(from: event.date) {
                                            let calendar = Calendar.current
                                            let eventYear = calendar.component(.year, from: eventDate)
                                            let eventMonth = calendar.component(.month, from: eventDate)
                                            let eventDay = calendar.component(.day, from: eventDate)
                                            return eventYear == date.year && eventMonth == date.month && eventDay == date.day
                                        }
                                        return false
                                    }) {
                                        VStack {
                                            Spacer()
                                            HStack(spacing: 1) {
                                                Rectangle()
                                                    .fill(Color.blue)
                                                    .frame(width: 1.5)
                                                
                                                Text(event.title)
                                                    .font(.system(size: max(4, min(6, geometry.size.width * 0.12)), weight: .light, design: .default))
                                                    .foregroundColor(.black)
                                                    .minimumScaleFactor(0.3)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 1)
                                            .padding(.bottom, 1)
                                        }
                                    }
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedDate = date
                                }
                            }
                        } else {
                            EmptyView()
                        }
                    })
                    .padding(4)
                    .frame(height: max(140, (max(0, geometry.size.width - 8)) / 7 * 6)) // Increased minimum height for better visibility
                    
                    HStack {
                        Text("Event News")
                            .font(.custom("Roboto-Medium", size: 18.0))
                            .foregroundColor(Color(red: 19.0 / 255.0, green: 59.0 / 255.0, blue: 58.0 / 255.0))
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)

                        Spacer()
                        
                        Button(action: {
                            viewModel.showEventView.toggle()
                        }) {
                            Text("See all event news")
                                .font(.custom("Roboto-Medium", size: 12.0))
                                .foregroundColor(Color(hex:"#223a76"))
                                .multilineTextAlignment(.leading)
                                .underline()
                                .textCase(.uppercase)
                    }
                        .padding(.vertical, 8)
                        .padding(.trailing, 8)
                    }
                    .background(Color(white: 248.0 / 255.0))
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
                
                    if filteredEventsForDate.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image("no_data")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if isShowingFutureDateEvents {
                        if let event  = filteredEventsForDate.first {
                            EventListItemCard(event: event, screenWidth: geometry.size.width - 44, showDetails: !isShowingFutureDateEvents, viewModel: viewModel)
                            
                        }
                    } else {
                        let columns = [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredEventsForDate) { event in
                                EventListItemCard(event: event, screenWidth: (geometry.size.width - 44) / 2, showDetails: !isShowingFutureDateEvents, viewModel: viewModel)
                                    .onTapGesture {
                                        self.selectedEventId = event.id
                                        self.viewModel.showEventDetailView.toggle()
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
                }
                
                // Floating Menu Button
                FloatingMenuActionButton(
                    isSelected: $isMenuSelected,
                    floatingMenuItems: generateFloatingMenuItems()
                )
                .padding(.trailing, 8)
                .padding(.bottom, 30)
            }
            .task {
                await Task { @MainActor in
                    viewModel.getSpogEvents()
                }.value
            }
            .background(.white)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("SPOG_logo_2")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                        Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                    startPoint: .bottom,
                    endPoint: .center),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $viewModel.showEventView) {
                if viewModel.showEventView {
                    EventListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showEventDetailView) {
                if viewModel.showEventDetailView {
                    EventDetailView(eventId: self.selectedEventId)
                }
            }
            .navigationDestination(isPresented: $showDashboardView) {
                if showDashboardView {
                    DashBoardView()
                }
            }
            .navigationDestination(isPresented: $showAlertListView) {
                if showAlertListView {
                    AlertListView()
                }
            }
            .navigationDestination(isPresented: $showEventListView) {
                if showEventListView {
                    EventListView()
                }
            }
            .navigationDestination(isPresented: $showMessageView) {
                if showMessageView {
                    PresidentMessageListView()
                }
            }
            .navigationDestination(isPresented: $showAdditionalInfoView) {
                if showAdditionalInfoView {
                    AdditionalInfoView()
                }
            }
            .navigationDestination(isPresented: $showRequestGuidRepView) {
                if showRequestGuidRepView {
                    RequestGuidRep(onCompleteDismiss: {
                        showRequestGuidRepView = false
                    })
                }
            }
            .navigationDestination(isPresented: $showProfileView) {
                if showProfileView {
                    ProfileView()
                }
            }
        }
    }
    
    // MARK: - Floating Menu Items
    private func generateFloatingMenuItems() -> [FloatingMenuItem] {
        return [
            .init(iconName: "ic_home", buttonAction: {
                showDashboardView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_bell", buttonAction: {
                showAlertListView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_calendar", buttonAction: {
                showEventListView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_president_message", buttonAction: {
                showMessageView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_contact_shortcut", buttonAction: {
                showRequestGuidRepView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_more", buttonAction: {
                showAdditionalInfoView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_user", buttonAction: {
                showProfileView = true
                isMenuSelected = false
            }),
        ]
    }
}

// MARK: - Event List Item Card
struct EventListItemCard: View {
    let event: SpogEvent
    let screenWidth: CGFloat
    let showDetails: Bool
    @ObservedObject var viewModel: EventViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Event Image
            if let imagePath = event.image, !imagePath.isEmpty {
                let imageURL = appSharedData.constructImageURL(from: imagePath)
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: screenWidth - 44)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth - 44, height: screenWidth - 44)
                            .clipped()
                            .cornerRadius(4)
                    case .failure:
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenWidth - 44)
                    @unknown default:
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenWidth - 44)
                    }
                }
            } else {
                Image("SPOG_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenWidth - 44)
            }
            
            // Event details - only show if showDetails is true
            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, yyyy ", stringDate: event.date)
            let eventTime = appSharedData.convertDateFormatFromForDate(fromFormat: "HH:MM:SS", toFormat: "hh:mm a", stringDate: event.time)
            if showDetails {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.custom("Roboto-Medium", size: 16.0))
                            .foregroundColor(Color(hex:"#133b3a"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text("\(eventDate) at \(eventTime)")
                            .font(.custom("Roboto-Regular", size: 12.0))
                            .foregroundColor(Color(red: 105.0 / 255.0, green: 163.0 / 255.0, blue: 162.0 / 255.0))
                    }
                    
                Button(action: {
                    let newBookmarkStatus = event.isBookmark ? 0 : 1
                    viewModel.bookmarkPost(itemType: "event", itemId: event.id, isBookmark: newBookmarkStatus)
                }) {
                        Image(systemName: event.isBookmark ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
                }
            } else {
                
                Text("Next future event found \(eventDate) at \(eventTime)")
                    .font(.custom("Roboto-Regular", size: 12.0))
                    .foregroundColor(Color(hex:"#262626"))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

