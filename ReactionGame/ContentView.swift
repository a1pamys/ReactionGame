//
//  ContentView.swift
//  ReactionGame
//
//  Created by Alpamys Duimagambetov on 13/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var gameState: GameState = .initial
    @State private var buttonPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var progress: [ProgressState] = [.current] + Array(repeating: .future, count: 4)
    @State private var lastTapTime: Date?
    @State private var tapIntervals: [TimeInterval] = []
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Start Button
                if gameState == .initial {
                    startButton
                        .position(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top + geometry.size.height / 2)
                }

                // Reset and Play Field
                VStack {
                    if gameState == .playing || gameState == .completed {
                        progressIndicator
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Spacer()

                    if gameState == .playing {
                        playButton(position: buttonPosition, in: geometry.size)
                    } else if gameState == .completed {
                        resultTable
                    }

                    if gameState == .playing || gameState == .completed {
                        resetButton
                            .frame(height: 50)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.2))
                    }
                }
                .padding(.vertical, 8)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            resetGame()
        }
    }

    var startButton: some View {
        Button(action: startGame) {
            Text("Start")
                .frame(width: 96, height: 96)
                .background(Circle().fill(Color.blue))
                .foregroundColor(.white)
        }
    }

    func playButton(position: CGPoint, in size: CGSize) -> some View {
        Button(action: playAction) {
            Circle().fill(Color.red)
                .frame(width: 96, height: 96)
        }
        .position(x: position.x * size.width, y: position.y * size.height)
    }

    var resetButton: some View {
        Button(action: resetGame) {
            Text("Reset")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Capsule().fill(Color.blue))
                .foregroundColor(.white)
        }
    }

    var progressIndicator: some View {
        HStack {
            ForEach(progress, id: \.self) { state in
                Circle()
                    .fill(state.color)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
    }

    var resultTable: some View {
        VStack {
            ForEach(0..<tapIntervals.count, id: \.self) { index in
                Text("Click \(index + 1): \(tapIntervals[index], specifier: "%.0f") ms")
                    .font(index == bestClickIndex() ? .headline.bold() : .body)
            }
            Text("Average time: \(averageClickTime(), specifier: "%.0f") ms")
                .font(.headline)
                .padding()
                .background(Color.yellow.opacity(0.3))
        }
        .padding()
    }

    // MARK: - Game Logic

    func startGame() {
        lastTapTime = Date()
        gameState = .playing
        moveButtonRandomly()
        startTimer()
    }

    func playAction() {
        guard gameState == .playing else { return }
        recordClick()
        updateProgress()
        if gameState != .completed {
            moveButtonRandomly()
        }
    }

    func resetGame() {
        gameState = .initial
        progress = [.current] + Array(repeating: .future, count: 4)
        tapIntervals = []
        timer?.invalidate()
    }

    func moveButtonRandomly() {
        buttonPosition = CGPoint(x: CGFloat.random(in: 0.2...0.8), y: CGFloat.random(in: 0.2...0.8))
    }

    func recordClick() {
        let currentTime = Date()
        if let lastTime = lastTapTime {
            let interval = currentTime.timeIntervalSince(lastTime) * 1000 // Convert to milliseconds
            tapIntervals.append(interval)
        }
        lastTapTime = currentTime
    }

    func timeIntervalDifferenceInMilliseconds(from givenTimeInterval: TimeInterval) -> TimeInterval {
        // Get the current date and time
        let currentDate = Date()

        // Convert the given TimeInterval to a Date
        let givenDate = Date(timeIntervalSince1970: givenTimeInterval)

        // Calculate the difference in seconds
        let differenceInSeconds = currentDate.timeIntervalSince(givenDate)

        // Convert the difference to milliseconds
        let differenceInMilliseconds = differenceInSeconds * 1000

        return differenceInMilliseconds
    }

    func updateProgress() {
        if let currentIndex = progress.firstIndex(of: .current) {
            progress[currentIndex] = .completed
            if currentIndex < progress.count - 1 {
                progress[currentIndex + 1] = .current
            } else {
                gameState = .completed
                timer?.invalidate()
            }
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            moveButtonRandomly()
        }
    }

    func bestClickIndex() -> Int {
        let minTime = tapIntervals.min() ?? 0
        return tapIntervals.firstIndex(of: minTime) ?? 0
    }

    func averageClickTime() -> Double {
        return tapIntervals.reduce(0, +) / Double(tapIntervals.count)
    }
}

enum GameState {
    case initial, playing, completed
}

enum ProgressState {
    case current, completed, future

    var color: Color {
        switch self {
        case .current:
            return .yellow
        case .completed:
            return .green
        case .future:
            return .gray
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
