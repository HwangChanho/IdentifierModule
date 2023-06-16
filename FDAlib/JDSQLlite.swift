//
//  JDFDSQL.swift
//  FDAlib
//
//  Created by jiran_daniel on 2023/06/13.
//

import Foundation
import SQLite3

enum DML: String {
    case insert = "INSERT INTO"
    case delete = "DELETE FROM"
    case update = "UPDATE"
    case select = "SELECT"
} // DDL, DCL, DQL, TCL etc

enum SQLError: Error {
    case connectionError
    case queryError
    case bindingError
    case typeMissMatchingError
    case statementError
    case otherError
}

enum ColumnType {
    case int
    case double
    case text
}

protocol JDFDSQLiteBuilder {
    func prepare(with query: String) throws -> JDFDSQLiteExecuteBuilder
}

protocol JDFDSQLiteQueryBuilder {
    func setDMLtype(type: DML) -> JDFDSQLiteQueryBuilder
    
    func setLookUpData(columnNameString: String) throws -> JDFDSQLiteQueryBuilder
    func setSelectTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder
    func setUpdateTable(tableNameString: String, setValues: String) throws -> JDFDSQLiteQueryBuilder
    func setInsertTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder
    func setDeleteTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder
    
    func setSubQuery(where query: String) throws -> JDFDSQLiteQueryBuilder
    func checkQuery(queryHandler:((String) -> Void)?)
    
    func prepare() throws -> JDFDSQLiteExecuteBuilder
}

protocol JDFDSQLiteExecuteBuilder {
    func bind(data: Any, withType type: ColumnType, at col: Int32) throws -> JDFDSQLiteExecuteBuilder
    func execute(rowHandler:((OpaquePointer?, String?) -> Void)?) throws -> JDFDSQLiteExecuteBuilder
    func closeDB()
}

// not in use
class SQLiteDirector {
    private var builder: JDFDSQLiteBuilder?
    
    func buildSqlite(_ builder: JDFDSQLiteBuilder) {
        
    }
    
    func buildSqliteWithQuery(_ builder: JDFDSQLiteBuilder) {
        
    }
}

class SQLiteBuilder: JDFDSQLiteBuilder, JDFDSQLiteQueryBuilder, JDFDSQLiteExecuteBuilder {
    struct TableColumn {
        let name: String
        let type: String
    }
    
    private var SQLite = JDFDSQLite()
    var statement: OpaquePointer?
    let noDataString = "No Data"
    
    init(path: String) throws {
        var DB: OpaquePointer?
        
        guard sqlite3_open(path, &DB) == SQLITE_OK else { throw SQLError.connectionError }
        SQLite.setDB(DB!)
    }
    
    func setDMLtype(type: DML) -> JDFDSQLiteQueryBuilder {
        SQLite.query = type.rawValue
        SQLite.DMLType = type
        
        return self
    }
    
    func setLookUpData(columnNameString: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        if queryString.isEmpty { throw SQLError.queryError }
        
        if columnNameString == "" {
            queryString += " *"
            SQLite.setQuery(queryString)
            return self
        }
        
        queryString += " " + columnNameString.trimmingCharacters(in: .whitespaces)
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func setSelectTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        if tableNameString.isEmpty || queryString.isEmpty { throw SQLError.queryError }
        
        queryString += " FROM " + tableNameString.trimmingCharacters(in: .whitespaces)
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func setUpdateTable(tableNameString: String, setValues: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        if tableNameString.isEmpty || queryString.isEmpty { throw SQLError.queryError }
        
        queryString += " " + tableNameString.trimmingCharacters(in: .whitespaces) + " SET " + setValues
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func setInsertTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        if tableNameString.isEmpty || queryString.isEmpty { throw SQLError.queryError }
        
        queryString += " " + tableNameString.trimmingCharacters(in: .whitespaces)
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func setDeleteTable(tableNameString: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        if tableNameString.isEmpty || queryString.isEmpty { throw SQLError.queryError }
        
        queryString += " " + tableNameString.trimmingCharacters(in: .whitespaces)
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func setSubQuery(where query: String) throws -> JDFDSQLiteQueryBuilder {
        guard var queryString = SQLite.query else { throw SQLError.queryError }
        guard let type = SQLite.DMLType else { throw SQLError.queryError }
        
        switch type {
        case .select, .delete, .update:
            queryString += " WHERE " + query + ";"
        case .insert:
            queryString += " VALUES " + "(" + query + ")" + ";"
        }
        
        SQLite.setQuery(queryString)
        
        return self
    }
    
    func checkQuery(queryHandler:((String) -> Void)? = nil) {
        guard let query = SQLite.query else {
            queryHandler?("need to set query")
            return
        }
        
        queryHandler?(query)
    }
    
    func prepare(with query: String) throws -> JDFDSQLiteExecuteBuilder {
        sqlite3_finalize(statement)
        statement = nil
        
        SQLite.setQuery(query)
        
        if sqlite3_prepare_v2(SQLite.DB, SQLite.query, -1, &statement, nil) == SQLITE_OK {
            return self
        }
        throw SQLError.queryError
    }
    
    func prepare() throws -> JDFDSQLiteExecuteBuilder {
        sqlite3_finalize(statement)
        statement = nil
        
        if sqlite3_prepare_v2(SQLite.DB, SQLite.query, -1, &statement, nil) == SQLITE_OK {
            return self
        }
        
        throw SQLError.queryError
    }
    
    func bind(data: Any, withType type: ColumnType, at col: Int32) throws -> JDFDSQLiteExecuteBuilder {
        sqlite3_reset(statement)
        
        try bindData(data, type, col)
        return self
    }
    
    func execute(rowHandler:((OpaquePointer?, String?) -> Void)? = nil) throws -> JDFDSQLiteExecuteBuilder {
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_DONE: // insert, update, delete
                rowHandler?(statement, noDataString)
            case SQLITE_ROW: // select
                rowHandler?(statement, nil)
            default:
                throw SQLError.otherError
            }
        }
    }
    
    private func bindData(_ data: Any, _ type: ColumnType, _ col: Int32) throws {
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        switch type {
        case .int:
            if let value = data as? Int32 {
                guard sqlite3_bind_int(statement, col, Int32(value)) == SQLITE_OK else { throw SQLError.bindingError }
            } else {
                throw SQLError.typeMissMatchingError
            }
        case .double:
            if let value = data as? Double {
                guard sqlite3_bind_double(statement, col, value) == SQLITE_OK else { throw SQLError.bindingError }
            } else {
                throw SQLError.typeMissMatchingError
            }
        case .text:
            if let value = data as? String {
                let utf8Value = value.cString(using: .utf8)
                guard sqlite3_bind_text(statement, col, utf8Value, -1, SQLITE_TRANSIENT) == SQLITE_OK else { throw SQLError.bindingError }
            } else {
                throw SQLError.typeMissMatchingError
            }
        }
    }
    
    func closeDB() {
        if let statement = self.statement { sqlite3_finalize(statement) }
        if let db = SQLite.DB { sqlite3_close(db) }
    }
}

// MARK: - 간편 조회용
extension SQLiteBuilder {
    func getTableColumns(for tableName: String) -> [TableColumn] {
        var columns = [TableColumn]()
        let query = "PRAGMA table_info(\(tableName));"
        
        if sqlite3_prepare_v2(SQLite.DB, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let name = getColumnValue(for: statement!, columnIndex: 1),
                   let type = getColumnValue(for: statement!, columnIndex: 2) {
                    let column = TableColumn(name: name, type: type)
                    columns.append(column)
                }
            }
            
            sqlite3_finalize(statement)
        }
        
        print(columns)
        
        return columns
    }
    
    func getColumnValue(for statement: OpaquePointer?, columnIndex: Int32) -> String? {
        if let value = sqlite3_column_text(statement, columnIndex) {
            return String(cString: value)
        }
        
        return nil
    }
    
    func getTableInfo() -> [String] {
        sqlite3_finalize(statement)
        statement = nil
        
        var tables: [String] = []
        let query = "SELECT name FROM sqlite_master WHERE type IN ('table', 'view') AND name NOT LIKE 'sqlite_%' UNION ALL SELECT name FROM sqlite_temp_master WHERE type IN ('table', 'view') ORDER BY 1;"
        
        if sqlite3_prepare_v2(SQLite.DB, query, -1, &statement, nil) == SQLITE_OK {
            let result = sqlite3_step(statement)
            print(result)
            
            switch result {
            case SQLITE_ROW: // select
                
                for column in 0..<sqlite3_column_count(statement) {
                    guard let columnName = sqlite3_column_name(statement, column) else {
                        return []
                    }
                    
                    guard let columnValue = sqlite3_column_text(statement, column) else {
                        return []
                    }
                    
                    tables.append(String(cString:columnValue))
                }
            default:
                print("default")
            }
            
            sqlite3_finalize(statement)
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(SQLite.DB))
            print("Error: \(errorMessage)")
        }
        
        return tables
    }
}

final class JDFDSQLite {
    var DB: OpaquePointer?
    
    var DMLType: DML?
    var query: String?
    
    init() {}
    
    func setQuery(_ query: String) {
        self.query = query
    }
    
    func setDB(_ DB: OpaquePointer) {
        self.DB = DB
    }
    
    func setDMLType(_ type: DML) {
        self.DMLType = type
    }
}
