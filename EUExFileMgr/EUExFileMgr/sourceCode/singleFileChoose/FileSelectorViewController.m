//
//  FileSelectorViewController.m
//  Finder
//
//  Created by AppCan  on 11-2-25.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "FileSelectorViewController.h"

#import "FileExplorerItem.h"
#import "File.h"


@implementation FileSelectorViewController

@synthesize fileItemArray,currentPath;
@synthesize headView,fTableView,headLabel;

-(void)loadData:(NSString *)relpath{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	
	//NSString *preDirStr = [relpath stringByDeletingLastPathComponent];
	NSRange range = [relpath rangeOfString:NSHomeDirectory()];
    NSString *subPath = [relpath substringFromIndex:range.length];
	if (subPath) {
		[self.headLabel setText:subPath];
	}
	NSArray *subFiles = [fmanager contentsOfDirectoryAtPath:relpath error:nil];
	[self.currentPath setString:relpath];
	if ([subFiles count]==0) {
		return;
	}
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:10];
	for (NSString *subFileName in subFiles) {
		NSString *subFilePath = [relpath stringByAppendingPathComponent:subFileName];
		FileExplorerItem *fileItem = [[FileExplorerItem alloc] initFileObjectWithPath:subFilePath];
		[items addObject:fileItem];

	}

	self.fileItemArray = items;

}

//init
-(id)initWithRootPath:(NSString *)inPath{
   
	self = [super init];
	if (self != nil) {
		NSString *relpath;
		BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:inPath];
		 if (inPath==nil||[inPath isEqualToString:@""]||isExist==NO) {
			 currentPath =[[NSMutableString alloc]initWithString:[File getDocumentsPath:@""]];
			 relpath = [File getDocumentsPath:@""];
		 }else {
			 currentPath = [[NSMutableString alloc]initWithString:inPath];;
			 relpath = inPath;
		 }
        _chuanRuPath=[[NSMutableString alloc]initWithString:relpath];
		[self loadData:relpath];
	}
	return self;
}

-(void)cancelClicked{
	if(_delegate!=nil && [_delegate respondsToSelector: @selector(fileSelectCancled:)] == YES){
		[_delegate fileSelectCancled:self];		
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc]
									  initWithTitle:UEX_LOCALIZEDSTRING(@"取消")
									  style:UIBarButtonItemStylePlain 
									  target:self
									  action:@selector(cancelClicked)
									  ];
	self.navigationItem.rightBarButtonItem = cancleButton;
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:UEX_LOCALIZEDSTRING(@"返回") style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick)];
    self.navigationItem.title = UEX_LOCALIZEDSTRING(@"文件浏览器");
    



//    NSLog(@"%@", NSStringFromCGRect(rect));
	fTableView = [[UITableView alloc] initWithFrame:self.view.frame];
	[fTableView setDelegate:self];
	[fTableView setDataSource:self];
	[self.view addSubview:fTableView];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([fileItemArray count]==0) {
		return 1;
	}
    return [fileItemArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	if ([fileItemArray count]!=0) {
		//cell.textLabel.text = [[fileItemArray objectAtIndex:row-1] fileName];
		FileExplorerItem *item = [fileItemArray objectAtIndex:row];
        for (UIView *subview in cell.contentView.subviews) {
			[subview removeFromSuperview];
		}
		UIImageView *itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
		[itemImageView setImage:item.fileIcon];
		[cell.contentView addSubview:itemImageView];
	
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 240, 20)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		nameLabel.text = item.fileName;
		[cell.contentView addSubview:nameLabel];

		if ([item.itemType intValue]==1) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if ([item.itemType intValue]==0) {
			UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, 100, 15)];
			[sizeLabel setBackgroundColor:[UIColor clearColor]];
			[sizeLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
			[sizeLabel setText:[NSString stringWithFormat:@"%.2f kB",[item.fileSize intValue]/1024.0]];
			[cell.contentView addSubview:sizeLabel];

		}
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 35, 120, 15)];
		[timeLabel setBackgroundColor:[UIColor clearColor]];
		[timeLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
		[timeLabel setText:item.fileCreateTime];
		[cell.contentView addSubview:timeLabel];

		
	}		
    return cell;
}
-(void)backBtnClick{
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    NSString * string = NSHomeDirectory();
//    NSString * AccessPath = [documentsDirectory stringByAppendingString:@"/Documents"];
//    NSLog(@"currentPath:++++%@    AccessPath:++++%@",currentPath,str);
    
    //如果有问题换成[[NSMutableString alloc]initWithString:chuanRuPath]；
    if ([currentPath isEqualToString:_chuanRuPath]) {
		[self.navigationItem.leftBarButtonItem setEnabled:NO];
        if(_delegate!=nil && [_delegate respondsToSelector: @selector(fileSelectCancled:)]){
            [_delegate fileSelectCancled:self];
        }
        
		return;
	}
	[currentPath setString:[currentPath stringByDeletingLastPathComponent]];
 	[self loadData:currentPath];
	[self.fTableView reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   NSInteger row = [indexPath row];
	FileExplorerItem *item = [fileItemArray objectAtIndex:row];
 
	NSString *fileName = item.fileName;
	[currentPath setString:[currentPath stringByAppendingPathComponent:fileName]];
	if ([item.itemType intValue] == 1 && [item.subItems count] == 0) {
		[currentPath setString:[currentPath stringByDeletingLastPathComponent]];
		return;
	}
	//FileExplorerItem *nextItem = [[FileExplorerItem alloc] initFileObjectWithPath:currentPath];
   
	if (  [File fileisDirectoy:currentPath] == 1) {
		//dir
		[self loadData:currentPath];
		if (![currentPath isEqualToString:NSHomeDirectory()]) {
			[self.navigationItem.leftBarButtonItem setEnabled:YES];
		}
		[self.fTableView reloadData];
	}else {
		//file
		if(_delegate!=nil && [_delegate respondsToSelector: @selector(fileSelectEnded:)]){
			[_delegate fileSelectEnded:currentPath];		
		}
	}
}

#pragma mark -//转动屏幕
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //先判断转屏是否有效
    if (UIDeviceOrientationIsValidInterfaceOrientation(toInterfaceOrientation)) {
        //参数表示是否横屏，这里我只需要知道屏幕方向就可以提前知道目标区域了！
        [self setCtrlPos: UIInterfaceOrientationIsLandscape( toInterfaceOrientation) ];
    }
}
//这个用来实现窗口空间大小位置调整

-(void)setCtrlPos:(BOOL)isHorz

{
    
//    CGRect rcClient = getFrameRect( isHorz );
    CGRect rcClient = [self getFrameRect:isHorz];

    fTableView.frame = rcClient;
    //其他控件根据这个rcClient.view来调整位置大小
    
}



//CGRect getFrameRect( BOOL isHorz)
-(CGRect)getFrameRect:( BOOL )isHorz
{
    BOOL isStatusBarHidden = [[ UIApplication sharedApplication ]isStatusBarHidden ];//判断屏幕顶部有没状态栏出现
    CGRect rcScreen = [[UIScreen mainScreen] bounds];//这个不会随着屏幕旋转而改变
    int status_height = isStatusBarHidden ? 0 :20;
    CGRect rcClient = rcScreen;
    
    if ([[UIDevice  currentDevice].systemVersion  floatValue] < 7.0) {
        if( isHorz )
        {
            rcClient.size.width -= status_height;//20
        }
        else
        {
            rcClient.size.height -= status_height;//20
        }
    }
    
    
    CGRect rcArea = rcClient;
    if( isHorz )
    {
        rcArea.size.width = MAX(rcClient.size.width,rcClient.size.height);
        rcArea.size.height = MIN(rcClient.size.width,rcClient.size.height);
    }else{
        rcArea.size.width   = MIN(rcClient.size.width,rcClient.size.height);
        rcArea.size.height = MAX(rcClient.size.width,rcClient.size.height);
    }
    return rcArea;
}


- (void)dealloc {

}


@end

