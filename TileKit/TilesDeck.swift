public struct TilesDeck {
    public let lottery: Lottery
    public let mixer: Mixer
    
    public let tile: Tile
    public let hint: TileHint
    
    private let stack: ArraySlice<Tile>
    
    public init(mixer: Mixer, lottery: Lottery) {
        let stack = mixer.mix()
        guard let tile = stack.first else {
            fatalError("Out of tiles")
        }
        self.init(
            stack: stack.dropFirst(),
            tile: tile,
            hint: .single(tile),
            mixer: mixer.next(),
            lottery: lottery
        )
    }
    
    private init(stack: ArraySlice<Tile>, tile: Tile, hint: TileHint, mixer: Mixer, lottery: Lottery) {
        self.stack = stack
        self.tile = tile
        self.hint = hint
        self.mixer = mixer
        self.lottery = lottery
    }
    
    public func next(maxValue: Int) -> TilesDeck {
        if let (hint, tile) = lottery.draw(maxValue: maxValue) {
            return TilesDeck(
                stack: stack,
                tile: tile,
                hint: hint,
                mixer: mixer,
                lottery: lottery.next()
            )
        }
        if let tile = stack.first {
            return TilesDeck(
                stack: stack.dropFirst(),
                tile: tile,
                hint: .single(tile),
                mixer: mixer,
                lottery: lottery.next()
            )
        }
        return TilesDeck(
            mixer: mixer,
            lottery: lottery.next()
        )
    }
}
