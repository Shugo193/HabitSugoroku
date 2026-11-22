//
//  HabitSugorokuTests.swift
//  HabitSugorokuTests
//
//  Created by asaishugo on 2026/11/16.
//

import Testing
import Foundation
@testable import HabitSugoroku

let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!

func createCalendar(timeZone:TimeZone)-> Calendar{
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    
    return calendar
}


func createYMD(year:Int, month:Int, day:Int,timeZone:TimeZone)throws->YearMonthDay{
   let calendar = createCalendar(timeZone: timeZone)
    
    let dateComponents = DateComponents(year: year,month: month, day: day)
    let date = try #require(calendar.date(from: dateComponents))
    let YMD = YearMonthDay(date: date, timeZone: timeZone)
    
    return YMD
    
}
struct HabitSugorokuTests {
    
    
    
    struct DayPassedTests{
        
        @Test("前日23:00->今日00:01の経過日数は１日")
        func dayPassedAcrossMidnight() throws{
            let calendar = createCalendar(timeZone: tokyoTimeZone)
            let startComponents = DateComponents(
                year: 2026,month: 11, day: 20, hour:23, minute: 00, second:0
            )
            
            let todayComponents = DateComponents(
                year: 2026,month: 11, day: 21, hour:0, minute: 01, second:0
            )
            
            let startDate = try #require(calendar.date(from: startComponents))
            let todayDate = try #require(calendar.date(from: todayComponents))
            
            let startYMD = YearMonthDay(date: startDate, timeZone: tokyoTimeZone)
            
            let todayYMD = YearMonthDay(date: todayDate, timeZone: tokyoTimeZone)
            
            
            
            let passedDays = try dayPassed(startYMD: startYMD, todayYMD: todayYMD)
            
            #expect(passedDays == 1)
        }
        
        struct TestCase{
            let startDate:(year:Int,month:Int,day:Int)
            let todayDate:(year:Int,month:Int,day:Int)
            let expected:Int
        }
        @Test("境目の日数テスト",arguments: [
            TestCase(startDate: (year:2026,month :10, day:31), todayDate: (year:2026,month:11,day:1), expected: 1),
            TestCase(startDate: (year:2026,month:12,day:31), todayDate: (year:2027,month:1,day:1), expected: 1),
            TestCase(startDate: (year:2028,month:2,day:28), todayDate: (year:2028,month:3,day:1), expected: 2)
        ])
        func borderDays(testCase :TestCase)throws{
            let startDate = testCase.startDate
            let todayDate = testCase.todayDate
            let startYMD = try(createYMD(year: startDate.year, month: startDate.month, day: startDate.day, timeZone: tokyoTimeZone))
            let todayYMD = try(createYMD(year: todayDate.year, month: todayDate.month, day: todayDate.day, timeZone: tokyoTimeZone))
            let expected = testCase.expected
            
            let passedDays = try(dayPassed(startYMD: startYMD, todayYMD: todayYMD))
            
            #expect(passedDays == expected)
        }
    }
    struct BoardPositionTests{
        struct TestCase{
            let totalDays:Int
            let passedDays:Int
            let expected: BoardState
            
        }
        @Test("旅の日数と、経過日数から盤の位置を計算",arguments: [
            TestCase(totalDays: 20, passedDays: 19, expected: .traveling(sheets: 0, spaces: 19)),
            TestCase(totalDays: 20, passedDays: 20, expected: .complete),
            TestCase(totalDays: 1, passedDays: 0, expected: .traveling(sheets: 0, spaces: 0)),
            TestCase(totalDays: 30, passedDays: 29, expected: .traveling(sheets: 1, spaces: 9)),
            TestCase(totalDays: 100, passedDays: 99, expected: .traveling(sheets: 4, spaces: 19)),
            TestCase(totalDays: 20, passedDays: -1, expected: .setup)
        ])
        func calulateBoardPositionAndState(testCase:TestCase){
            let totalDays = testCase.totalDays
            let passedDays = testCase.passedDays
            let expected = testCase.expected
            
            #expect(boardPosition(periodDays: totalDays, passedDays: passedDays)==expected)
        }
    }
    
    struct JourneyPlanTests{
        @Test("旅の日数は1-100日の間でそれ以外はエラーが返る")
        func initInvalidDaysThrows()throws{

            let todayYMD = try (createYMD(year: 2026, month: 11, day: 21, timeZone: tokyoTimeZone))
            
            #expect(throws: CreateJourneyError.invalidDays){
                try JourneyPlan(startYMD: todayYMD, periodDays: 0, todayYMD: todayYMD)
            }
            #expect(throws: Never.self){
                try JourneyPlan(startYMD: todayYMD, periodDays: 1,todayYMD: todayYMD)
            }
            #expect(throws: Never.self){
                try JourneyPlan(startYMD: todayYMD, periodDays: 100, todayYMD: todayYMD)
            }
            #expect(throws: CreateJourneyError.invalidDays){
                try JourneyPlan(startYMD: todayYMD, periodDays: 101, todayYMD: todayYMD)
            }
        }
        
        @Test("旅は終了日が昨日よりあとの場合のみ作ることができそれ以外はエラーが返る")
        func initAlreadyEndedThrows()throws{
            let calendar = createCalendar(timeZone: tokyoTimeZone)
            
            let todayComponents = DateComponents(
                year: 2026,month: 11, day: 21, hour:0, minute: 01, second:0
            )
            let pastComponents = DateComponents(year: 2026,month: 11, day: 18, hour:0, minute: 01, second:0)
            let tomorrowComponents = DateComponents(year: 2026,month: 11, day: 22, hour:0, minute: 01, second:0)
            
            let todayDate = try #require(calendar.date(from: todayComponents))
            let pastDate = try #require(calendar.date(from: pastComponents))
            let tomorrowDate = try #require(calendar.date(from: tomorrowComponents))
                    
            
            let todayYMD = YearMonthDay(date: todayDate, timeZone: tokyoTimeZone)
            let pastYMD = YearMonthDay(date: pastDate, timeZone: tokyoTimeZone)
            let tomorrowYMD = YearMonthDay(date: tomorrowDate, timeZone: tokyoTimeZone)
            
            #expect(throws: CreateJourneyError.alreadyEnded){
                try JourneyPlan(startYMD: pastYMD, periodDays: 3,todayYMD: todayYMD)
            }
            #expect(throws: Never.self){
                try JourneyPlan(startYMD: pastYMD, periodDays: 4, todayYMD: todayYMD)
            }
            #expect(throws: Never.self){
                try JourneyPlan(startYMD: tomorrowYMD, periodDays: 20, todayYMD: todayYMD)
            }
        }
    }
    
    struct RecordTests{
        @Test("同じ日の違う時間につくったRecordでも日付が一致する。")
        func sameDayRecord() throws {
            let calendar = createCalendar(timeZone: tokyoTimeZone)
            
            let morningComponents = DateComponents(
                year: 2026,month: 11, day: 21, hour:9, minute: 01, second:0
            )
            let eveningComponents = DateComponents(year: 2026,month: 11, day: 21, hour:21, minute: 01, second:0)
            
            let morningDate = try #require(calendar.date(from: morningComponents))
            let eveningDate = try #require(calendar.date(from: eveningComponents))
            
            let morningYMD = YearMonthDay(date: morningDate, timeZone: tokyoTimeZone)
            
            let eveningYMD = YearMonthDay(date: eveningDate, timeZone: tokyoTimeZone)
            
            let morningRecord = Record(dateYMD: morningYMD, rateOfDay: .good)
            let eveningRecord = Record(dateYMD: eveningYMD, rateOfDay: .good)
            
            #expect(morningRecord.dateYMD == eveningRecord.dateYMD)
        }
        
        @Test("違う日につくったRecordは日付が一致しない。")
        func diffDaysRecord() throws {
            let calendar = createCalendar(timeZone: tokyoTimeZone)
            
            let todayComponents = DateComponents(
                year: 2026,month: 11, day: 20, hour:0, minute: 01, second:0
            )
            let yesterdayComponents = DateComponents(year: 2026,month: 11, day: 19, hour:23, minute: 59, second:0)
            
            let todayDate = try #require(calendar.date(from: todayComponents))
            let yesterdayDate = try #require(calendar.date(from: yesterdayComponents))
            
            let todayYMD = YearMonthDay(date: todayDate, timeZone: tokyoTimeZone)
            let yesterdayYMD = YearMonthDay(date: yesterdayDate, timeZone: tokyoTimeZone)
            let morningRecord = Record(dateYMD: todayYMD, rateOfDay: .bad)
            let eveningRecord = Record(dateYMD: yesterdayYMD, rateOfDay: .bad)

            #expect(morningRecord.dateYMD != eveningRecord.dateYMD)
        }
    }
    
    struct YearMonthDayTest{
        
        @Test("同じ瞬間が、東京では11/22ニューヨークでは11/21になる")
        func diffPlaceDiffDate() throws{
            let calendar = createCalendar(timeZone: tokyoTimeZone)
            
            let newyorkTimeZone = try #require(TimeZone(identifier: "America/New_York"))
            
            let todayComponents = DateComponents(
                year: 2026,month: 11, day: 22, hour:0, minute: 01, second:0
            )
            
            let todayDate = try #require(calendar.date(from: todayComponents))
            
            let tokyoYMD = YearMonthDay(date: todayDate, timeZone: tokyoTimeZone)
            let newyorkYMD = YearMonthDay(date: todayDate, timeZone: newyorkTimeZone)
            
            #expect(tokyoYMD.year == 2026)
            #expect(tokyoYMD.month == 11)
            #expect(tokyoYMD.day == 22)
            
            #expect(newyorkYMD.year == 2026)
            #expect(newyorkYMD.month == 11)
            #expect(newyorkYMD.day == 21)
            
        
        }
    }
}
