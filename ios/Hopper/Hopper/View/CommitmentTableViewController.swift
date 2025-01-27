//
//  CommitmentTableViewController.swift
//  iOSProver
//
//  Created by Olivier van den Biggelaar on 18/02/2019.
//  Copyright © 2019 Olivier van den Biggelaar. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CommitmentTableViewController : FetchedResultsTableViewController {
    
    private struct Storyboard {
        static let rowHeight: CGFloat = 110
        static let commitmentCell = "Commitment Cell"
        static let showMixerAddressSegue = "Show Mixer Address"
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Commitment>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = Storyboard.rowHeight
        tableView.rowHeight = Storyboard.rowHeight
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(segueToGainsLossesDetails(_:)),
                                               name: .segueToMixerAddress,
                                               object: nil)
        
        updateUI()
    }
    
    private func updateUI() {
        
        // fetch request
        let request: NSFetchRequest<Commitment> = Commitment.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController?.delegate = self
        do { try fetchedResultsController?.performFetch() }
        catch { NSLog("CommitmentTableViewController Error: fetchedResultsController failed to performFetch: \(error.localizedDescription)") }
    }
    
    // MARK: - Table View Data Source & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.commitmentCell, for: indexPath)
        if let commitmentCell = cell as? CommitmentTableViewCell, let commitment = fetchedResultsController?.object(at: indexPath) {
            commitmentCell.commitment = commitment
        }
        return cell
    }
    
    // MARK: - Navigation
    
    private var mixerAddressToDisplay: String?
    private var mixedValueToDisplay: String?
    
    @objc func segueToGainsLossesDetails(_ notification: Notification) {
        if let mixerId = notification.object as? String {
            mixerAddressToDisplay = ConfigParser.shared.mixerAddress(for: mixerId)
            mixedValueToDisplay = ConfigParser.shared.value(for: mixerId)
        }
        
        self.performSegue(withIdentifier: Storyboard.showMixerAddressSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showMixerAddressSegue {
            if let showMixerVC = segue.destination as? ShowMixerViewController {
                showMixerVC.mixerAddress = mixerAddressToDisplay
                showMixerVC.mixedValue = mixedValueToDisplay
            }
        }
    }
    
}
