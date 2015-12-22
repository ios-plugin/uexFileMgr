//
//  FileSelectorViewController.m
//  Finder
//
//  Created by AppCan  on 11-2-25.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "FileSelectorViewController.h"
#import "EUtility.h"
#import "FileExplorerItem.h"
#import "File.h"


@implementation FileSelectorViewController

@synthesize fileItemArray,currentPath;
@synthesize delegate,headView,fTableView,headLabel,stringssss;

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
		[fileItem release];
	}

	self.fileItemArray = items;
	[items release];
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
        stringssss=[[NSMutableString alloc]initWithString:relpath];
        NSLog(@"path==%@",relpath);
		[self loadData:relpath];
	}
	return self;
}

-(void)cancelClicked{
	if(delegate!=nil && [delegate respondsToSelector: @selector(fileSelectCancled:)] == YES){			
		[delegate fileSelectCancled:self];		
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *cancleButton = [[[UIBarButtonItem alloc]
									  initWithTitle:UEX_LOCALIZEDSTRING(@"取消")
									  style:UIBarButtonItemStylePlain 
									  target:self
									  action:@selector(cancelClicked)
									  ]autorelease];
	self.navigationItem.rightBarButtonItem = cancleButton;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:UEX_LOCALIZEDSTRING(@"返回") style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick)]autorelease];
    self.navigationItem.title = UEX_LOCALIZEDSTRING(@"文件浏览器");
    

//	 if ([UIApplication sharedApplication].statusBarHidden) {
//		 headView = [[UIView alloc] initWithFrame:CGRectMake(0,44, [EUtility screenWidth], 20)];
//	 }else {
//		 headView = [[UIView alloc] initWithFrame:CGRectMake(0,64, [EUtility screenWidth], 20)];
//	 }

//	headLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, [EUtility screenWidth], 16)];
//	[headLabel setBackgroundColor:[UIColor clearColor]];
//	[headView addSubview:headLabel];
//	[self.navigationController.view  addSubview:headView];
    CGRect rect;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (__IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_7_0) {
//        [headView setBackgroundColor:[UIColor whiteColor]];
        rect = CGRectMake(0,0, screenRect.size.width, screenRect.size.height-20);
    }else{
//        [headView setBackgroundColor:[UIColor colorWithRed:147/255.0 green:147/255.0 blue:147/255.0 alpha:1.0]];
        rect =CGRectMake(0,20, [EUtility screenWidth], [EUtility screenHeight]-64);
//      	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    }
    
//    NSLog(@"%@", NSStringFromCGRect(rect));
	fTableView = [[UITableView alloc] initWithFrame:rect];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
		[itemImageView release];
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 240, 20)];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		nameLabel.text = item.fileName;
		[cell.contentView addSubview:nameLabel];
		[nameLabel release];
		if ([item.itemType intValue]==1) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if ([item.itemType intValue]==0) {
			UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, 100, 15)];
			[sizeLabel setBackgroundColor:[UIColor clearColor]];
			[sizeLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
			[sizeLabel setText:[NSString stringWithFormat:@"%.2f kB",[item.fileSize intValue]/1024.0]];
			[cell.contentView addSubview:sizeLabel];
			[sizeLabel release];
		}
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 35, 120, 15)];
		[timeLabel setBackgroundColor:[UIColor clearColor]];
		[timeLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
		[timeLabel setText:item.fileCreateTime];
		[cell.contentView addSubview:timeLabel];
		[timeLabel release];
		
	}		
    return cell;
}
-(void)backBtnClick{
    
    NSLog(@"点击返回+++++++++++++");
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths firstObject];
//    NSString * string = NSHomeDirectory();
//    NSString * AccessPath = [documentsDirectory stringByAppendingString:@"/Documents"];
//    NSLog(@"currentPath:++++%@    AccessPath:++++%@",currentPath,str);
    
    if ([currentPath isEqualToString:[[NSMutableString alloc]initWithString:stringssss]]) {
		[self.navigationItem.leftBarButtonItem setEnabled:NO];
        NSLog(@"当前页面路径和所获取路径相同++++++++++++++++++++");
        if(delegate!=nil && [delegate respondsToSelector: @selector(fileSelectCancled:)] == YES){
            [delegate fileSelectCancled:self];
        }
        
		return;
	}
    NSLog(@"当前页面路径和所获取路径不不不不不相同++++++++++++++++++++++++");
	[currentPath setString:[currentPath stringByDeletingLastPathComponent]];
 	[self loadData:currentPath];
 
	[self.fTableView reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   int row = [indexPath row];
	FileExplorerItem *item = [fileItemArray objectAtIndex:row];
 
	NSString *fileName = item.fileName;
	[currentPath setString:[currentPath stringByAppendingPathComponent:fileName]];
	PluginLog(@"current path = %@",currentPath);
	if ([item.itemType intValue]==1&&[item.subItems count]==0) {
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
		if(delegate!=nil && [delegate respondsToSelector: @selector(fileSelectEnded:)] == YES){			
			[delegate fileSelectEnded:currentPath];		
		}		
		[self dismissModalViewControllerAnimated:YES];	
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
	
	[fileItemArray release];
	[currentPath release];
    [super dealloc];
}


@end

