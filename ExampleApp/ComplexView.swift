
import SwiftUI

///  https://betterprogramming.pub/an-overview-of-built-in-swiftui-views-374ea7549bf9
struct ComplexView: View {
    @State private var toggle = false
    @State private var sliderValue = 15.0
    @State private var stepperValue = 7.0
    @State private var date = Date(timeIntervalSinceReferenceDate: 87654321)
    @State private var color: Color = .red

    var body: some View {
        VStack {
            Image(systemName: "cart")
                        .resizable()
                        .frame(width: 40, height: 40)
            Toggle("Toggle", isOn: $toggle)
            HStack {
                Slider(value: $sliderValue, in: 0...30.0, minimumValueLabel: Text("0"), maximumValueLabel: Text("30"), label: {
                    Text("\(sliderValue)")
                })
                Text("\(Int(sliderValue))")
            }
            Stepper("Stepper: \(Int(stepperValue))", value: $stepperValue)
            Picker(selection: .constant(2), label: Text("Picker"), content: {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
            })
            DatePicker("Date:", selection: $date)
            ColorPicker("Color:", selection: $color)

        }.padding()
    }
}

struct ComplexView_Previews: PreviewProvider {
    static var previews: some View {
        ComplexView()
            .previewLayout(.sizeThatFits)
    }
}
