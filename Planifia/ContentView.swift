import SwiftUI
import SwiftData
import AppKit
import Combine



struct ContentView: View {
    
//    @State private var sortOrder: [KeyPathComparator<EntitySchedule>] = []

    var selectedScheduler: EntitySchedule? {
        guard let id = selectedItem else { return nil }
        return sortedSchedulers.first { $0.id == id }
    }

    @State var schedulers: [EntitySchedule] = []
    
    @State var modelContext : ModelContext?
    @State var undoManager : UndoManager?

    @State private var selectedItem: EntitySchedule.ID?
    @State private var lastDeletedID: UUID?

    @State private var isAddDialogPresented = false
    @State private var isEditDialogPresented = false
    @State private var modeCreate = false
    
    var canUndo: Bool {
        undoManager?.canUndo ?? false
    }

    var canRedo: Bool {
        undoManager?.canRedo ?? false
    }

    @State var selectedType     : String
    @State private var sortOrder: [KeyPathComparator<EntitySchedule>] = [
        .init(\.libelle, order: .forward)
    ]
    
    var selectedSchedule: EntitySchedule? {
        guard let id = selectedItem else { return nil }
        return schedulers.first(where: { $0.id == id })
    }
    
    var sortedSchedulers: [EntitySchedule] {
        schedulers.sorted {
            $0.libelle < $1.libelle
        }
    }

    var body: some View {
        VStack {
            Text("\(schedulers.count) schedules ")
            Table(sortedSchedulers, selection: $selectedItem, sortOrder: $sortOrder) {
                TableColumn("Comment", value: \.libelle)
                TableColumn("Amount") { Text(String(format: "%.2f", $0.amount)) }
                TableColumn("Occurence") { Text(String(format: "%d", $0.occurrence)) }
            }
            .tableStyle(.bordered)
            .onAppear {
                schedulers = SchedulerManager.shared.getAllData() ?? []
            }
            
            HStack {
                Button(action: {
                    isAddDialogPresented = true
                    modeCreate = true
                }) {
                    Label("Add", systemImage: "plus")
                        .frame(minWidth: 100) // Largeur minimale utile
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain) // pour éviter les bordures par défaut sur macOS
                Button(action: {
                    isEditDialogPresented = true
                    modeCreate = false
                }) {
                    Label("Edit", systemImage: "plus")
                        .frame(minWidth: 100) // Largeur minimale utile
                        .padding()
                        .background(selectedItem == nil ? Color.gray : Color.green)
                        .opacity(selectedItem == nil ? 0.6 : 1)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled( selectedItem == nil )
                }
                .buttonStyle(.plain) // pour éviter les bordures par défaut sur macOS
                Button(action: {
                    delete()
                }) {
                    Label("Delete", systemImage: "trash")
                        .frame(minWidth: 100) // Largeur minimale utile
                        .padding()
                        .background(selectedItem == nil ? Color.gray : Color.red)
                        .opacity(selectedItem == nil ? 0.6 : 1)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled( selectedItem == nil )
                }
                .buttonStyle(.plain)
                .disabled(selectedItem == nil)
                
                Button(action: {
                    if let manager = undoManager, manager.canUndo {
                        manager.undo()
                        schedulers = SchedulerManager.shared.getAllData() ?? []
                    }
                }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .frame(minWidth: 100) // Largeur minimale utile
                        .padding()
                        .background(canUndo == false ? Color.gray : Color.green)
                        .opacity(canUndo == false  ? 0.6 : 1)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    if let manager = undoManager, manager.canRedo {
                        manager.redo()
                        schedulers = SchedulerManager.shared.getAllData() ?? []
                        
                    }
                }) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                        .frame(minWidth: 100) // Largeur minimale utile
                        .padding()
                        .background( canRedo == false ? Color.gray : Color.orange)
                        .opacity( canRedo  == false ? 0.6 : 1)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .onAppear {
            modelContext = DataContext.shared.context
            undoManager = DataContext.shared.undoManager
        }
        .onChange(of: schedulers) { _, _ in
            if let restoredID = lastDeletedID,
               schedulers.contains(where: { $0.id == restoredID }) {
                selectedItem = restoredID
                lastDeletedID = nil
            }
        }
        .frame(width: 400, height: 350)
        
        .sheet(isPresented: $isAddDialogPresented, onDismiss: {
            schedulers = SchedulerManager.shared.getAllData() ?? []
        }) {
            SchedulerFormView(
                isModeCreate: $modeCreate,
                scheduler: nil,
                selectedTypeIndex: indexForSelectedType()
            )
        }
        .sheet(isPresented: $isEditDialogPresented, onDismiss: {
            schedulers = SchedulerManager.shared.getAllData() ?? []
        }) {
            let selectedSchedule = schedulers.first { $0.id == selectedItem }
            SchedulerFormView(
                isModeCreate: $modeCreate,
                scheduler: selectedSchedule,
                selectedTypeIndex: indexForSelectedType()
            )
        }

    }
    
    private func delete() {
        if let id = selectedItem,
           let item = schedulers.first(where: { $0.id == id }) {
            lastDeletedID = id
            
            SchedulerManager.shared.delete(entity: item, undoManager: undoManager)
            DispatchQueue.main.async {
                selectedItem = nil
            }
            schedulers = SchedulerManager.shared.getAllData() ?? []
        }
    }
    
    private func indexForSelectedType() -> Int {
        let types = ["Day", "Week", "Month", "Year"]
        return types.firstIndex(of: selectedType) ?? 2 // Retourne 2 (Month) par défaut
    }
}

func printTag( _ message: String, flag : Bool = true) {
    if flag == true {
        let tag = "[Planifia]"
        print("\(tag) \(message)")
    }
}

