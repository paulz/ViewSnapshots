import SwiftUI
import PreviewGroup

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewGroup {
            ContentView()
                .background(Color.yellow)
            ContentView()
                .background(Color.green)
        }
    }
}
