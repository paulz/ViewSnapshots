//

import SwiftUI

struct ToggleView: View {
    @State var on: Bool = true
    var body: some View {
        Toggle(isOn: $on) {
            Text(on ? "On": "Off")
                .foregroundColor(.secondary)
        }
        .fixedSize()
        .padding()
    }
}

struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToggleView(on: true)
            ToggleView(on: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
