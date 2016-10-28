//
//  PoeViewController.m
//  Poe
//
//  Created by lanou on 16/10/26.
//  Copyright © 2016年 lanou. All rights reserved.
//

#import "PoeViewController.h"
#import "PoeModel.h"
#import "PoeTool.h"
#import <stdlib.h>


@interface PoeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleT;

@property (weak, nonatomic) IBOutlet UILabel *authorT;

@property (weak, nonatomic) IBOutlet UIButton *collBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) PoeModel *model;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) BOOL isCollected;

@end

@implementation PoeViewController

-(void)loadData {
    
    NSLog(@"TMD,CNM");
    
    self.model = [[PoeModel alloc] init];
    
    int arc = arc4random()%(92-1+1)+1;

    NSLog(@"%d",arc);
    
    NSString *str=[NSString stringWithFormat:@"http://bubo.in/poe/poem?s=%d",arc];
    
    //生成Url
    NSURL *url = [NSURL URLWithString:str];
    
    //创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    
    //创建任务
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            for (NSDictionary *dic in arr) {
                [self.model setValuesForKeysWithDictionary:dic];
                self.dataArray = [self.model.content componentsSeparatedByString:@"|^n|"];
                }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *arr = [PoeTool searchPoe:self.model.poe_id];
                if (arr.count == 0) {
                    [self.collBtn setBackgroundImage:[UIImage imageNamed:@"未收藏.png"] forState:UIControlStateNormal];
                    self.isCollected = NO;
                }
                else
                {
                    [self.collBtn setBackgroundImage:[UIImage imageNamed:@"已收藏.png"] forState:UIControlStateNormal];
                    self.isCollected = YES;
                }
                self.tableView.contentOffset = CGPointMake(0,0);
                [self.tableView reloadData];
                self.titleT.text = self.model.title;
                self.authorT.text = self.model.artist;
            });
        }
        else {
            NSLog(@"error = %@",error);
        }
        
    }];
    [task resume];
    
}

-(void)initView {
    
    self.dataArray = [[NSArray alloc] init];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
    
    self.titleT.textColor = [UIColor colorWithWhite:0.550 alpha:1.000];
    self.authorT.textColor = [UIColor colorWithWhite:0.550 alpha:1.000];
    
    [self.collBtn setBackgroundImage:[UIImage imageNamed:@"未收藏.png"] forState:UIControlStateNormal];
    [self.collBtn addTarget:self action:@selector(collAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

}

-(void)initTimer {
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self loadData];
    
    [self initTimer];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count+13;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (indexPath.row>=4&&indexPath.row<=self.dataArray.count+3) {
        cell.textLabel.text = self.dataArray[indexPath.row-4];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor colorWithWhite:0.550 alpha:1.000];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else cell.textLabel.text = nil;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshAction {
    self.isCollected = NO;
    [self loadData];
}

-(void)timerAction {
    
    self.tableView.contentOffset = CGPointMake(0,self.tableView.contentOffset.y+1);
    
    CGFloat x = (self.dataArray.count+13)*50 - self.tableView.bounds.size.height;

    if (self.tableView.contentOffset.y >= x) {
        self.tableView.contentOffset = CGPointMake(0,0);
    }
}


-(void)collAction {
    
    
    if (!self.isCollected) {
        [PoeTool addPoe:self.model];
        [self.collBtn setBackgroundImage:[UIImage imageNamed:@"已收藏.png"] forState:UIControlStateNormal];
        self.isCollected = YES;
    }
    else
    {
        [PoeTool deletePoe:self.model];
        [self.collBtn setBackgroundImage:[UIImage imageNamed:@"未收藏.png"] forState:UIControlStateNormal];
        self.isCollected = NO;
    }
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
