//
//  WellModel.swift
//  WellExplorer
//
//  Created by Owen Wetherbee on 5/5/20.
//  Copyright © 2020 Owen Wetherbee. All rights reserved.
//

import Foundation

struct WellShort: Decodable {
    var well_id: Int
    var well_name: String
    var distance: Double
    var toxicity: Int
}

struct Well: Decodable {
    var well_id: Int
    var well_name: String
    var operator_name: String
    var latitude: Double
    var longitude: Double
    var depth: Double
    var volume: Double
    var state: String
    var county: String
}

struct Ingredient: Decodable {
    var ingredient_name: String
    var cas: String
    var supplier: String
    var purpose: String
    var pathway: String
    var toxicity: Int
    var eafus: String
    var t3db: String
    var protein_targets: String
}

struct IngredientShort: Decodable {
    var ingredient_name: String
    var cas: String
    var pathway: String
    var toxicity: Int
    var eafus: String
    var t3db: String
    var protein_targets: String
}

struct ProteinTarget: Decodable {
    var uniprot: String
    var protein_name: String
    var gene_name: String
    var pathway: String
    var mechanism: String
    var protein_function: String
}

class WellModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func downloadWells(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            if let model = try? JSONDecoder().decode([WellShort]?.self, from: data) as [WellShort]? {
                self.delegate?.didReceiveData(data: model! as [WellShort])
            }
            if let model = try? JSONDecoder().decode(Well?.self, from: data) as Well? {
                self.delegate?.didReceiveData(data: model! as Well)
            }
            if let model = try? JSONDecoder().decode([Ingredient]?.self, from: data) as [Ingredient]? {
                self.delegate?.didReceiveData(data: model! as [Ingredient])
            }
            if let model = try? JSONDecoder().decode([IngredientShort]?.self, from: data) as [IngredientShort]? {
                self.delegate?.didReceiveData(data: model! as [IngredientShort])
            }
            if let model = try? JSONDecoder().decode([ProteinTarget]?.self, from: data) as [ProteinTarget]? {
                self.delegate?.didReceiveData(data: model! as [ProteinTarget])
            }
        }
    }
}
