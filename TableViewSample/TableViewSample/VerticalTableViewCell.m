//
//  VerticalTableViewCell.m
//  TableViewSample
//
//  Created by Jin Sasaki on 2016/07/30.
//  Copyright © 2016年 Jin Sasaki. All rights reserved.
//

#import "VerticalTableViewCell.h"
#import "Cell.h"

@implementation VerticalTableViewCell

static NSString * const TableViewCustomCellIdentifier = @"Cell";

- (void)awakeFromNib
{
    [super awakeFromNib];

    // TableViewで仕様するCellを登録する
    UINib *nib = [UINib nibWithNibName:TableViewCustomCellIdentifier bundle:nil];
    [self.horizontalTableView registerNib:nib forCellReuseIdentifier:TableViewCustomCellIdentifier];
    self.horizontalTableView.dataSource = self;

    // TableView全体を時計回りに90度回転させる
    self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weatherCapitals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCustomCellIdentifier forIndexPath:indexPath];
    // コンテンツを反時計回りに90度回転させる
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    // Weatherから文字を設定する
    NSString *capital = self.weatherCapitals[indexPath.row];
    NSDictionary *weather = self.weatherDataMap[capital];
    if (weather) {
        cell.textLabel.text = weather[@"names"];
        
        NSArray *icons = weather[@"icons"];
        if (icons && icons.count > 0) {
            cell.detailTextLabel.text = icons[0];
        } else {
            cell.detailTextLabel.text = nil;
        }
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

@end
