//

import SwiftUI

extension View {
    func multicolorGlow() -> some View {
        ZStack {
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                    .frame(width: 400, height: 300)
                    .mask(blur(radius: 20))
                    .overlay(blur(radius: 5 - CGFloat(i * 5)))
                    .overlay(blur(radius: CGFloat(i)))
            }
        }
    }
}

struct RainbowGlowView: View {
    var fillStyle: some ShapeStyle {
        AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
    }
    var body: some View {
        Text("Hello World")
            .font(
                .system(.largeTitle,design: .rounded)
            )
            .fontWeight(.black)
            .foregroundColor(.white)
            .shadow(radius: 2)
            .multilineTextAlignment(.center)
            .multicolorGlow()
            .frame(width: 200, height: 100)
            .padding()
    }
}

struct RainbowGlowView_Previews: PreviewProvider {
    static var previews: some View {
        RainbowGlowView()
            .previewLayout(.sizeThatFits)
    }
}
