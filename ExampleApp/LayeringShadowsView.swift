//

import SwiftUI

struct LayeringShadowsView: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 100, height: 100)
            .shadow(color: .black, radius: 10)
            .shadow(color: .green, radius: 10)
            .shadow(color: .red, radius: 10)
            .shadow(color: .blue, radius: 10)
            .padding(50)
    }
}

struct LayeringShadowsView_Previews: PreviewProvider {
    static var previews: some View {
        LayeringShadowsView()
            .previewLayout(.sizeThatFits)
    }
}
