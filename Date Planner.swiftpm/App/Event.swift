/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct Event: Identifiable, Hashable {
    var id = UUID()
    var symbol: String = EventSymbols.randomName()
    var color: Color = ColorOptions.random()
    var title = ""
    var tasks = [EventTask(text: "")]
    var date = Date()

    /// 获取未完成任务的数量 - 计算属性
    var remainingTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var isComplete: Bool {
        tasks.allSatisfy { $0.isCompleted }
    }
    
    /// 判断事件是否已过期
    var isPast: Bool {
        date < Date.now
    }
    
    /// 判断事件是否在未来7天内
    var isWithinSevenDays: Bool {
        !isPast && date < Date.now.sevenDaysOut
    }
    
    /// 判断事件是否在7-30天内
    var isWithinSevenToThirtyDays: Bool {
        !isPast && !isWithinSevenDays && date < Date.now.thirtyDaysOut
    }
    
    /// 判断事件是否在30天以后
    var isDistant: Bool {
        date >= Date().thirtyDaysOut
    }

    static var example = Event(
        symbol: "case.fill",
        title: "Sayulita Trip",
        tasks: [
            EventTask(text: "Buy plane tickets"),
            EventTask(text: "Get a new bathing suit"),
            EventTask(text: "Find an airbnb"),
        ],
        date: Date(timeIntervalSinceNow: 60 * 60 * 24 * 365 * 1.5))
}

extension Date {
    /// 获取7天后的日期
    var sevenDaysOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 7, to: self) ?? self
    }
    
    /// 获取30天后的日期
    var thirtyDaysOut: Date {
        // Calendar.autoupdatingCurrent 获取一个会自动根据用户系统设置更新的日历实例, 这比使用固定日历更灵活，能适应不同地区和时区的用户
        // .date(byAdding:value:to:) 这是 Calendar 的一个方法，用于日期计算 
        // byAdding: .day 指定要添加的时间单位是"天" 
        //value: 30 表示要添加30个单位（这里是30天）
        // to: self 表示基于当前日期进行计算
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 30, to: self) ?? self
    }
}
