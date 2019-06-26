//
//  ManagePageViewController.swift
//  coloringbook
//
//  Created by Iulian Dima on 5/11/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit

class ManagePageViewController: UIPageViewController {

    
    var isTransitionCompleted = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }  
    
    func getVC(_ index: Int) -> CollectionViewController? {
        if let storyboard = storyboard, let page = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            page.categoryIndex = index
            return page
        }
        return nil
    }

    func goToVC(_ viewController: CollectionViewController, navigationDirection: UIPageViewController.NavigationDirection) {
            let viewControllers = [viewController]
            isTransitionCompleted = false
            setViewControllers(viewControllers,
                               direction: navigationDirection,
                               animated: true) { (completion: Bool) in self.isTransitionCompleted = true }
    }
    
}

extension ManagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let collectionViewController = viewController as? CollectionViewController {
            
            var index = collectionViewController.categoryIndex
            if index < (DataManager.sharedInstance.categoriesCount - 1) {
                index += 1
                let newVC = getVC(index)
                //newVC?.collectionView?.contentOffset.y = 200
                return newVC
            }
            return nil
        }
        
        return nil
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let collectionViewController = viewController as? CollectionViewController {
            
            var index = collectionViewController.categoryIndex
            if index > 0 {
                index -= 1
                let newVC = getVC(index)
                //newVC?.collectionView?.contentOffset.y = 200
                return newVC
            }
            return nil
        }
        
        return nil
    }

}


