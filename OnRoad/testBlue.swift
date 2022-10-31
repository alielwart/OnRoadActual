//
//  testBlue.swift
//  OnRoad
//
//  Created by Lilly Wu on 10/31/22.
//

import SwiftUI
import CoreBluetooth

// NSObject -- root class of most objective C class hierarchies, from which subclasses inherit a basic interface
// to the runtime system and the ability to hebave as Objective C objects

// Obsservable Object -- type of object with a publisher that emits before the object has changed

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var peripherals: [CBPeripheral] = [] //recording a list of the peripherals
    
    @Published var peripheralNames: [String] = [] //in order to show list
    
    // to have central manager working, it needs a delegate and delegate methods
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        
    }
    
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    //checking for new peripheral in our list
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // if current list of peripherals doesn't containt the new one, append to list
        if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device") //not guaranteed to have a name
        }
    }
}

struct BlueView: View {
    // lowercase var vs upper case class
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    
    var body: some View {
        NavigationView {
            List(bluetoothViewModel.peripheralNames, id: \.self) {
                 peripheral in Text(peripheral)
            }
            .navigationTitle("Peripherals")
        }
    }
}

struct BlueView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

