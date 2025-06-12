import SwiftUI

extension View {
    nonisolated func alert(
        for model: Binding<AlertModel>
    ) -> some View {
        self.alert(isPresented: model.isPresented) {
            Alert(
                title: Text(model.wrappedValue.title),
                message: Text(model.wrappedValue.text),
                dismissButton: .cancel(Text(model.wrappedValue.buttonTitle))
            )
        }
    }
}
