//
//  CalculateDay.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/20.
//

import Foundation

let BOADSPACES = 20

enum BoardState{
    case setup
    case traveling(sheets:Int,spaces:Int)
    case complete
    
}

enum RecordType{
    enum RateDay{
        case good
        case normal
        case bad
    }
}

func daypassed(startDate:Date,todayDate:Date,calender:Calendar)-> Int{
    let startDay = calender.startOfDay(for: startDate)
    let todayDay = calender.startOfDay(for: todayDate)
    
    let days = calender.dateComponents(
        [.day],
        from:startDay,
        to:todayDay
    ).day ?? -1
    
    return days
}

func boardPosition(totalDays:Int, passedDays:Int)-> BoardState{
    if(passedDays < 0){
        return .setup
    }
    else{
        if((totalDays-passedDays)<0){
            return .complete
        }
        else{
            let seets = passedDays / BOADSPACES
            let spaces = passedDays % BOADSPACES
            
            return .traveling(sheets: seets, spaces: spaces)
        }
    }
    
}
