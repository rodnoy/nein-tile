import SwiftUI
import TileKit

struct DeckView: View {
    @EnvironmentObject var game: GameEnvironment
    
    @State private var showMaker = false
    @State private var showScore = false
    
    var tiles: [Tile] {
        switch game.current.deck.hint {
        case let .single(tile):
            return [ tile ]
        case let .either(left, right):
            return [ left, right ]
        case let .threes(left, middle, right):
            return [ left, middle, right ]
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: leftButton) {
                Image(systemName: game.current.done ? "plus.circle" : "plus")
                    .rotationEffect(.init(degrees: game.current.done ? 360 : 0))
                    .animation(Animation.easeInOut(duration: 1.0).repeatCount(game.current.done ? 7 : 1))
                    .padding()
            }
            .sheet(isPresented: $showMaker) {
                MakeView(previous: self.game.gameMaker, tournament: self.game.tournament)
                    .environmentObject(self.game)
            }
            Spacer()
            if showScore || game.current.done {
                Text(Tile.format.string(for: game.current.score)!)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .onTapGesture {
                        self.showScore = false
                    }
            } else {
                ForEach(self.tiles, id: \.self) { tile in
                    TileView(edge: 40, size: 80, tile: tile)
                }
                .transition(
                    .asymmetric(
                        insertion: AnyTransition.move(edge: .top).combined(with: .opacity),
                        removal: AnyTransition.opacity.combined(with: .scale)
                    )
                )
                .onTapGesture {
                        self.showScore = true
                }
            }
            Spacer()
            Button(action: rightButton) {
                Image(systemName: game.tournament != nil || game.current.done ? "globe" : "arrow.uturn.left")
                    .padding()
            }
            .disabled(rightButtonDisabled)
        }
        .font(.title)
    }
    
    func leftButton() {
        showMaker = true
    }
    
    var rightButtonDisabled: Bool {
        if game.tournament != nil {
            return !GameDelegate.enabled
        } else if game.current.done {
            return !GameDelegate.enabled
        } else {
            return game.current.last == nil
        }
    }
    
    func rightButton() {
        if game.tournament != nil {
            AppNotifications.gameCenter.post(object: GameCenterCommand.leaderboard)
        } else if game.current.done {
            AppNotifications.gameCenter.post(object: GameCenterCommand.achievements)
        } else if let last = game.current.last {
            withAnimation {
                game.current = last
            }
        }
    }
}

#if DEBUG
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeckView()
                .preferredColorScheme(.dark)
            DeckView()
                .preferredColorScheme(.light)
        }
        .accentColor(Color.orange)
        .previewLayout(.sizeThatFits)
        .environmentObject(GameEnvironment())
    }
}
#endif
