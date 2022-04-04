//
//  Logger.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 4/04/22.
//

import Foundation

enum LogEvent: String {
    case error = "[❌ERROR]"
    case info = "[ℹ️INFO]"
    case warning = "[⚠️WARNING]"
    case api = "[📡API]"
}

func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

class Log {
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Logging methods
    /// - Parameters:
    ///   - type: Event type to be logged
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func event(type: LogEvent, _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        
        if isLoggingEnabled {
            var eventPrefix = ""
            switch type {
                case .error:
                    eventPrefix = LogEvent.error.rawValue
                case .info:
                    eventPrefix = LogEvent.info.rawValue
                case .warning:
                    eventPrefix = LogEvent.warning.rawValue
                case .api:
                    eventPrefix = LogEvent.api.rawValue
            }
            print("\(Date().toString()) \(eventPrefix)[\(sourceFileName(filePath: filename))]: line:\(line) column:\(column) \(funcName) -> \(object)\n")
        }
        
    }
    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
