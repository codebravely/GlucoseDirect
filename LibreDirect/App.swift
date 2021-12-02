//
//  App.swift
//  LibreDirect
//

import CoreBluetooth
import SwiftUI

// MARK: - LibreDirectApp

@main
final class LibreDirectApp: App {
    // MARK: Lifecycle

    init() {
        UNUserNotificationCenter.current().delegate = notificationCenterDelegate

        /* if store.state.isPaired && store.state.isConnectable {
             DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                 self.store.dispatch(.connectSensor)
             }
         } */

        store.dispatch(.startup)
    }

    // MARK: Internal

    static var isPreviewMode: Bool {
        return UserDefaults.standard.bool(forKey: "preview_mode")
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }

    // MARK: Private

    private let store = createStore()
    private let notificationCenterDelegate = LibreDirectNotificationCenter()

    private static func createStore() -> AppStore {
        if isSimulator || isPreviewMode {
            Log.info("start preview mode")

            return createPreviewStore()
        }

        return createAppStore()
    }

    private static func createPreviewStore() -> AppStore {
        return AppStore(initialState: InMemoryAppState(), reducer: appReducer, middlewares: [
            // required middlewares
            actionLogMiddleware(),
            sensorConnectorMiddelware([
                SensorConnectionInfo(id: "virtual", name: "Virtual", connection: VirtualLibreConnection.self)
            ]),

            // notification middleswares
            expiringNotificationMiddelware(),
            glucoseNotificationMiddelware(),
            connectionNotificationMiddelware(),
            glucoseBadgeMiddelware(),
        ])
    }

    private static func createAppStore() -> AppStore {
        return AppStore(initialState: UserDefaultsAppState(), reducer: appReducer, middlewares: [
            // required middlewares
            actionLogMiddleware(),
            sensorConnectorMiddelware([
                SensorConnectionInfo(id: "libre2", name: "Libre 2", connection: Libre2Connection.self),
                SensorConnectionInfo(id: "virtual", name: "Virtual", connection: VirtualLibreConnection.self)
            ]),

            // notification middleswares
            expiringNotificationMiddelware(),
            glucoseNotificationMiddelware(),
            connectionNotificationMiddelware(),
            glucoseBadgeMiddelware(),

            // export middlewares
            nightscoutMiddleware(),
            appGroupSharingMiddleware(),
        ])
    }
}

// MARK: - LibreDirectNotificationCenter

final class LibreDirectNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
}
