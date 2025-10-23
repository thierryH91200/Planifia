import SwiftUI
import SwiftData

@main
struct MyUndoApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var container: ModelContainer
    
    let schema = Schema([
        EntitySchedule.self,
    ])
    
    init() {
        
        do {
            let storeURL = URL.documentsDirectory.appending(path: "Planifia.store")
            let config = ModelConfiguration(url: storeURL)
            container = try ModelContainer(for: schema, configurations: config)
            container.mainContext.undoManager = UndoManager()
            let context = container.mainContext
            DataContext.shared.context = context
            DataContext.shared.undoManager = context.undoManager
            
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView( selectedType: "Month")
        }
//        .commands {
//            AppCommands()
//        }

        .modelContainer(
            for: EntitySchedule.self,
            inMemory: false,
            isAutosaveEnabled: true
        )
    }
}

final class DataContext {
    static let shared = DataContext()
    var context: ModelContext?
    var undoManager: UndoManager?

    private init() {}
}


