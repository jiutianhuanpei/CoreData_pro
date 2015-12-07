//
//  ViewController.m
//  CoreData_pro
//
//  Created by 沈红榜 on 15/11/25.
//  Copyright © 2015年 沈红榜. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Person.h"

#import <MJRefresh.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController {
    NSInteger       _page;
    
    NSMutableArray  *_dataArray;
    __weak IBOutlet UITableView *_tableView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _page = 0;
    _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    _tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) SHB = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [SHB getDataMore:true];
    }];
    
    header.stateLabel.hidden = true;
    header.lastUpdatedTimeLabel.hidden = true;
    _tableView.mj_header = header;
    [self getDataMore:false];
    
    // 打印全部数据
    NSArray *ar = [Person MR_findAllSortedBy:@"name" ascending:false];
    NSArray *na = [ar valueForKeyPath:@"@unionOfObjects.name"];
    NSLog(@"allname:%@", na);

}
- (IBAction)addData:(id)sender {
    NSString *name = [NSString stringWithFormat:@"name_%d", arc4random() % 1000];
    
    
    Person *man = [Person MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]];
    if (!man) {
        man = [Person MR_createEntity];
        man.name = name;
        man.time = @([[NSDate date] timeIntervalSince1970]);
        [man.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        [_dataArray addObject:man];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    }
    
}


- (void)getDataMore:(BOOL)isMore {
    if (isMore) {
        _page = _dataArray.count == 0 ? 0 : _page + 1;
    } else {
        _page = 0;
    }

    
    NSFetchRequest *request = [Person MR_requestAll];
    
    NSInteger allDataNum = [[Person MR_numberOfEntities] integerValue];
    NSInteger pageCount = 5;
    
    NSInteger startNum = allDataNum - pageCount * (_page + 1);
    NSLog(@"start:%d", startNum);
    
    if (allDataNum / pageCount < _page) {
        // 超出数据范围，返回 空
        [_tableView.mj_header endRefreshing];
        NSLog(@"return");
        return;
    }
    
    
    NSInteger offset = 0;
    NSInteger limit = 0;
    
    if (startNum >= 0) {
        offset = startNum;
        limit = pageCount;
    } else {
        offset = 0;
        limit = allDataNum % pageCount == 0 ? pageCount : allDataNum % pageCount;
    }
    NSLog(@"offset/limit:%d   %d", offset, limit);
    [request setFetchOffset:offset];   // 如果最后的数据不够一页，从第一条开始查
    [request setFetchLimit:limit];  //如果最后的数据不够一页，返回剩余的数据个数
    [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:false]]];    // 设置数据排序
    NSArray *array = [Person MR_executeFetchRequest:request];
    [_tableView.mj_header endRefreshing];
    
    
    if (isMore) {
        if (array.count > 0) {
            NSMutableArray *indexs = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                [indexs addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
//            [_dataArray addObjectsFromArray:array];
            [_dataArray insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
            
            [UIView setAnimationsEnabled:false];
            
            [_tableView insertRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationNone];
            if (_dataArray.count > array.count) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:array.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:false];
            } else {
                [_tableView reloadData];
            }
            [UIView setAnimationsEnabled:true];
        }
    } else {
        if (array.count > 0) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:array];
        }
        [_tableView reloadData];
    }
    NSLog(@"array:%@", [array valueForKeyPath:@"@unionOfObjects.name"]);

}

- (IBAction)deleteAllData:(id)sender {
    
    [Person MR_deleteAllMatchingPredicate:nil];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [_dataArray removeAllObjects];
    [_tableView reloadData];
}

- (IBAction)resetMainScreen:(id)sender {
    [_dataArray removeAllObjects];
    [_tableView reloadData];
    _page = 0;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    Person *man = _dataArray[indexPath.row];
    cell.textLabel.text = man.name;
    cell.detailTextLabel.text = [self timeByInterval:[man.time doubleValue]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (NSString *)timeByInterval:(NSTimeInterval)time {
    
    static NSDateFormatter *matter = nil;
    if (!matter) {
        matter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
        matter.timeZone = timeZone;
        
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        matter.locale = locale;
        [matter setDateFormat:@"MM-dd hh:mm:ss"];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    return [matter stringFromDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
