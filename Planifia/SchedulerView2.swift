//
//  Untitled.swift
//  PegaseUIData
//
//  Created by Thierry hentic on 23/05/2025.
//

import AppKit
import SwiftUI
import SwiftDate
import SwiftData

private enum UpdateTrigger {
    case dateDebut
    case frequencyCount
    case occurrence
    case frequencyType
}

// Vue pour la boîte de dialogue d'ajout
struct SchedulerFormView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var isModeCreate: Bool
    
    @State var scheduler: EntitySchedule?
    
    @State private var amount: String = ""
    @State private var dateValeur: Date = Date()
    @State private var dateDebut: Date = Date()
    @State private var dateFin: Date = Date()
    @State private var frequence: String = ""
    @State private var libelle: String = ""
    @State private var nextOccurrence: String = ""
    @State private var occurrence: String = ""
    @State private var frequency: String = ""
    
    @State private var frequenceType     : [String]    = []
    
    @State var selectedTypeIndex = 0
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            schedulerDateFields
            schedulerTextFields
            schedulerPickers
        }
        .frame(width: 300)
        .padding()
        .navigationTitle(scheduler == nil ? "New scheduler" : "Edit scheduler")
        .background(.white)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
            }
        }
        .onAppear {

            frequenceType = [
                String(localized :"Day",table : "Account"),
                String(localized :"Week",table : "Account"),
                String(localized :"Month",table : "Account"),
                String(localized :"Year",table : "Account")]
            
            if let scheduler = scheduler {
                //                scheduler.account = currentAccount
                amount = String(scheduler.amount)
                dateValeur = scheduler.dateValeur
                dateDebut = scheduler.dateDebut
                dateFin = scheduler.dateFin
                frequence = String(scheduler.frequence)
                libelle = scheduler.libelle
                nextOccurrence = String(scheduler.nextOccurrence)
                occurrence = String(scheduler.occurrence)
                frequency = String(scheduler.frequence)
                
                selectedTypeIndex = Int(scheduler.typeFrequence)
                
            } else {
                //                account = scheduler.account!
                amount = String(scheduler?.amount ?? 0.0)
                dateValeur = Date().noon
                dateDebut = Date().noon
                dateFin = Date().noon + 12.months
                frequence = "2"
                libelle = ""
                nextOccurrence = "1"
                occurrence = "12"
                frequency = "1"
                
                selectedTypeIndex = 2
            }
        }
    }
    
    private var schedulerDateFields: some View {
        Group {
            HStack {
                Text("Start Date").frame(width: 100, alignment: .leading)
                DatePicker("", selection: $dateDebut, displayedComponents: .date)
            }
            HStack {
                Text("Value Date").frame(width: 100, alignment: .leading)
                DatePicker("", selection: $dateValeur, displayedComponents: .date)
            }
            HStack {
                Text("End Date").frame(width: 100, alignment: .leading)
                DatePicker("", selection: .constant(dateFin), displayedComponents: .date)
                    .disabled(true)
            }
        }
        .onChange(of: dateDebut) { old, newValue in
            update(.dateDebut)
        }
    }

    private var schedulerTextFields: some View {
        Group {
            HStack {
                Text("Occurence").frame(width: 100, alignment: .leading)
                TextField("Occurence", text: $occurrence)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("Next occurence").frame(width: 100, alignment: .leading)
                TextField("Next occurence", text: $nextOccurrence)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)
            }
            HStack {
                Text("Comment").frame(width: 100, alignment: .leading)
                TextField("Comment", text: $libelle)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("Amount").frame(width: 100, alignment: .leading)
                TextField("Amount", text: $amount)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .onChange(of: occurrence) { _, _ in update(.occurrence) }
    }

    private var schedulerPickers: some View {
        Group {
            HStack {
                Text("Frequency").frame(width: 100, alignment: .leading)
                TextField("", text: $frequency)
                    .textFieldStyle(.roundedBorder)
                Picker("", selection: $selectedTypeIndex) {
                    ForEach(0..<frequenceType.count, id: \.self) { index in
                        Text(frequenceType[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .onChange(of: occurrence)        { _, _ in update(.occurrence) }
            .onChange(of: dateDebut)         { _, _ in update(.dateDebut) }
            .onChange(of: selectedTypeIndex) { _, _ in update(.frequencyType) }
            .onChange(of: frequency)         { _, _ in update(.frequencyCount) }
        }
    }
    
    private func update(_ trigger: UpdateTrigger) {
        
        let numOccurrence = Int(occurrence) ?? 1
        let numFrequence = Int(frequency) ?? 1
        let nombre = (numFrequence * numOccurrence) - (numFrequence )
        
        switch trigger {
        case .dateDebut, .frequencyCount, .occurrence, .frequencyType:
            
            switch selectedTypeIndex {
            case 0:
                dateFin = dateDebut + nombre.days
            case 1:
                dateFin = dateDebut + nombre.weeks
            case 2:
                dateFin = dateDebut + nombre.months
            case 3:
                dateFin = dateDebut + nombre.years
            default:
                dateFin = dateDebut + nombre.months
            }
        }
    }
    
    private func save() {
        
        var newItem: EntitySchedule?
        
        if let existingStatement = scheduler {
            newItem = existingStatement
        } else {
            newItem = EntitySchedule()
            let modelContext = DataContext.shared.context
            modelContext?.insert(newItem!)
        }
        if let frequence = Int16(frequency),
           let nextOccurrence = Int16(nextOccurrence),
           let occurrence = Int16(occurrence),
           let frequencyType = Int16(exactly: selectedTypeIndex),
           let amount = Double(amount) {
            
            newItem?.amount = amount
            newItem?.dateValeur = dateValeur.noon
            newItem?.dateDebut = dateDebut.noon
            newItem?.dateFin = dateFin.noon
            newItem?.frequence = frequence
            if libelle == "" {
                libelle = "test"
            }
            newItem?.libelle = libelle
            newItem?.nextOccurrence = nextOccurrence
            newItem?.occurrence = occurrence
            newItem?.typeFrequence = Int16(frequencyType)
            
            let undoManager = DataContext.shared.undoManager
            guard let modelContext = DataContext.shared.context else {
                // If there's no context, we can't register undo or save; just bail out gracefully
                scheduler = nil
                newItem = nil
                return
            }

            undoManager?.registerUndo(withTarget: modelContext) { context in
                context.delete(newItem!)
            }
            try? modelContext.save()
            scheduler = nil
            newItem = nil
        }
    }
}
