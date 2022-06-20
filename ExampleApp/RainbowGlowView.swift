import SwiftUI

extension View {
    var steps: Int { 10 }
    var rainbowColors: [Color] {
        (0...steps).map {
            Color(
                hue: Double($0)/Double(steps + 1),
                saturation: 1,
                brightness: 1
            )
        }
    }
    
    var fillStyle: some ShapeStyle {
        AngularGradient(
            gradient: Gradient(
                colors: rainbowColors
            ),
            center: .center
        )
    }
    func multicolorGlow() -> some View {
        ZStack {
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(fillStyle)
                    .frame(width: 400, height: 300)
                    .mask(blur(radius: 20))
                    .overlay(blur(radius: 5 - CGFloat(i * 5)))
                    .overlay(blur(radius: CGFloat(i)))
            }
        }
    }
}

struct RainbowGlowView: View {
    var body: some View {
        Text("Hello World")
            .font(
                .system(.largeTitle, design: .rounded)
            )
            .fontWeight(.black)
            .foregroundColor(.white)
            .shadow(radius: 2)
            .multilineTextAlignment(.center)
            .multicolorGlow()
            .frame(width: 200, height: 100)
            .padding(50)
    }
}

public struct RainbowGlowView_Previews: PreviewProvider {
    public static var previews: some View {
        RainbowGlowView()
            .previewLayout(.sizeThatFits)
    }
}
