
//
//  SensorConnection.swift
//  LibreDirect
//

import Combine
import CoreBluetooth
import Foundation

typealias SensorConnectionHandler = (_ update: SensorConnectorUpdate) -> Void

// MARK: - SensorConnectionProtocoll

protocol SensorConnectionProtocoll {
    func pairSensor(updatesHandler: @escaping SensorConnectionHandler)
    func connectSensor(sensor: Sensor, updatesHandler: @escaping SensorConnectionHandler)
    func disconnectSensor()
}

// MARK: - SensorConnectionClass

class SensorConnectionClass: NSObject {
    // MARK: Lifecycle

    required override init() {}

    // MARK: Internal

    var updatesHandler: SensorConnectionHandler?

    func sendUpdate(connectionState: SensorConnectionState) {
        Log.info("ConnectionState: \(connectionState.description)")
        updatesHandler?(SensorConnectionStateUpdate(connectionState: connectionState))
    }

    func sendUpdate(sensor: Sensor) {
        Log.info("Sensor: \(sensor.description)")
        updatesHandler?(SensorUpdate(sensor: sensor))
    }

    func sendUpdate(transmitter: Transmitter) {
        Log.info("Transmitter: \(transmitter.description)")
        updatesHandler?(SensorTransmitterUpdate(transmitter: transmitter))
    }

    func sendUpdate(age: Int, state: SensorState) {
        Log.info("SensorAge: \(age.description)")
        updatesHandler?(SensorStateUpdate(sensorAge: age, sensorState: state))
    }

    func sendUpdate(nextReading: SensorReading) {
        Log.info("NextReading: \(nextReading)")

        updatesHandler?(SensorReadingUpdate(nextReading: nextReading))
    }

    func sendUpdate(trendReadings: [SensorReading] = [], historyReadings: [SensorReading] = []) {
        Log.info("SensorTrendReadings: \(trendReadings)")
        Log.info("SensorHistoryReadings: \(historyReadings)")

        updatesHandler?(SensorReadingUpdate(nextReading: trendReadings.last, trendReadings: trendReadings, historyReadings: historyReadings))
    }

    func sendUpdate(error: Error?) {
        guard let error = error else {
            return
        }

        sendUpdate(errorMessage: error.localizedDescription)
    }

    func sendUpdate(errorMessage: String) {
        Log.error("ErrorMessage: \(errorMessage)")
        updatesHandler?(SensorErrorUpdate(errorMessage: errorMessage))
    }

    func sendUpdate(errorCode: Int) {
        Log.error("ErrorCode: \(errorCode)")
        updatesHandler?(SensorErrorUpdate(errorCode: errorCode))
    }
}

typealias SensorConnection = SensorConnectionClass & SensorConnectionProtocoll

// MARK: - SensorConnectionInfo

class SensorConnectionInfo: Identifiable {
    // MARK: Lifecycle

    init(id: String, name: String, connection: SensorConnection.Type) {
        self.id = id
        self.name = name
        self.connection = connection
    }

    // MARK: Internal

    let id: String
    let name: String
    let connection: SensorConnection.Type
}
