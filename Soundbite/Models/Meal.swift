import Foundation

struct Meal: Identifiable, Codable {
    let id: UUID
    let date: Date
    let time: String
    let name: String
    let category: String
    let ingredients: [String]
    let carbLevel: String
    let carbsGrams: Double?
    let proteinLevel: String
    let proteinGrams: Double?
    let fatLevel: String
    let fatGrams: Double?
    let sugarContent: String
    let sugarGrams: Double?
    let fiberContent: String
    let fiberGrams: Double?
    let feeling: String
    let notes: String
    
    init(id: UUID = UUID(), date: Date, time: String, name: String, category: String, ingredients: [String], carbLevel: String, carbsGrams: Double?, proteinLevel: String, proteinGrams: Double?, fatLevel: String, fatGrams: Double?, sugarContent: String, sugarGrams: Double?, fiberContent: String, fiberGrams: Double?, feeling: String, notes: String) {
        self.id = id
        self.date = date
        self.time = time
        self.name = name
        self.category = category
        self.ingredients = ingredients
        self.carbLevel = carbLevel
        self.carbsGrams = carbsGrams
        self.proteinLevel = proteinLevel
        self.proteinGrams = proteinGrams
        self.fatLevel = fatLevel
        self.fatGrams = fatGrams
        self.sugarContent = sugarContent
        self.sugarGrams = sugarGrams
        self.fiberContent = fiberContent
        self.fiberGrams = fiberGrams
        self.feeling = feeling
        self.notes = notes
    }
}