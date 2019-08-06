//
//  MainHomeViewController.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-05.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit

class MainHomeViewController: AuthViewControllerWithSettings {
    
    @IBOutlet weak var familyNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var members: [MemberModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyNameLabel.text = authModelController.session.familyName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showSpinner(onView: self.view)
        
        MemberModelController.getMembers(view: self, completion: { (results) in
            if results != nil {
                self.members = results!
                self.collectionView.reloadData()
            }
            self.removeSpinner()
        })
    }

//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditMemberSegue" {
            let editMemberViewController = segue.destination as! EditMemberViewController
            
            editMemberViewController.authModelController = authModelController
            
            if let cell = sender as? UICollectionViewCell,
                let indexPath = self.collectionView.indexPath(for: cell) {
                
                editMemberViewController.member = members[indexPath.row]
            }
        }
    }
}


extension MainHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if members.isEmpty {
            return 0
        }
        
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollectionViewCell", for: indexPath) as! MemberCollectionViewCell
        
        cell.memberAvatar.roundedImage()
        
        cell.memberName.text = members[indexPath.row].name
        if members[indexPath.row].avatar != nil {
            cell.memberAvatar.image = members[indexPath.row].avatar
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(members[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 156, height: 218)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidthPadding = collectionView.frame.size.width - (156 * 2)
        return UIEdgeInsets(top: 0, left: cellWidthPadding / 3, bottom: 0, right: cellWidthPadding / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let cellWidthPadding = collectionView.frame.size.width - (156 * 2)
        return cellWidthPadding / 3
    }
}
