//
//  ViewController.m
//  TableViewSample
//
//  Created by Jin Sasaki on 2016/07/30.
//  Copyright © 2016年 Jin Sasaki. All rights reserved.
//

#import "ViewController.h"
#import "VerticalTableViewCell.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *sampleCapitals;
@property (nonatomic) NSCache *cache;
@property (nonatomic) NSDictionary *weatherIconDict;
@property (nonatomic) NSMutableDictionary *weatherDataMap;

@end

@implementation ViewController

static NSString *VerticalTableViewCellIdentifier = @"VerticalTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sampleCapitals = @[
                            @[
                                @"tokyo",
                                @"osaka",
                                @"kyoto",
                                @"okinawa",
                                @"hiroshima",
                                @"sapporo"
                            ],
                            @[
                                @"tokyo",
                                @"osaka",
                                @"kyoto",
                                @"okinawa",
                                @"hiroshima",
                                @"sapporo"
                                ],
                            @[
                                @"tokyo",
                                @"osaka",
                                @"kyoto",
                                @"okinawa",
                                @"hiroshima",
                                @"sapporo"
                                ]
                            ];
    self.weatherDataMap = @{}.mutableCopy;
    
    UINib *nib = [UINib nibWithNibName:VerticalTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:VerticalTableViewCellIdentifier];

    self.tableView.dataSource = self;
}

- (void)fetchWeatherData:(NSArray *)capitals indexPath:(NSIndexPath *)indexPath
{
    
    // 非同期で行うためのキューを作成
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    
    // 非同期処理
    dispatch_async(q_global, ^{
        
        // すべての capital に対して APIを叩く
        for (NSString *capital in capitals) {
            
            // URL作成
            NSURL *url;
            NSRange searchResult = [capital rangeOfString:@"lat="];
            if(searchResult.location == NSNotFound){
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?APPID=b8f4ce09ae1ca4d1b34a14438e857866&q=%@", capital]];
            }else{
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?APPID=b8f4ce09ae1ca4d1b34a14438e857866&%@", capital]];
            }
            // キャッシュにデータがあるかチェック
            if([self.cache objectForKey:url]) {
                // キャッシュがあればなにもせずに飛ばす
                NSLog(@"cache...%@",self.cache);
                continue;
            }
            
            // APIを叩いてデータを取得
            NSURLSessionDataTask *task = [[NSURLSession sharedSession]
             dataTaskWithURL:url
             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                 // data がない場合はエラーで終了
                 if (!data) {
                     NSLog(@"レスポンス == %@, エラー == %@", response, error);
                     return;
                 }
                 
                 // JSONをパースする
                 NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
                 // 空だったらの失敗ため終了
                 if (!object) {
                     return;
                 }
                 
                 // 必要な情報を取得
                 NSArray *main = [object valueForKeyPath:@"weather.main"]; //天候
                 NSArray *description = [object valueForKeyPath:@"weather.description"]; // 天候詳細
                 NSArray *speed = [object valueForKeyPath:@"wind.speed"]; //風速
                 NSArray *icons = [object valueForKeyPath:@"weather.icon"];
                 NSArray *names = [object valueForKeyPath:@"name"];
                 NSLog(@"main(天候)=%@,description(天候詳細)=%@,speed(風速)=%@,icons(天気アイコン)=%@,name=%@",main,description,speed,icons,names);
                 
                 // 取得したデータを保持する
                 NSMutableDictionary *weatherData = @{@"main":main,
                                                      @"description":description,
                                                      @"speed":speed,
                                                      @"icons":icons,
                                                      @"names":names}.mutableCopy;
                 self.weatherDataMap[capital] = weatherData;

                 dispatch_async(q_main, ^{
                     // データを反映する該当する行のセルを取得して更新
                     VerticalTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                     cell.weatherDataMap = self.weatherDataMap;
                     [cell.horizontalTableView reloadData];
                 });
             }];
            [task resume];
        }
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sampleCapitals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VerticalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VerticalTableViewCellIdentifier forIndexPath:indexPath];
    NSArray *capitals = self.sampleCapitals[indexPath.row];
    [self fetchWeatherData:capitals indexPath:indexPath];
    cell.weatherCapitals = capitals;
    cell.weatherDataMap = self.weatherDataMap;
    [cell.horizontalTableView reloadData];
    return cell;
}

@end
