import UIKit

protocol LanguageCellDelegate {
    func didToggleRadioButton(_ indexPath: IndexPath)
}

class LanguageCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    var delegate: LanguageCellDelegate?
    
    func initCellItem() {

        if self.radioButton.isSelected{
               let selectedImage = UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysTemplate)
            self.radioButton.setImage(selectedImage, for: .normal)
        }else{
            let deselectedImage = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
               
                  radioButton.setImage(deselectedImage, for: .normal)
        }
      
        
        radioButton.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        print("radio button tapped")
        let isSelected = !self.radioButton.isSelected
        self.radioButton.isSelected = isSelected
        if isSelected {
            deselectOtherButton()
             let selectedImage = UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysTemplate)
              radioButton.setImage(selectedImage, for: .normal)
        }
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.didToggleRadioButton(tappedCellIndexPath)
    }

    func deselectOtherButton() {
        let tableView = self.superview as! UITableView
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        let indexPaths = tableView.indexPathsForVisibleRows
        for indexPath in indexPaths! {
            if indexPath.row != tappedCellIndexPath.row && indexPath.section == tappedCellIndexPath.section {
                let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as! LanguageCell
                 let deselectedImage = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
                cell.radioButton.isSelected = false
                cell.radioButton.setImage(deselectedImage, for: .normal)
            }
        }
    }
    
}
