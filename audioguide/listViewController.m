//
//  listViewController.m
//  audioguide
//
//  Created by hzhwang on 2015/01/31.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "listViewController.h"
#import "noteViewController.h"
#import "defines.h"
@implementation listViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editSwitch)];
    self.navigationItem.rightBarButtonItem = editBarButton;

    selectedRow=-1;
    [self loadData];
    
}
- (void)editSwitch {
    if([self.tableView isEditing]==YES) {
        [self.tableView setEditing:NO animated:YES];
    } else {
        [self.tableView setEditing:YES animated:YES];
    }
}
- (void)loadData {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:AUDIO_STORAGE_KEY];
    self.audioItem=[NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
}
- (void)saveData {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.audioItem];
    [defaults setObject:data forKey:AUDIO_STORAGE_KEY];
    [defaults setBool:YES forKey:@"bootstraps"];
    [defaults synchronize];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadData];
    [self.tableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"list"]) {
        
    } else {
        NSMutableDictionary *d =[self.audioItem objectForKey:[[self.audioItem allKeys] objectAtIndex:selectedRow]];
        noteViewController *vc = (noteViewController*)[segue destinationViewController];
        [vc setKey:[d objectForKey:@"id"]];
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow=indexPath.row;
    [self performSegueWithIdentifier:@"note" sender:self];
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [[self.audioItem allKeys] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
//        [self.dataSourceItem removeObjectAtIndex:indexPath.row];
        [self.audioItem removeObjectForKey:[[self.audioItem allKeys] objectAtIndex:indexPath.row]];
        [self.tableView reloadData];
        [self saveData];
        
    }else if(editingStyle == UITableViewCellEditingStyleInsert){
        // Insert時の処理をここに書く
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellIdentifier_%zd_%zd",indexPath.row, indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableDictionary *d =[self.audioItem objectForKey:[[self.audioItem allKeys] objectAtIndex:indexPath.row]];
    
    cell.textLabel.text= [d objectForKey:@"location"];
    cell.detailTextLabel.text=[d objectForKey:@"description"];

    
    
    
    //[self.dataSourceItem objectAtIndex:indexPath.row];

    return cell;
}

@end
