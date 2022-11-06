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
    private var paired: [CBPeripheral] = []
    
    @Published var peripheralNames: [String] = [] //in order to show list
    @Published var pairedNames: [String] = []
    
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
            //retrieveConnectedPeripherals returns bluetooth devices connect to the syste/
            //if peripheral state shows disconnected, that peripheral is not connected to central manager
            let connected = self.centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: "180A")])
             
            for conpair in connected! {
                paired.append(conpair)
                pairedNames.append(conpair.name ?? "unnamed device")
            }
        }
    }
    
    //scanning for new peripheral in our list
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // if current list of peripherals doesn't contain the new one, append to list
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
//            List(bluetoothViewModel.peripheralNames, id: \.self) {
//                 peripheral in Text(peripheral)
//            }
//            .navigationTitle("Peripherals")

            List(bluetoothViewModel.pairedNames, id: \.self) {
                peripheral in Text(peripheral)
            }
            .navigationTitle("Paired")
        }
        .navigationViewStyle(.stack)
    }
}

struct BlueView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

