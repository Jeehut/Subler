//
//  TableView.swift
//  Subler
//
//  Created by Damiano Galassi on 20/10/2017.
//

import Cocoa

@objc protocol ExpandedTableViewDelegate: NSTableViewDelegate {
    @objc optional func deleteSelection(in tableview: NSTableView)
    @objc optional func copySelection(in tableview: NSTableView)
    @objc optional func cutSelection(in tableview: NSTableView)
    @objc optional func paste(to tableview: NSTableView)
}

class ExpandedTableView: NSTableView {

    @objc var pasteboardTypes: [NSPasteboard.PasteboardType]
    var pasteboardHasSupportedType: Bool {
        get {
            // has the pasteboard got a type we support?
            let pb = NSPasteboard.general
            let bestType = pb.availableType(from: pasteboardTypes)
            return bestType != nil
        }
    }

    var targetedRowIndexes: IndexSet {
        get {
            let selection = self.selectedRowIndexes
            let clickedRow = self.clickedRow

            if clickedRow != -1 && selection.contains(clickedRow) == false {
                return IndexSet(integer: clickedRow)
            } else {
                return selection
            }
        }
    }

    @objc var defaultEditingColumn: Int

    private var expandedDelegate: ExpandedTableViewDelegate? {
        get {
            return delegate as? ExpandedTableViewDelegate
        }
    }

    override init(frame frameRect: NSRect) {
        pasteboardTypes = Array()
        defaultEditingColumn = 0
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        pasteboardTypes = Array()
        defaultEditingColumn = 0
        super.init(coder: coder)
    }

    override func keyDown(with event: NSEvent) {

        guard let key = event.charactersIgnoringModifiers?.utf16.first else { super.keyDown(with: event); return }

        if (key == NSEnterCharacter || key == NSCarriageReturnCharacter) && defaultEditingColumn > 0 {
            editColumn(defaultEditingColumn, row: selectedRow, with: nil, select: true)
        }
        else if (key == NSDeleteCharacter || key == NSDeleteFunctionKey) && implements(selector: #selector(ExpandedTableViewDelegate.deleteSelection(in:))) {
            if selectedRow == -1 {
                __NSBeep()
            } else {
                expandedDelegate?.deleteSelection!(in: self)
            }
        }
        else if key == 27 && selectedRow != -1 {
            deselectAll(self)
        }
        else {
            super.keyDown(with: event)
        }

    }

    private func implements(selector: Selector) -> Bool {
        if let implemented = expandedDelegate?.responds(to: selector),
            implemented == true {
            return true
        }
        return false
    }

    @IBAction func delete(_ sender: Any?) {
        if selectedRow != -1 && implements(selector: #selector(ExpandedTableViewDelegate.deleteSelection(in:))) {
            expandedDelegate?.deleteSelection!(in: self)
        }
    }

    @IBAction func copy(_ sender: Any?) {
        if selectedRow != -1 && implements(selector: #selector(ExpandedTableViewDelegate.copySelection(in:))) {
            expandedDelegate?.copySelection!(in: self)
        }
    }

    @IBAction func cut(_ sender: Any?) {
        if selectedRow != -1 && implements(selector: #selector(ExpandedTableViewDelegate.cutSelection(in:))) {
            expandedDelegate?.cutSelection!(in: self)
        }
    }

    @IBAction func paste(_ sender: Any?) {
        if implements(selector: #selector(ExpandedTableViewDelegate.paste(to:))) {
            expandedDelegate?.paste!(to: self)
        }
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if let action = menuItem.action {
            switch action {
            case #selector(delete(_:)):
                if selectedRow == -1 || implements(selector: #selector(ExpandedTableViewDelegate.deleteSelection(in:))) == false {
                    return false
                }
            case #selector(copy(_:)):
                if selectedRow == -1 || implements(selector: #selector(ExpandedTableViewDelegate.copySelection(in:))) == false {
                    return false
                }
            case #selector(cut(_:)):
                if selectedRow == -1 || implements(selector: #selector(ExpandedTableViewDelegate.cutSelection(in:))) == false {
                    return false
                }
            case #selector(paste(_:)):
                if pasteboardHasSupportedType == false || implements(selector:  #selector(ExpandedTableViewDelegate.paste(to:))) == false {
                    return false
                }
            default:
                break
            }
        }
        return true
    }
}
