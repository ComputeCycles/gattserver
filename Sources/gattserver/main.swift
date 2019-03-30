//
//  main.swift
//  gattserver
//
//  Created by Alsey Coleman Miller on 6/29/18.
//
//

import Foundation
import CoreFoundation
import Bluetooth

#if os(Linux)
import GATT
import BluetoothLinux
#else
import DarwinGATT
import BluetoothDarwin
//public typealias Peripheral = DarwinPeripheral
#endif

public extension Data {
    /// A hexadecimal string representation of the bytes.
    var hexEncodedString: String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}

var serviceController: GATTServiceController?

func run(arguments: [String] = CommandLine.arguments) throws {
    
    //  first argument is always the current directory
    let arguments = Array(arguments.dropFirst())
    
    #if os(Linux)
    guard let controller = HostController.default
        else { throw CommandError.bluetoothUnavailible }
        
    print("Bluetooth Controller: \(controller.address)")
    
    let peripheral = PeripheralManager(controller: controller)
    peripheral.newConnection = { [weak peripheral] () throws -> (L2CAPSocket, Central) in
        let serverSocket = try L2CAPSocket.lowEnergyServer(
            controllerAddress: controller.address,
            isRandom: false,
            securityLevel: .low
        )
        let socket = try serverSocket.waitForConnection()
        let central = Central(identifier: socket.address)
        peripheral?.log?("[\(central)]: New \(socket.addressType) connection")
        return (socket, central)
    }
    #else
    let peripheral = PeripheralManager()
    #endif
    
    peripheral.log = { print("PeripheralManager:", $0) }
    
    #if os(macOS)
    while peripheral.state != .poweredOn { sleep(1) }
    #endif
    
    guard let serviceUUIDString = arguments.first
        else { throw CommandError.noCommand }
    
    guard let service = BluetoothUUID(rawValue: serviceUUIDString),
        let controllerType = serviceControllers.first(where: { $0.service == service })
        else { throw CommandError.invalidCommandType(serviceUUIDString) }
    
    serviceController = try controllerType.init(peripheral: peripheral)
    
    try peripheral.start()
    
    while true {
        #if os(Linux)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.001, true)
        #elseif os(macOS)
            CFRunLoopRunInMode(.defaultMode, 0.001, true)
        #endif
    }
}

do { try run() }
    
catch {
    print("\(error)")
    exit(1)
}
