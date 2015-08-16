//
//  BluetoothManager.h
//  Braaiometer
//
//  Created by Wilhelm Van Der Walt on 8/1/15.
//  Copyright (c) 2015 ysterslot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothManager : CBCentralManager<CBCentralManagerDelegate>
-(void)beginScanning;
-(id) initWithDataBlock: (void (^)(NSData*))dataBlock;
@end
