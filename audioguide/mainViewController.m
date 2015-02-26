//
//  mainViewController.m
//  audioguide
//



#import "mainViewController.h"

@interface mainViewController ()

@property (nonatomic, strong) IBOutlet UIButton *plannerBtn;
@property (nonatomic, strong) IBOutlet UIButton *visitorBtn;


@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.plannerBtn.layer.borderWidth = 2.0;
    self.plannerBtn.layer.masksToBounds = YES;
    self.plannerBtn.layer.cornerRadius = 8.0;
    self.plannerBtn.layer.borderColor = [UIColor colorWithRed:51.0f/255.0f green:76.0f/255.0f blue:155.0f/255.0f alpha:1.0f].CGColor;
    
    self.visitorBtn.layer.borderWidth = 2.0;
    self.visitorBtn.layer.masksToBounds = YES;
    self.visitorBtn.layer.cornerRadius = 8.0;
    self.visitorBtn.layer.borderColor = [UIColor colorWithRed:51.0f/255.0f green:76.0f/255.0f blue:155.0f/255.0f alpha:1.0f].CGColor;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
