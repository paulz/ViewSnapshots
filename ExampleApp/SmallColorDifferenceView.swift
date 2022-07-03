import SwiftUI
import PreviewGroup

struct SmallColorDifferenceView: View {
    var difference = 0.01
    var body: some View {
        VStack {
            Text("Color difference \(Int(difference * 100))%").font(.headline)
            HStack(spacing: 0) {
                ForEach((1...10), id: \.self) { _ in
                    Rectangle().foregroundColor(Color(red: 0, green: 1, blue: 0))
                    Rectangle().foregroundColor(Color(red: 0, green: 1 - difference, blue: 0))
                }
            }.frame(width: 100, height: 100)
        }
    }
}

struct SmallColorDifferenceView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewGroup {
            SmallColorDifferenceView(difference: 0.01)
            SmallColorDifferenceView(difference: 0.03)
        }
        .previewLayout(.sizeThatFits)
    }
}
