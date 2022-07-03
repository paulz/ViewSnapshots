import SwiftUI

struct SmallColorDifferenceView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().foregroundColor(Color(red: 0, green: 1, blue: 0))
            Rectangle().foregroundColor(Color(red: 0, green: 0.95, blue: 0))
        }
    }
}

struct SmallColorDifferenceView_Previews: PreviewProvider {
    static var previews: some View {
        SmallColorDifferenceView()
            .previewLayout(.sizeThatFits)
    }
}
