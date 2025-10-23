//
//  Model.swift
//  test47
//
//  Created by thierryH24 on 28/06/2025.
//

import SwiftData
import Foundation
import Combine

@Model
class EntitySchedule: Identifiable {
    var id: UUID = UUID()
    
    var amount                   : Double = 0.0
    var dateDebut                : Date   = Date()
    var dateFin                  : Date   = Date()
    var dateValeur               : Date   = Date()
    var frequence                : Int16  = 0
    var libelle                  : String = ""
    var nextOccurrence           : Int16  = 0
    var occurrence               : Int16  = 0
    var typeFrequence            : Int16  = 0

    init(libelle: String) {
        self.libelle = libelle
    }
    
    public init() {
    }
}

class SchedulerManager {
    
    @Published var entities = [EntitySchedule]()

    static let shared = SchedulerManager()
    private init() {}

    var modelContext: ModelContext? {
        DataContext.shared.context
    }
    
    func getAllData() -> [EntitySchedule]? {
        
        let sort =  [SortDescriptor(\EntitySchedule.libelle, order: .forward)]
        
        let descriptor = FetchDescriptor<EntitySchedule>(
            sortBy: sort )
        
        do {
            // Récupérez les entités en utilisant le FetchDescriptor
            entities = try modelContext?.fetch( descriptor ) ?? []
        } catch {
            printTag("Erreur lors de la récupération des données: \(error)")
            return nil // Retourne nil en cas d'erreur
        }
        return entities
    }


    func delete(entity: EntitySchedule, undoManager: UndoManager?) {
        guard let context = modelContext else { return }

        context.undoManager = undoManager
        context.undoManager?.beginUndoGrouping()
        context.undoManager?.setActionName("Delete Schedule")
        context.delete(entity)
        context.undoManager?.endUndoGrouping()
    }
}


