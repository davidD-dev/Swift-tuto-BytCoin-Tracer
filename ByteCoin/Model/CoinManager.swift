//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdate(price: String, currency: String)
    
    func didFailWithError(error: Error?)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "38D8A973-D457-44BD-B005-F4D6487E6696"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let requestUrl = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: requestUrl) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                if let safeData = data {
                    if  let price = self.parseJSON(safeData) {
                        let formatedPrice = String(format: "%.2f", price)
                        self.delegate?.didUpdate(price: formatedPrice, currency: currency)
                    }
                    
                }
                
            }
            task.resume()
        }
    }
    
    
    private func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(BitCoinModel.self, from: data)
            return decodedData.rate
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
