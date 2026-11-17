import SwiftUI

struct ContentView: View {
    @StateObject private var model = GameModel()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(#colorLiteral(red: 0.1058823529, green: 0.1568627451, blue: 0.2196078431, alpha: 1)), Color(#colorLiteral(red: 0.05098039216, green: 0.06666666667, blue: 0.09019607843, alpha: 1))], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if let state = model.gameState {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Top User Info & Resources Bar
                            HStack {
                                HStack(spacing: 12) {
                                    Text("🐉")
                                        .font(.system(size: 32))
                                        .padding(8)
                                        .background(Circle().fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(state.user.name)
                                            .font(.headline)
                                            .foregroundColor(.yellow)
                                        Text("Level \(state.user.level)")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(Color.indigo))
                                            .foregroundColor(.white)
                                    }
                                }

                                Spacer()

                                // Currencies
                                HStack(spacing: 12) {
                                    CurrencyBadge(icon: "🪙", value: state.user.gold)
                                    CurrencyBadge(icon: "🍖", value: state.user.food)
                                    CurrencyBadge(icon: "💎", value: state.user.gems)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.6)).border(Color.gray.opacity(0.3), width: 1))

                            // Islands & Habitats
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("🏝️ \(state.islands.first?.name ?? "Island")")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.green)
                                    Spacer()
                                    Button(action: { model.buyHabitat() }) {
                                        Text("Build Habitat 🪙1000")
                                            .font(.caption)
                                            .bold()
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }

                                ForEach(state.islands.first?.habitats ?? []) { hab in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(hab.name)
                                                .bold()
                                                .foregroundColor(.green)
                                            Spacer()
                                            Text("Gold: \(hab.gold_stored)/\(hab.max_gold)")
                                                .font(.subheadline)
                                                .foregroundColor(.yellow)
                                            Button(action: { model.collectGold(habitatId: hab.id) }) {
                                                Text("Collect")
                                                    .font(.caption)
                                                    .bold()
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Color.yellow)
                                                    .foregroundColor(.black)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        Text("Dragons inside: \(hab.dragons.count)/\(hab.capacity)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.4)).border(Color.green.opacity(0.4), width: 1))
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(#colorLiteral(red: 0.137254902, green: 0.2039215686, blue: 0.1411764706, alpha: 0.8))).border(Color.green.opacity(0.6), width: 2))

                            // Hatchery & Breeding
                            HStack(spacing: 16) {
                                // Hatchery
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("🥚 Hatchery")
                                        .font(.headline)
                                        .foregroundColor(.cyan)
                                    if state.hatchery.isEmpty {
                                        Text("Hatchery empty")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    } else {
                                        ForEach(state.hatchery) { egg in
                                            HStack {
                                                Text(egg.icon)
                                                Text(egg.egg_name)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Button(action: { model.hatchEgg(eggId: egg.id) }) {
                                                    Text("Hatch")
                                                        .font(.caption)
                                                        .bold()
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(Color.cyan)
                                                        .foregroundColor(.black)
                                                        .cornerRadius(6)
                                                }
                                            }
                                        }
                                    }
                                    Button(action: { model.breedDragons() }) {
                                        Text("Breed Dragons (💎50)")
                                            .font(.caption)
                                            .bold()
                                            .frame(maxWidth: .infinity)
                                            .padding(8)
                                            .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.5)))

                                // Dragons
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("🐉 Sanctuary (\(state.dragons.count))")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    ForEach(state.dragons) { dragon in
                                        HStack {
                                            Text(dragon.icon)
                                            VStack(alignment: .leading) {
                                                Text(dragon.name)
                                                    .font(.caption)
                                                    .bold()
                                                    .foregroundColor(.yellow)
                                                Text("Lvl \(dragon.level)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Button(action: { model.feedDragon(dragonId: dragon.id) }) {
                                                Text("Feed")
                                                    .font(.system(size: 10))
                                                    .bold()
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 4)
                                                    .background(Color.orange)
                                                    .foregroundColor(.black)
                                                    .cornerRadius(6)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.5)))
                            }
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Connecting to Open Source Game Server...")
                        .foregroundColor(.white)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CurrencyBadge: View {
    var icon: String
    var value: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
            Text("\(value)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.6)))
    }
}
