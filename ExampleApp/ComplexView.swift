
import SwiftUI

///  https://betterprogramming.pub/an-overview-of-built-in-swiftui-views-374ea7549bf9
struct ComplexView: View {
    @State private var toggle = false
    @State private var sliderValue = 12.0
    @State private var stepperValue = 2
    @State var date = Date()
    @State private var color: Color = .red

    var body: some View {
        VStack {
            Image(systemName: "cloud.sun.rain.fill")
                .renderingMode(.original)
                        .resizable()
                        .font(.largeTitle)
                        .background(Color.black)
                        .clipShape(Circle())
                        .frame(width: 60, height: 60)
                        .padding()
            Toggle("Toggle", isOn: $toggle)
            HStack {
                Slider(value: $sliderValue, in: 0...30.0, minimumValueLabel: Text("0"), maximumValueLabel: Text("30"), label: {
                    Text("\(sliderValue)")
                })
                Text("\(Int(sliderValue))")
            }
            Stepper("Stepper: \(stepperValue)", value: $stepperValue)
            Picker(selection: $stepperValue,
                   label: Text("Picker \(stepperValue)")) {
                Text("♥️ - Hearts").tag(1)
                Text("♣️ - Clubs").tag(2)
                Text("♠️ - Spades").tag(3)
                Text("♦️ - Diamonds").tag(4)
            }
                   .pickerStyle(.wheel)
                   .padding(-20)
            DatePicker(
                "Time:",
                selection: $date,
                displayedComponents: [.hourAndMinute]
            ).id(date)
            ColorPicker("Color:", selection: $color)
        }.padding()
    }
}

struct ComplexView_Previews: PreviewProvider {
    static var previews: some View {
        ComplexView(date: .sample)
            .previewLayout(.sizeThatFits)
    }
}

extension Date {
    static var sample: Date! = Calendar.current
        .date(
            from: DateComponents(
                year: 2022,
                month: 7,
                day: 2,
                hour: 17,
                minute: 06
            )
        )
}
