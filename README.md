Certainly! Here is a summary of the application as understood from the provided code:


<p align="center">
<img src="Doc/Capture1.png" alt="Capture1">
<p align="center">
<em>Welcome</em>
</p>
</p>

⸻

Application Summary

General Objective

the application is an interface for managing “schedules” (plannings, timetables, or scheduled tasks), with the ability to add, edit, view, and delete EntitySchedule entities. It is designed for macOS, uses SwiftUI for the interface, SwiftData for data persistence, and includes undo/redo operations management.

⸻

Main Features

1. Viewing and Selecting Schedules
• A list displays all schedules present in the database.
• You can select a schedule from the list; the system remembers the selected item via its identifier.

2. Adding a Schedule
• An “Add” button opens a dialog box (SchedulerFormView) to enter the information for a new schedule: dates, frequency, occurrences, amount, comment, etc.
• The available frequency types are “Day, Week, Month, Year.”

3. Deleting a Schedule
• A “Delete” button removes the selected item.
• The application remembers the last deleted item to allow re-selection if needed.

4. Undo / Redo
• Two buttons, “Undo” and “Redo,” let you undo or redo recent changes, relying on the undoManager from the SwiftUI environment.

5. Editing a Schedule
• When you open the dialog on an existing item, the fields are pre-filled with its values; otherwise, they get default values.

6. Smart Date Management
• The form dynamically calculates the end date (dateFin) based on the start date, frequency, frequency type (day/week/month/year), and the number of occurrences.
• These calculations are updated automatically when the user changes the corresponding fields.

⸻

Architecture and Technologies

• SwiftUI: Used for the entire graphical interface.
• SwiftData: For managing persistent data (local storage of schedules).
• SwiftDate: For advanced date calculations and manipulations.
• UndoManager: Allows users to undo/redo actions on data.

⸻

Customized / Notable Points

• The application uses mechanisms for managing data context (modelContext) and localization (String(localized:)).
• Action buttons are styled for better visual integration on macOS.
• Utilities like printTag are used to centralize debug logs.

⸻

