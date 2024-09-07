//
//  ImageCollectionViewCell.swift
//  30hw_OperationQueue
//
//  Created by Pavel Plyago on 10.07.2024.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageViewForCell: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageViewForCell)
        
        NSLayoutConstraint.activate([
            imageViewForCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageViewForCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageViewForCell.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageViewForCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let operationQueue = OperationQueue()
    
    func createImage(url: URL){
        
        let blockOperation = BlockOperation(){
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                OperationQueue.main.addOperation {
                    self.imageViewForCell.image = image
                }
            }
        }
        
        operationQueue.addOperation(blockOperation)
    }
}
