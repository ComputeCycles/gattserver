//
//  GATTServiceController.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/30/18.
//
//

import Foundation
import Bluetooth
#if os(Linux)
import GATT
import BluetoothLinux
public typealias PeripheralManager = GATTPeripheral<HostController, L2CAPSocket>
#else
import DarwinGATT
import BluetoothDarwin
public typealias PeripheralManager = DarwinPeripheral
#endif

public protocol GATTServiceController: class {
    
    static var service: BluetoothUUID { get }
    
    var peripheral: PeripheralManager { get }
    
    init(peripheral: PeripheralManager) throws
}

internal let serviceControllers: [GATTServiceController.Type] = [
    GATTBatteryServiceController.self,
    GATTDeviceInformationServiceController.self
]
