//
//  AnalogClockView.swift
//  AnalogClock
//
//  Created by Nirajan Shrestha on 14/08/2025.
//

import SwiftUI
import AVFoundation

struct AnalogClockView: View {
	@State private var currentDate = Date()
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	var body: some View {
		VStack {
			ClockFaceView(currentDate: $currentDate)
				.frame(width: 300, height: 300)
		}
		.onReceive(timer) { input in
			currentDate = input
			AudioServicesPlaySystemSound(1104)
		}
	}
}

struct ClockFaceView: View {
	@Binding var currentDate: Date

	var body: some View {
		ZStack {
			Circle()
				.stroke(Color.gray.opacity(0.3), lineWidth: 8)

			MinuteTicksView()
			HourNumbersView()
			DateView(date: currentDate)

			ClockHandsView(date: currentDate)
		}
	}
}

struct MinuteTicksView: View {
	var body: some View {
		ForEach(0..<60) { tick in
			Rectangle()
				.fill(Color.gray)
				.frame(width: tick % 5 == 0 ? 3 : 1, height: tick % 5 == 0 ? 15 : 7)
				.offset(y: -150 + (tick % 5 == 0 ? 7.5 : 3.5))
				.rotationEffect(.degrees(Double(tick) / 60 * 360))
		}
	}
}

struct HourNumbersView: View {
	let radius: CGFloat = 120
	let center: CGPoint = CGPoint(x: 150, y: 150)

	var body: some View {
		ForEach(1...12, id: \.self) { hour in
			let position = calculatePosition(for: hour)

			Text("\(hour)")
				.font(.system(size: 16, weight: .bold))
				.position(position)
		}
	}

	func calculatePosition(for hour: Int) -> CGPoint {
		// Convert hour to angle in radians
		let angle = Double(hour) / 12 * 2 * Double.pi - Double.pi/2
		let x = center.x + radius * CGFloat(cos(angle))
		let y = center.y + radius * CGFloat(sin(angle))
		return CGPoint(x: x, y: y)
	}
}

struct DateView: View {
	var date: Date
	var body: some View {
		Text("\(Calendar.current.component(.day, from: date))")
			.font(.system(size: 14, weight: .bold))
			.frame(width: 30, height: 30)
			.background(Circle().fill(Color.yellow.opacity(0.8)))
			.position(x: 150 + 90, y: 150) // 3 o'clock
	}
}

struct ClockHandsView: View {
	var date: Date

	var body: some View {
		// Hour hand
		Rectangle()
			.fill(Color.black)
			.frame(width: 4, height: 70)
			.offset(y: -35)
			.rotationEffect(.degrees(hourAngle(date: date)))

		// Minute hand
		Rectangle()
			.fill(Color.blue)
			.frame(width: 3, height: 100)
			.offset(y: -50)
			.rotationEffect(.degrees(minuteAngle(date: date)))

		// Second hand
		Rectangle()
			.fill(Color.red)
			.frame(width: 2, height: 120)
			.offset(y: -60)
			.rotationEffect(.degrees(secondAngle(date: date)))

		// Center circle
		Circle()
			.fill(Color.black)
			.frame(width: 8, height: 8)
	}

	// MARK: - Helper functions
	func hourAngle(date: Date) -> Double {
		let calendar = Calendar.current
		let hours = calendar.component(.hour, from: date) % 12
		let minutes = calendar.component(.minute, from: date)
		return Double(hours) / 12 * 360 + Double(minutes)/60 * 30
	}

	func minuteAngle(date: Date) -> Double {
		let calendar = Calendar.current
		let minutes = calendar.component(.minute, from: date)
		let seconds = calendar.component(.second, from: date)
		return Double(minutes) / 60 * 360 + Double(seconds)/60 * 6
	}

	func secondAngle(date: Date) -> Double {
		let calendar = Calendar.current
		let seconds = calendar.component(.second, from: date)
		return Double(seconds) / 60 * 360
	}
}

#Preview {
	AnalogClockView()
}
