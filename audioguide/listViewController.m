//
//  listViewController.m
//  audioguide
//



#import "listViewController.h"
#import "noteViewController.h"
#import "defines.h"

@interface listViewController() <MFMailComposeViewControllerDelegate,UITableViewDelegate, UITableViewDataSource> {
    UIBarButtonItem *exportBarButton;
    NSInteger selectedRow;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *audioItem;

@property (nonatomic, strong) NSMutableArray *dataSourceItem;
@property (nonatomic, strong) NSMutableArray *dataSourceIndex;
@end


@implementation listViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    exportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export)];
    self.navigationItem.rightBarButtonItem = exportBarButton;
    
    selectedRow=-1;
}

- (void)export {
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.audioItem options:0 error:nil];
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    
    [controller addAttachmentData:jsonData mimeType:@"text/plain" fileName:@"audio.json"];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}
- ( void )mailComposeController:( MFMailComposeViewController* )controller didFinishWithResult:( MFMailComposeResult )result error:( NSError* )error {
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
        [self.audioItem removeObjectForKey:[[self.audioItem allKeys] objectAtIndex:indexPath.row]];
        [self.tableView reloadData];
        [self saveData];
        
    }else if(editingStyle == UITableViewCellEditingStyleInsert){

    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellIdentifier_%zd_%zd",indexPath.row, indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSMutableDictionary *d =[self.audioItem objectForKey:[[self.audioItem allKeys] objectAtIndex:indexPath.row]];
    
    cell.textLabel.text= [d objectForKey:@"location"];
    cell.detailTextLabel.text=[d objectForKey:@"description"];
    

    return cell;
}

@end
