//
//  listViewController.h
//  audioguide
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface listViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UIBarButtonItem *editBarButton;
    
    NSInteger selectedRow;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *audioItem;

@property (nonatomic, strong) NSMutableArray *dataSourceItem;
@property (nonatomic, strong) NSMutableArray *dataSourceIndex;

@end
