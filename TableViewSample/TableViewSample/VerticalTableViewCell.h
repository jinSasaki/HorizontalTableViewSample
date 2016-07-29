//
//  VerticalTableViewCell.h
//  TableViewSample
//
//  Created by Jin Sasaki on 2016/07/30.
//  Copyright © 2016年 Jin Sasaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerticalTableViewCell : UITableViewCell <UITableViewDataSource> {
}

@property (nonatomic) NSArray *weatherCapitals;
@property (nonatomic) NSDictionary *weatherDataMap;
@property (nonatomic, weak) IBOutlet UITableView *horizontalTableView;

@end
