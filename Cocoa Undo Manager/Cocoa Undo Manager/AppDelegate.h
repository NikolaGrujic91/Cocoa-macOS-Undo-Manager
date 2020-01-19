//
//  AppDelegate.h
//  Cocoa Table View
//
//  Created by Nikola Grujic on 14/01/2020.
//  Copyright © 2020 Mac Developers. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FootballClub;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDelegate>
{
    NSMutableArray *footballClubs;
    IBOutlet NSTableView *tableView;    
}

@property (weak) IBOutlet NSWindow *window;

- (IBAction)addClub:(id)sender;
- (IBAction)removeClub:(id)sender;

- (void)insertObject:(FootballClub*) club
inFootballClubsAtIndex: (NSUInteger)index;
- (void)removeObjectFromFootballClubsAtIndex:(NSUInteger)index;

- (void)setTableViewDataSource;
- (void)setTableViewDelegate;
- (void)setColumnsIdentifiers;
- (void)setColumnsSortDescriptors;

- (void)startObservingClub:(FootballClub*) club;
- (void)stopObservingClub:(FootballClub*) club;

- (void)fillTestData;

@end

