//
//  BoardPosition.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/20.
//

import Foundation

let BOARDSPACES = 20

enum BoardState: Equatable{
    case setup
    case traveling(sheets:Int,spaces:Int)
    case complete
}

enum RateOfDay:Int{
    case good=2
    case normal=1
    case bad=0
}

enum CreateJourneyError:Error{
    case invalidDays
    case alreadyEnded
}
enum calendarError:Error{
    case invalidDate
}

func createUtcCalendar()-> Calendar{
    var calendar = Calendar(identifier: .gregorian)
    if let timezone = TimeZone(identifier: "UTC"){
        calendar.timeZone = timezone
    }
    
    return calendar
}

struct YearMonthDay:Comparable,Hashable,Codable{
    let year:Int
    let month:Int
    let day:Int
    
    init(date:Date,timeZone:TimeZone){
        
        var inputCalendar = Calendar(identifier: .gregorian)
        inputCalendar.timeZone = timeZone

        self.year = inputCalendar.component(.year, from: date)
        self.month = inputCalendar.component(.month, from: date)
        self.day = inputCalendar.component(.day, from: date)
    }
    
    static func < (lhs:YearMonthDay, rhs:YearMonthDay)->Bool{
        if lhs.year != rhs.year{
            return lhs.year < rhs.year
        }
        if lhs.month != rhs.month{
            return lhs.month < rhs.month
        }
        return lhs.day < rhs.day
    }
}



struct JourneyPlan{
    let startYMD:YearMonthDay
    let periodDays:Int
    
    init(startYMD:YearMonthDay, periodDays:Int, todayYMD:YearMonthDay) throws {
        
        if !(1...100).contains(periodDays){
            throw CreateJourneyError.invalidDays
        }
        let passedDays = try dayPassed(startYMD: startYMD, todayYMD: todayYMD)
        
        let state = boardPosition(periodDays: periodDays, passedDays: passedDays)
        if state == .complete{
            throw CreateJourneyError.alreadyEnded
        }
        
        self.startYMD = startYMD
        self.periodDays = periodDays
        
    }
}

struct Record{
    let dateYMD:YearMonthDay
    let rateOfDay:RateOfDay
    
    init(dateYMD:YearMonthDay,rateOfDay:RateOfDay){
        self.dateYMD = dateYMD
        self.rateOfDay = rateOfDay
    }
}

func dayPassed(startYMD:YearMonthDay,todayYMD:YearMonthDay)throws-> Int{
    let utcCalendar = createUtcCalendar()
    
    let startComponents = DateComponents(year: startYMD.year,month: startYMD.month, day: startYMD.day)
    let todayComponents = DateComponents(year: todayYMD.year,month: todayYMD.month, day: todayYMD.day)
    
    guard let startDate = (utcCalendar.date(from: startComponents)) else{throw calendarError.invalidDate}
    guard let todayDate = (utcCalendar.date(from: todayComponents)) else{throw calendarError.invalidDate}
    
    guard let days = (utcCalendar.dateComponents(
        [.day],
        from:startDate,
        to:todayDate
    ).day) else{throw calendarError.invalidDate}
    
    return days
}

func boardPosition(periodDays:Int, passedDays:Int)-> BoardState{
    if(passedDays < 0){
        return .setup
    }
    else{
        if(passedDays  >= periodDays){
            return .complete
        }
        else{
            let sheets = passedDays / BOARDSPACES
            let spaces = passedDays % BOARDSPACES
            
            return .traveling(sheets: sheets, spaces: spaces)
        }
    }
    
}
