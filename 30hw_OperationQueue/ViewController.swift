//
//  ViewController.swift
//  30hw_OperationQueue
//
//  Created by Pavel Plyago on 10.07.2024.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var imageUrls: [String] = [
        "https://developer.apple.com/assets/elements/icons/swift/swift-96x96_2x.png",
        "https://static.tildacdn.com/tild3831-3766-4432-b034-643862663863/scale_1200_5.jpeg",
        "https://i.pinimg.com/236x/a6/f1/17/a6f11757d5608421cca27efedf34f273.jpg",
        "https://dummyimage.com/600x400/000/fff&text=1",
        "https://dummyimage.com/600x400/000/fff&text=2",
        "https://dummyimage.com/600x400/000/fff&text=3",
        "https://dummyimage.com/600x400/000/fff&text=4",
        "https://dummyimage.com/600x400/000/fff&text=5",
        "https://dummyimage.com/600x400/000/fff&text=6",
        "https://dummyimage.com/600x400/000/fff&text=7",
        "https://dummyimage.com/600x400/000/fff&text=8",
        "https://dummyimage.com/600x400/000/fff&text=9",
        "https://dummyimage.com/600x400/000/fff&text=10",
        "https://dummyimage.com/600x400/000/fff&text=11",
        "https://dummyimage.com/600x400/000/fff&text=12",
        "https://dummyimage.com/600x400/000/fff&text=13",
        "https://dummyimage.com/600x400/000/fff&text=14",
        "https://dummyimage.com/600x400/000/fff&text=15"

    ]
    
    private var images: [UIImage?] = []
    private let operationQueue = OperationQueue()
    
    
    private lazy var collectionOfImage: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionOfImage)
        NSLayoutConstraint.activate([
            collectionOfImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionOfImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionOfImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionOfImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        //заполняем массив для картинок nil таким количеством, сколько ссылок на изображения
        images = Array(repeating: nil, count: imageUrls.count)
        
        loadImages()
    }
    
    
    
    func loadImages(){
        //для поочередной загрузки картинок используем один поток
        operationQueue.maxConcurrentOperationCount = 1
        
        for (index, urlString) in imageUrls.enumerated() {
            //MARK: использование паттерна PROXY - перехватывает объект и сравнивает есть ли уже такие данные в кэше
            
            //проверяем есть ли данные в кэше с таким ключом
            if let cachedImage = imageCache.object(forKey: urlString as NSString) {
                images[index] = cachedImage
                self.collectionOfImage.reloadItems(at: [IndexPath(item: index, section: 0)])
            } else {
                //MARK: использование паттерна ФАСАД - вызов класса одной строкой, который скрывает большой функционал
                
                let operation = LoadImageOperation(urlString: urlString) { [weak self] image in

                    if let image = image {
                        self?.imageCache.setObject(image, forKey: urlString as NSString)
                    }
                    
                    self?.images[index] = image
                    DispatchQueue.main.async{
                        //обновляеми ячейку в collection
                        self?.collectionOfImage.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                operationQueue.addOperation(operation)
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.image = images[indexPath.row]
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}


