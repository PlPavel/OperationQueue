//
//  loadImageOperation.swift
//  30hw_OperationQueue
//
//  Created by Pavel Plyago on 12.07.2024.
//

import Foundation
import UIKit

class LoadImageOperation: Operation {
    private let syncQueue = DispatchQueue(label: "serial")
    private let urlString: String
    private let completion: (UIImage?) -> Void
    
    override var isAsynchronous: Bool {
        return true
    }
    
    init(urlString: String, completion: @escaping (UIImage?) -> Void) {
        self.urlString = urlString
        self.completion = completion
    }
    
    private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            syncQueue.sync {
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            syncQueue.sync {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished: Bool = false
    override var isFinished: Bool {
        get {
            syncQueue.sync {
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            syncQueue.sync {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        
        if isCancelled {
            _isFinished = true
            return
        }
        
        isExecuting = false
        main()
    }
    
    override func main() {
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let url = URL(string: urlString) else {
            finish()
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if self.isCancelled {
                self.finish()
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async{
                self.completion(image)
            }
            
            self.finish()
            
        }.resume()
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}

