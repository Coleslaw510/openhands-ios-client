import Foundation
import Combine

struct UserState: Codable {
    var id: String
    var name: String
    var level: Int
    var xp: Int
    var next_level_xp: Int
    var gold: Int
    var food: Int
    var gems: Int
}

struct Habitat: Codable, Identifiable {
    var id: Int
    var name: String
    var type: String
    var level: Int
    var capacity: Int
    var gold_stored: Int
    var max_gold: Int
    var dragons: [Int]
}

struct Island: Codable, Identifiable {
    var id: Int
    var name: String
    var unlocked: Bool
    var habitats: [Habitat]
}

struct Dragon: Codable, Identifiable {
    var id: Int
    var name: String
    var element: String
    var level: Int
    var rarity: String
    var gold_per_min: Int
    var icon: String
}

struct Egg: Codable, Identifiable {
    var id: Int
    var egg_name: String
    var element: String
    var icon: String
}

struct Farm: Codable, Identifiable {
    var id: Int
    var level: Int
    var status: String
    var crop: String?
    var yield: Int
}

struct GameState: Codable {
    var user: UserState
    var islands: [Island]
    var dragons: [Dragon]
    var hatchery: [Egg]
    var farms: [Farm]
}

class GameModel: ObservableObject {
    @Published var gameState: GameState?
    @Published var serverURL: String = "https://katrina-pattern-elderly-ion.trycloudflare.com"
    @Published var errorMessage: String?
    
    private var timer: Timer?

    init() {
        fetchState()
        startPolling()
    }

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchState()
        }
    }

    func fetchState() {
        guard let url = URL(string: "\(serverURL)/api/state") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(GameState.self, from: data)
                    DispatchQueue.main.async {
                        self.gameState = decoded
                        self.errorMessage = nil
                    }
                } catch {
                    print("Decode error: \(error)")
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }.resume()
    }

    func collectGold(habitatId: Int) {
        sendAction(endpoint: "/api/action/collect_gold", body: ["habitat_id": habitatId])
    }

    func feedDragon(dragonId: Int) {
        sendAction(endpoint: "/api/action/feed_dragon", body: ["dragon_id": dragonId])
    }

    func hatchEgg(eggId: Int) {
        sendAction(endpoint: "/api/action/hatch_egg", body: ["egg_id": eggId])
    }

    func breedDragons() {
        sendAction(endpoint: "/api/action/breed", body: ["dragon1_id": 1, "dragon2_id": 1])
    }

    func buyHabitat() {
        sendAction(endpoint: "/api/action/buy_habitat", body: ["type": "fire"])
    }

    func harvestFarm(farmId: Int) {
        sendAction(endpoint: "/api/action/harvest_farm", body: ["farm_id": farmId])
    }

    func plantFarm(farmId: Int) {
        sendAction(endpoint: "/api/action/plant_farm", body: ["farm_id": farmId, "crop": "Mega Munchies"])
    }

    private func sendAction(endpoint: String, body: [String: Any]) {
        guard let url = URL(string: "\(serverURL)\(endpoint)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(GameState.self, from: data)
                    DispatchQueue.main.async {
                        self.gameState = decoded
                    }
                } catch {
                    self.fetchState()
                }
            }
        }.resume()
    }
}
