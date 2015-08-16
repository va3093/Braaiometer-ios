//
//  BluetoothManager.m
//  Braaiometer
//
//  Created by Wilhelm Van Der Walt on 8/1/15.
//  Copyright (c) 2015 ysterslot. All rights reserved.
//

#import "BluetoothManager.h"

@interface BluetoothManager()<CBPeripheralDelegate> {
	CBUUID *service;
	CBUUID *bcharacteristic;
	CBPeripheral *bPeripheral;
}

@property (nonatomic, copy) void (^dataBlock)(NSData*);

@end

@implementation BluetoothManager


-(instancetype)init {
	self = [super initWithDelegate:self queue:nil];
	if (self) {
		service = [CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"];
		bcharacteristic = [CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"];
	}
	return self;
}

-(instancetype) initWithDataBlock: (void (^)(NSData*))dataBlock {
	self = [super initWithDelegate: self queue: nil];
	if (self) {
		service = [CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"];
		bcharacteristic = [CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"];
		self.dataBlock = dataBlock;
	}
	return self;
}

- (void) beginScanning {
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
		[self scanForPeripheralsWithServices:@[service] options:nil ];

	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	NSLog(@"didDiscoverPeripheral: %@ advertisementData: %@, RSSI: %@",peripheral, advertisementData, RSSI);
	
	bPeripheral = peripheral;
	bPeripheral.delegate = self;
	[self connectPeripheral:peripheral options:nil];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	[bPeripheral discoverServices:@[[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"]] ];
	NSLog(@"didConnectPeripheral: %@", peripheral);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"didFailToConnectPeripheral:%@ error:%@", peripheral, error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	NSLog(@"didDisconnectPeripheral: %@ error: %@", peripheral, error);
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	for (CBService *bService in peripheral.services) {
		NSLog(@"Discovered service: %@", bService.UUID);
		[peripheral discoverCharacteristics:nil forService:bService];
	}
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)bservice error:(NSError *)error {
	if ([bservice.UUID isEqual:[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"]])  {
		for (CBCharacteristic *aChar in bservice.characteristics)
		{
			if ([aChar.UUID isEqual: [CBUUID UUIDWithString:@"713D0002-503E-4C75-BA94-3148F18D941E"]]) {
				[bPeripheral setNotifyValue:YES forCharacteristic:aChar];
				[bPeripheral readValueForCharacteristic:aChar];
			}
		}
	}
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	// Updated value for heart rate measurement received
	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"713D0002-503E-4C75-BA94-3148F18D941E"]]) { // 1
		// Get the Heart Rate Monitor BPM
		NSData *data = [characteristic value];      // 1
		if (data) {
			self.dataBlock(data);
			NSLog(@"data: %@", data);
			NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			NSLog(@"%@", s);
			NSNumber *form = [NSNumber numberWithBool:YES];
			
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:s, @"textString", form, @"form", nil];

			NSLog(@"reportData textString: %@", dict[@"textString"]);
			NSLog(@"reportData form: %@", dict[@"form"]);
		}
		
	}
	
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	if (error) {
		NSLog(@"There was an error subscribing to notifications: %@", error);
	}
}


@end
