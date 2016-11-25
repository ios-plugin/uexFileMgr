/**
 *
 *	@file   	: EUExFileMgr.h  in EUExFileMgr
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/6/2.
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
 
#import <Foundation/Foundation.h>

#define F_FILE_EXPLORER_PATH		@"fileExplorerPath"
#define F_FILE_OPEN_MODE_READ		0x1
#define F_FILE_OPEN_MODE_WRITE		0x2
#define F_FILE_OPEN_MODE_NEW		0x4
#define F_FILE_OPEN_MODE_CREADER    0x8

#define F_FILE_WRITE_MODE_RESTORE	0x0
#define F_FILE_WRITE_MODE_APPEND	0x1

#define F_TYPE_FILE			0
#define F_TYPE_DIR			1

#define F_FILE_EXIST		0
#define F_FILE_NOT_EXIST	1

@interface EUExFileMgr : EUExBase

@end
