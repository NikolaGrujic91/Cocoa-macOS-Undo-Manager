//
//  AppDelegate.m
//  Cocoa Table View
//
//  Created by Nikola Grujic on 14/01/2020.
//  Copyright © 2020 Mac Developers. All rights reserved.
//

#import "AppDelegate.h"
#import "FootballClub.h"

@implementation AppDelegate

- (id)init
{
    self = [super init];
    
    if (self)
    {
        footballClubs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self setTableViewDataSource];
    [self setTableViewDelegate];
    [self setColumnsIdentifiers];
    [self setColumnsSortDescriptors];
    
    [self fillTestData];
}

#pragma mark Table view dataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [footballClubs count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(NSInteger)row
{
    NSString *columnIdentifier = [tableColumn identifier];
    FootballClub *club = [footballClubs objectAtIndex:row];
    
    return [club valueForKey:columnIdentifier];
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    FootballClub *club = [footballClubs objectAtIndex:row];
    [club setValue:object forKey:identifier];
}

#pragma mark Table view sortDescriptor methods

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [footballClubs sortUsingDescriptors:[aTableView sortDescriptors]];
    [aTableView reloadData];
}

#pragma mark Cell edit undo methods

- (void)changeKeyPath:(NSString*) keyPath
             ofObject:(id)obj
              toValue:(id)newValue
{
    [obj setValue:newValue forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if (context != &WindowKVOContext)
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    
    if (oldValue == [NSNull null])
    {
        oldValue = nil;
    }
    
    NSUndoManager *undoManager = [_window undoManager];
    [[undoManager prepareWithInvocationTarget:self] changeKeyPath:keyPath
                                                         ofObject:object
                                                          toValue:oldValue];
    [undoManager setActionName:@"Edit"];
}

#pragma mark Action methods

- (IBAction)addClub:(id)sender
{
    FootballClub *club = [[FootballClub alloc] init];
    NSUInteger index = [footballClubs count];
    [self insertObject:club inFootballClubsAtIndex: index];
    [tableView editColumn:0 row:index withEvent:nil select:YES];
}

- (IBAction)removeClub:(id)sender
{
    NSIndexSet *indexes = [tableView selectedRowIndexes];
    
    if ([indexes count] == 0)
    {
        return;
    }
    
    NSUInteger currentIndex = [indexes firstIndex];
    while (currentIndex != NSNotFound)
    {
        [self removeObjectFromFootballClubsAtIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex: currentIndex];
    }
}

#pragma mark Undo manager methods

- (void)insertObject:(FootballClub*) club
inFootballClubsAtIndex: (NSUInteger)index
{
    NSUndoManager *undoManager = [_window undoManager];
    [[undoManager prepareWithInvocationTarget:self] removeObjectFromFootballClubsAtIndex:index];
    
    if (![undoManager isUndoing])
    {
        [undoManager setActionName:@"Add football club"];
    }
    
    [self startObservingClub:club];
    [footballClubs insertObject:club atIndex:index];
    [tableView reloadData];
}

- (void)removeObjectFromFootballClubsAtIndex:(NSUInteger)index
{
    FootballClub *club = [footballClubs objectAtIndex:index];
    
    NSUndoManager *undoManager = [_window undoManager];
    [[undoManager prepareWithInvocationTarget:self] insertObject:club inFootballClubsAtIndex:index];
    
    if (![undoManager isUndoing])
    {
        [undoManager setActionName:@"Remove club"];
    }
    
    [self stopObservingClub:club];
    [footballClubs removeObjectAtIndex:index];
    [tableView reloadData];
}

#pragma mark Additional methods

- (void)setTableViewDataSource
{
    [tableView setDataSource: (id)self];
}

- (void)setTableViewDelegate
{
    [tableView setDelegate:self];
}

- (void)setColumnsIdentifiers
{
    NSArray<NSTableColumn*> *columns = [tableView tableColumns];
    int firstColumn = 0;
    int secondColumn = 1;
    
    for (int i = 0; i < [columns count]; i++)
    {
        NSTableColumn *column = [columns objectAtIndex:i];
        
        if (i == firstColumn)
        {
            [column setIdentifier:@"name"];
        }
        else if (i == secondColumn)
        {
            [column setIdentifier:@"foundationYear"];
        }
    }
}

- (void)setColumnsSortDescriptors
{
    NSArray<NSTableColumn*> *columns = [tableView tableColumns];
    
    for (int i = 0; i < [columns count]; i++)
    {
        NSTableColumn *column = [columns objectAtIndex:i];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[column identifier]
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        [column setSortDescriptorPrototype:sortDescriptor];
    }
}

static void *WindowKVOContext;

- (void)startObservingClub:(FootballClub*) club
{
    [club addObserver:self
           forKeyPath:@"name"
              options:NSKeyValueObservingOptionOld
              context:&WindowKVOContext];
    
    [club addObserver:self
           forKeyPath:@"foundationYear"
              options:NSKeyValueObservingOptionOld
              context:&WindowKVOContext];
}

- (void)stopObservingClub:(FootballClub*) club
{
    [club removeObserver:self
              forKeyPath:@"name"
                 context:&WindowKVOContext];
    
    [club removeObserver:self
              forKeyPath:@"foundationYear"
                 context:&WindowKVOContext];
}

- (void)fillTestData
{
    FootballClub *club1 = [[FootballClub alloc] init];
    [club1 setName:@"Manchester United"];
    [club1 setFoundationYear:@"1878"];
    
    FootballClub *club2 = [[FootballClub alloc] init];
    [club2 setName:@"Liverpool"];
    [club2 setFoundationYear:@"1892"];
    
    FootballClub *club3 = [[FootballClub alloc] init];
    [club3 setName:@"Real Madrid"];
    [club3 setFoundationYear:@"1902"];
    
    FootballClub *club4 = [[FootballClub alloc] init];
    [club4 setName:@"Barcelona"];
    [club4 setFoundationYear:@"1899"];
    
    [footballClubs addObject:club1];
    [footballClubs addObject:club2];
    [footballClubs addObject:club3];
    [footballClubs addObject:club4];
}

@end
