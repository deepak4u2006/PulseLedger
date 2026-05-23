import SwiftUI
import SwiftData

@main
struct PulseLedgerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TransactionRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView(context: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
