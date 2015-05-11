//
//  FileListViewController.m
//  ABMutilChoose
//
//  Created by AppCan on 12-5-31.
//  Copyright 2012 AppCan. All rights reserved.
//
#import "FileListViewController.h"
#import "JSON.h"
@implementation FileListViewController
@synthesize table;
@synthesize fileArray;
@synthesize pathArray;
@synthesize selectFiles;
@synthesize filesType;
@synthesize selectAllPaths;
@synthesize rootPath;
@synthesize indexpath;
@synthesize toolBar;
@synthesize callBack;

enum fileType {
	Unknow_Type,
	Directory_Type,
	EmptyDirectory_Type,
	Document_type,
	Image_Type,
	Music_Type,
	Video_Type,
	Zip_Type,
	Txt_Type,
	Pdf_Type,
	Ppt_Type,
	Xls_Type
};

-(UIImage*)scaleToSize:(UIImage*)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
#pragma mark -
#pragma mark init data
-(void)initSelectAllPaths{
	self.selectAllPaths = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
}
-(void)updateToolbarConfirmButton{
	NSInteger count = 0;
	if (selectAllPaths) {
		count = [[selectAllPaths allKeys] count];
	}
	UIBarButtonItem* confirmBarItem = [[self.toolBar items] lastObject];
	confirmBarItem.title = [NSString stringWithFormat:@"确定(%d)",count];
}
-(void)initFilesType{
	if (fileArray && indexpath) {
		NSInteger count = [fileArray count];
		self.filesType = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for (NSInteger i = 0; i < count;i++) {
			NSString *file = (NSString*)[fileArray objectAtIndex: i];
			NSString *path = [indexpath stringByAppendingPathComponent:file];
			BOOL isDir;
			if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir)
			{
				NSArray* subPath = [[NSFileManager defaultManager] subpathsAtPath:path];
				if (subPath && subPath.count > 0) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Directory_Type] atIndex:i];
				}else {
					[filesType insertObject:[NSString stringWithFormat:@"%d",EmptyDirectory_Type] atIndex:i];
				}
			}
			else{
				NSString *smallName = [file lowercaseString];
				if ([smallName hasSuffix:@"jpg"]||[smallName hasSuffix:@"jpeg"]||[smallName hasSuffix:@"png"]||[smallName hasSuffix:@"gif"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Image_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"mov"]||[smallName hasSuffix:@"mp4"]||[smallName hasSuffix:@"avi"]||[smallName hasSuffix:@"3gp"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Video_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"mp3"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Music_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"zip"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Zip_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"txt"]){
					[filesType insertObject:[NSString stringWithFormat:@"%d",Txt_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"pdf"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Pdf_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"doc"]||[smallName hasSuffix:@"docx"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Document_type] atIndex:i];
				}else if ([smallName hasSuffix:@"ppt"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Ppt_Type] atIndex:i];
				}else if ([smallName hasSuffix:@"xls"]) {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Xls_Type] atIndex:i];
				}else {
					[filesType insertObject:[NSString stringWithFormat:@"%d",Unknow_Type] atIndex:i];
				}
			}
		}
	}
}
-(void)initSelectFiles:(NSString*)value{
	if (fileArray && indexpath) {
		NSInteger count = [fileArray count];
		selectFiles = [[NSMutableArray alloc] initWithCapacity:count];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for (NSInteger i = 0; i < count;i++) {
			NSString *file = (NSString*)[fileArray objectAtIndex: i];
			NSString *path = [indexpath stringByAppendingPathComponent:file];
			//判断是否是为目录
			BOOL isDir;
			if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir)
			{//目录
				[selectFiles insertObject:@"2" atIndex:i];
			}
			else
			{//文件
				[selectFiles insertObject:value atIndex:i];
			}
		}
	}
}

-(void)initFileList{
	if (self.rootPath == nil) {
		self.rootPath = NSHomeDirectory();
		self.pathArray = [[[NSMutableArray alloc] init] autorelease];
        //		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //		self.rootPath = [documentPaths objectAtIndex:0];
        //		root = TRUE;
	}
	NSString* tempPath = rootPath;
	NSInteger count = 0;
	if (pathArray) {
		count = pathArray.count;
	}
	for (NSInteger i = 0; i < count; i++) {
		tempPath = [tempPath stringByAppendingFormat:@"/%@",[pathArray objectAtIndex:i]];
	}
	self.indexpath = tempPath;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    self.fileArray =[NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:indexpath error:nil]];
//	self.fileArray = [fileManager directoryContentsAtPath:indexpath];
	[self initSelectFiles:@"0"];
	[self initFilesType];
    //	[self initTitleBar];
    //	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //	NSString *documentDir = [documentPaths objectAtIndex:0];
	
    //	NSString *myDirectory = [documentDir stringByAppendingPathComponent:@"test2/"];
    //	BOOL ok = [fileManager createDirectoryAtPath:myDirectory attributes:nil];
    //	NSString *filePath= [myDirectory stringByAppendingPathComponent:@"file5.txt"];
    //	//需要写入的字符串
    //	NSString *str= @"iPhoneDeveloper Tips\nhttp://iPhoneDevelopTips,com";
    //	//写入文件
    //	[str writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //	[fileManager createFileAtPath:[documentDir stringByAppendingPathComponent:@"file6.txt"] contents:@"hello" attributes:nil];
	
    //	NSError *error = nil;
    //	NSArray *fileList = [[NSArray alloc] init];
    //	fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
}
#pragma mark -
#pragma mark init UIToolBar
-(void)doCallBack:(NSString*)jsonString{
	if (callBack) {
		[callBack jsSuccessWithName:@"uexFileMgr.cbMultiExplorer" opId:0 dataType:1 strData:jsonString];
	}
}

-(void)confirmButtonClick{
    //	if (selectFiles && fileArray && indexpath) {
    //		NSMutableArray* array = [[NSMutableArray alloc] init];
    //		NSInteger count = [selectFiles count];
    //		for (NSInteger i = 0; i < count; i++) {
    //			NSString* flagStr = [selectFiles objectAtIndex:i];
    //			NSInteger flag = flagStr ? [flagStr intValue]:0;
    //			if (flag == 1) {
    //				[array addObject:[indexpath stringByAppendingFormat:@"/%@",[fileArray objectAtIndex:i]]];
    //			}
    //		}
	if (selectAllPaths) {
		NSArray* array = [selectAllPaths allValues];
		NSString* pjson = [array JSONRepresentation];
		[self doCallBack:pjson];
	}
	[self dismissModalViewControllerAnimated:YES];
}
-(void)allSelectButtonClick{
    //	indexSelects = [fileArray count];
	[self initSelectFiles:@"1"];
	[table reloadData];
	if (fileArray) {
		NSInteger count = [fileArray count];
		for (NSInteger i = 0; i < count; i++) {
			if ([[selectFiles objectAtIndex:i] intValue] == 2) {
				continue;
			}
			NSString* key = [NSString stringWithFormat:@"%@X%d)",indexpath,i];
			[selectAllPaths setObject:[indexpath stringByAppendingPathComponent:[fileArray objectAtIndex:i]] forKey:key];
		}
		[self updateToolbarConfirmButton];
	}
}
-(void)CancelAllSelectButtonClick{
    //	indexSelects = 0;
	[self initSelectFiles:@"0"];
	[table reloadData];
	if (fileArray) {
		NSInteger count = [fileArray count];
		for (NSInteger i = 0; i < count; i++) {
			if ([[selectFiles objectAtIndex:i] intValue] == 2) {
				continue;
			}
			NSString* key = [NSString stringWithFormat:@"%@X%d)",indexpath,i];
			[selectAllPaths removeObjectForKey:key];
		}
		[self updateToolbarConfirmButton];
	}
}
-(void)nullButtonClick{
}

-(void)initToolbar{
	//CGFloat width =  self.view.frame.size.width;
	CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat height = 0.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0) {
        height = 108;
    }else{
        height = 40;
    }
	self.toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, size.height-height, size.width, 40)] autorelease];
	toolBar.backgroundColor = [UIColor clearColor];
    toolBar.barStyle = UIBarButtonItemStyleBordered;
	//	toolBar.barStyle = UIBarButtonItemStylePlain;
	[toolBar sizeToFit];
	toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;//这句作用是切换时宽度自适应.
    
	UIBarButtonItem* allSelectBarItem = [[[UIBarButtonItem alloc] init] autorelease];
    [allSelectBarItem setTitle:@"全选"];
    [allSelectBarItem setStyle:UIBarButtonItemStyleBordered];
    [allSelectBarItem setTarget:self];
    [allSelectBarItem setAction:@selector(allSelectButtonClick)];
    
	UIBarButtonItem* cancelSelectBarItem = [[[UIBarButtonItem alloc] init] autorelease];
    [cancelSelectBarItem setTitle:@"取消全选"];
    [cancelSelectBarItem setStyle:UIBarButtonItemStyleBordered];
    [cancelSelectBarItem setTarget:self];
    [cancelSelectBarItem setAction:@selector(CancelAllSelectButtonClick)];
    
	UIBarButtonItem* confirmBarItem = [[[UIBarButtonItem alloc] init] autorelease];
    [confirmBarItem setTitle:[NSString stringWithFormat:@"确定(%d)",0]];
    [confirmBarItem setStyle:UIBarButtonItemStyleBordered];
    [confirmBarItem setTarget:self];
    [confirmBarItem setAction:@selector(confirmButtonClick)];
    
	UIBarButtonItem* barItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(nullButtonClick)] autorelease];
//    [barItem setTitle:[NSString stringWithFormat:@"确定(%d)",0]];
//    [barItem setStyle:UIBarButtonSystemItemFlexibleSpace];
//    [barItem setTarget:self];
//    [barItem setAction:@selector(nullButtonClick)];
    
	[toolBar setItems:[NSArray arrayWithObjects:allSelectBarItem,barItem,cancelSelectBarItem,barItem,confirmBarItem,nil]];
	[self.view addSubview:toolBar];
}

#pragma mark -
#pragma mark Init TitleBar
-(void)rightButtonClick:(id)sender{
	UIBarButtonItem* rightItemButton = (UIBarButtonItem*)sender;
    NSString *title = rightItemButton.title;
	if ([title isEqualToString:@"编辑"]) {
		rightItemButton.title = @"取消";
		isEditableOrNot = 1;
		[table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].applicationFrame.size.width,40)] autorelease]];
		[self initToolbar];
	}else {
		rightItemButton.title = @"编辑";
		isEditableOrNot = 0;
		[toolBar removeFromSuperview];
		[table setTableFooterView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
		[table reloadData];
	}
	[self initSelectAllPaths];
}

- (IBAction)backBtnClicked{
    //	if(root == TRUE)
    //	{
    //		[self dismissModalViewControllerAnimated:YES];
    //	}else {
    //		[self.navigationController popViewControllerAnimated:YES];
    //	}
	if (pathArray.count <= 0) {
        //		[self.navigationItem.leftBarButtonItem setStyle:UIControlStateDisabled];
		[self dismissModalViewControllerAnimated:YES];
	}else {
		[pathArray removeLastObject];
		[self initFileList];
		[table reloadData];
	}
}

- (void)initTitleBar{
	UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.opaque = NO;
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.highlightedTextColor = [UIColor blackColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:18];
	titleLabel.frame = CGRectMake(0.0, 0.0,160, 22.0);
	titleLabel.text = @"文件浏览器";
	titleLabel.textAlignment = UITextAlignmentCenter;
	self.navigationItem.titleView = titleLabel;
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnClicked)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClick:)] autorelease];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}
#pragma mark -
#pragma mark View lifecycle
- (id)initWithPath:(NSString*)path{
	self = [super init];
	if (self) {
		self.rootPath = path;
	}
	return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat y = 0.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0) {
        
    }else{
        y = 44+20;
    }
	self.view.backgroundColor = [UIColor redColor];
	table = [[UITableView alloc]initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
	table.delegate = self;
	table.dataSource = self;
	[self.view addSubview:table];
	[self initFileList];
	[self initTitleBar];
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [fileArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSInteger row = [indexPath row];
	NSString* name = [fileArray objectAtIndex:row];
	cell.textLabel.text = name;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	NSInteger flag = 0;
	if(selectFiles)
	{
		NSString* flagStr = [selectFiles objectAtIndex:row];
		flag = flagStr ? [flagStr intValue]:0;
	}
	if (flag == 2) {
		cell.accessoryView = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		if (isEditableOrNot && flag == 0) {
			NSString* key = [NSString stringWithFormat:@"%@X%d)",indexpath,row];
			NSString* value = [selectAllPaths objectForKey:key];
			if (value) {
				[selectFiles replaceObjectAtIndex:row withObject:@"1"];
				flag = 1;
			}
		}
		if(isEditableOrNot && flag == 1) {
			UIImage *image = [UIImage imageNamed:@"uexFileMgr/plugin_file_Selected.png"];
			UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
			cell.accessoryView = imageView;
            [imageView release];
		}else {
			cell.accessoryView = nil;
		}
	}
	if(filesType)
	{
		NSString* filetype = [filesType objectAtIndex:row];
		NSInteger typevalue = [filetype intValue];
		switch (typevalue) {
			case Directory_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_folder.png"];
			}
				break;
			case EmptyDirectory_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_emptyfolder.png"];
			}
				break;
			case Image_Type:
			{
				NSString* filename = [indexpath stringByAppendingPathComponent:name];
				cell.imageView.image = [self scaleToSize:[UIImage imageWithContentsOfFile:filename] size:CGSizeMake(50, 50)];
			}
				break;
			case Document_type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_doc.png"];
			}
				break;
			case Music_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_music.png"];
			}
				break;
			case Video_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_video.png"];
			}
				break;
			case Zip_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_zip.png"];
			}
				break;
			case Txt_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_txt.png"];
			}
				break;
			case Pdf_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_pdf.png"];
			}
				break;
			case Ppt_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_ppt.png"];
			}
				break;
			case Xls_Type:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_excel.png"];
			}
				break;
			default:
			{
				cell.imageView.image = [UIImage imageNamed:@"uexFileMgr/plugin_file_unknown.png"];
			}
				break;
		}
	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = [indexPath row];
	if (selectFiles) {
		NSString* flagStr = [selectFiles objectAtIndex:row];
		NSInteger flag = flagStr ? [flagStr intValue]:0;
		if(isEditableOrNot) {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			NSString* key = [NSString stringWithFormat:@"%@X%d)",indexpath,row];
			if (flag == 1) {
				cell.accessoryView = nil;
				[selectFiles replaceObjectAtIndex:row withObject:@"0"];
				[selectAllPaths removeObjectForKey:key];
			}
			else if(flag == 0){
				UIImage *image = [UIImage imageNamed:@"uexFileMgr/plugin_file_Selected.png"];
				UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
				cell.accessoryView = imageView;
                [imageView release];
				[selectFiles replaceObjectAtIndex:row withObject:@"1"];
				[selectAllPaths setObject:[indexpath stringByAppendingPathComponent:[fileArray objectAtIndex:row]] forKey:key];
			}
		}
		if(flag == 2){
            //				FileListViewController *fileController = [[FileListViewController alloc] initWithPath:[rootPath stringByAppendingPathComponent:[fileArray objectAtIndex:row]]];
            //				fileController.callBack = self.callBack;
            //				[self.navigationController pushViewController:fileController animated:YES];
            //				[fileController release];
			NSString* filetype = [filesType objectAtIndex:row];
			NSInteger typevalue = [filetype intValue];
			if (typevalue == Directory_Type) {
				[pathArray addObject:[fileArray objectAtIndex:row]];
				[self initFileList];
				[self.table reloadData];
			}
		}
	}
	[self updateToolbarConfirmButton];
}

//设置rowHeight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

#pragma mark -//转动屏幕
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //先判断转屏是否有效
    if (UIDeviceOrientationIsValidInterfaceOrientation(toInterfaceOrientation)) {
        //参数表示是否横屏，这里我只需要知道屏幕方向就可以提前知道目标区域了！
        [self setCtrlPos: UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ];
    
        
    }
}
//这个用来实现窗口空间大小位置调整

-(void)setCtrlPos:(BOOL)isHorz

{
    
    CGRect rcClient = getClientRect( isHorz );
    table.frame = rcClient;
    //其他控件根据这个rcClient.view来调整位置大小
    
}

CGRect getClientRect( BOOL isHorz)
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

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[table release];
	[fileArray release];
	[pathArray release];
	[selectFiles release];
	[filesType release];
	[selectAllPaths release];
	[rootPath release];
	[indexpath release];
	[toolBar release];
	[callBack release];
    [super dealloc];
}
@end
