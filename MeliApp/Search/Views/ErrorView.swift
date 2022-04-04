//
//  ErrorView.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 31/03/22.
//

import UIKit

class ErrorView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.alpha = 0.0 // Initial state not visible
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(){
        guard let viewFromXIB = Bundle.main.loadNibNamed("ErrorView", owner: self)![0] as? UIView else {
            return
        }
        
        viewFromXIB.frame = .zero
        addSubview(viewFromXIB)
    }
    
    func setupViewContentForError() {
        self.iconImageView.image = UIImage(systemName: "magnifyingglass.circle")
        self.titleLabel.text = "No encontramos publicaciones"
        self.messageLabel.text = "Revisa que la palabra esté bien escrita. También puedes probar con menos términos o más generales."
    }
    
    func fadeIn(duration: TimeInterval = 0.5) {
         UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
         })
     }

    func fadeOut(duration: TimeInterval = 0.25) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}
