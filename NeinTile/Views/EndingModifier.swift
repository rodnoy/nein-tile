import SwiftUI

struct EndingModifier: ViewModifier {
    @Environment (\.colorScheme) var colorScheme

    @EnvironmentObject var game: GameEnvironment

    @State private var tileSize: CGFloat = 0

    var overlay: Color {
        colorScheme == .dark ? .black : .white
    }

    func body(content: Content) -> some View {
        return ZStack {
            content
                .onPreferenceChange(TileSizePreferenceKey.self) { size in
                    self.tileSize = size
                }
            if game.current.done {
                overlay
                    .opacity(0.8)
                    .transition(AnyTransition.opacity.combined(with: .scale))
                Text("The")
                    .offset(x: 0, y: -tileSize)
                    .font(.system(size: tileSize, weight: .heavy))
                    .transition(AnyTransition.move(edge: .leading).combined(with: .opacity))
                Text("End")
                    .font(.system(size: tileSize, weight: .heavy))
                    .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                Text("Ready for the next game?")
                    .offset(x: 0, y: tileSize)
                    .multilineTextAlignment(.center)
                    .font(.system(size: tileSize / 4, weight: .bold))
                    .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

extension View {
    func applyEnding() -> some View {
        return self.modifier(EndingModifier())
    }
}

#if DEBUG
struct GameEndingModifier_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(GameSamples.allSamples) { sample in
                AreaView()
                    .environmentObject(GameEnvironment(sample))
                    .preferredColorScheme(.dark)
                AreaView()
                    .environmentObject(GameEnvironment(sample))
                    .preferredColorScheme(.light)
            }
        }
        .accentColor(Color.orange)
        .previewLayout(.fixed(width: 400, height: 400))
    }
}
#endif
