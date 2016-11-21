//
//  TableViewDeleteDelegate.swift
//  Pods
//
//  Created by Vlad Gorbenko on 11/21/16.
//
//

import UIKit

open class TableDeleteDelegate<Model: Equatable, View: ViewDelegate, Cell: ContentCell>: TableDelegate<Model, View, Cell> where View: UIView {

    public override init() {
        super.init()
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! Cell
            self.content.actions.onDelete?(self.content, self.content.items[indexPath.row], cell)
        }
    }
    
}
