import SwiftUI

struct TelevisionView: View {
    var body: some View {
        Image("Philips_PM5544_PDF")
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .padding(-2)
            .clipShape(Circle())
    }
}

struct TelevisionView_Previews: PreviewProvider {
    static var previews: some View {
        TelevisionView()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
