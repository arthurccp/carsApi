
import Foundation


enum carError{
    case url
    case taskError(erros: Error)
    case noReponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation{
    case save
    case update
    case delete
}

class REST {
    
    private static let basePath = "http://carangas.herokuapp.com/cars"
    
    private static let configuration: URLSessionConfiguration = {
       let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false // nao permite que o usuario utulize seu plano de dados
        config.httpAdditionalHeaders = ["Content-Type": "application/json"] // define que o tipo de arquivos a se lidar será a penas json
        config.timeoutIntervalForRequest = 30.0 //tempo de espera
        config.httpMaximumConnectionsPerHost = 5 // numero de tarefas de requisições ao mesmo tempo
        
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)    //URLSession.shared
    
    class func loadCars(onComplete: @escaping ([Car])-> Void, onError: @escaping (carError)-> Void) {
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        let dataTask = session.dataTask(with: url) {(data: Data?, response: URLResponse?,error: Error?) in
            
            if error == nil{
                guard let response = response as? HTTPURLResponse else {
                    onError(.noReponse)
                    return
                    
                }
                if response.statusCode == 200{
                    do{
                        guard let data = data else{return}
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    }catch{
                        print(error)
                        onError(.invalidJSON)
                    }
                }else{
                    print("Algum status inválido pelo servidor")
                    onError(.responseStatusCode(code: response.statusCode))
                }
            }else{
                print(error!)
                onError(.taskError(erros: error!))
            }
        }
        dataTask.resume()
    }
    
    
    class func save(car:Car, onComplete: @escaping (Bool) -> Void){
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    class func update(car:Car, onComplete: @escaping (Bool) -> Void){
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    class func delete(car:Car, onComplete: @escaping (Bool) -> Void){
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    private class func applyOperation(car:Car, operation: RESTOperation, onComplete: @escaping (Bool) -> Void){
        
        
        let urlString = basePath + "/" + (car._id ?? "")
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var httpMethod: String = ""
        var request = URLRequest(url: url)
        
        switch operation {
            case .save:
                httpMethod = "POST"
            case .update:
                httpMethod = "PUT"
            case .delete:
                httpMethod = "DELETE"
        }
        request.httpMethod = httpMethod
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
            
        }
        request.httpBody = json
        
        let dataTask = session.dataTask(with: request){(data, response,error) in
            if error == nil{
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data else{
                    onComplete(false)
                    return
                }
                onComplete(true)
            }else{
                onComplete(false)
            }
            
        }
        dataTask.resume()
        
    }
}
