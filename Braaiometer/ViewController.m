//
//  ViewController.m
//  Braaiometer
//
//  Created by Wilhelm Van Der Walt on 8/1/15.
//  Copyright (c) 2015 ysterslot. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothManager.h"

@interface ViewController ()

@property (nonatomic, strong) BluetoothManager* bleManager;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.bleManager beginScanning];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(BluetoothManager *) bleManager {
	if (!_bleManager) {
		_bleManager = [[BluetoothManager alloc] initWithDataBlock:^(NSData * data) {
			if (data) {
				NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				self.label.text = s;
			}

		}];
		return _bleManager;
	}
	return self.bleManager;
}

@end
