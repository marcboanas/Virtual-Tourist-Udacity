//
//  CoreDataCollectionViewController.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    var insertIndexPaths: [IndexPath]!
    
    var updateIndexPaths: [IndexPath]!
    
    var deleteIndexPaths: [IndexPath]!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            
            // Wheever the fetched-results-controller changes, we execute the search and reload the collection
            
            fetchedResultsController?.delegate = self
            
            executeSearch()
            
            collectionView?.reloadData()
        }
    }
    
    // MARK: Initializers
    
    init(fetchedResultsController fc: NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewLayout) {
        
        fetchedResultsController = fc
        
        super.init(collectionViewLayout: layout)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        fatalError("This method must be implemented by a subclass of CoreDataCollectionViewController")
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numberOfSections = 0
        
        if let fc = fetchedResultsController {
            
            numberOfSections = (fc.sections?.count)!
            
        } else {
            
            numberOfSections = 0
            
        }
        
        return numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController {
            
            return fc.sections![section].numberOfObjects
            
        } else {
            
            print(0)
            
            return 0
            
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func executeSearch() {
        
        if let fc = fetchedResultsController {
            
            do {
                
                try fc.performFetch()
                
            } catch let e as NSError {
                
                print("Error while trying to perform a search: \(e)")
                
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertIndexPaths = []
        
        updateIndexPaths = []
        
        deleteIndexPaths = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            
            insertIndexPaths.append(newIndexPath!)
            
        case .update:
            
            updateIndexPaths.append(indexPath!)
            
        case .delete:
            
            deleteIndexPaths.append(indexPath!)
            
        default: ()
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            
            for indexPath in self.insertIndexPaths {
                
                self.collectionView?.insertItems(at: [indexPath])
                
            }
            
            for indexPath in self.updateIndexPaths {
                
                self.collectionView?.reloadItems(at: [indexPath])
                
            }
            for indexPath in self.deleteIndexPaths {
                
                self.collectionView?.deleteItems(at: [indexPath])
                
            }
            
        }, completion: nil)
        
    }
}
