import SwiftUI

@available(iOS 14.0, *)
public struct FloatingMenuActionButton: View {
    @Binding var isSelected: Bool
    let floatingMenuItems: [FloatingMenuItem]
    let mainButtonColor: Color
    let menuButtonColor: Color
    let menuIconColor: Color

    public init(isSelected: Binding<Bool>, floatingMenuItems: [FloatingMenuItem], mainButtonColor: Color = .green, menuButtonColor: Color = .white, menuIconColor: Color = .black) {
        self._isSelected = isSelected
        self.floatingMenuItems = floatingMenuItems
        self.mainButtonColor = mainButtonColor
        self.menuButtonColor = menuButtonColor
        self.menuIconColor = menuIconColor
    }

    public var body: some View {
        VStack {
            if isSelected {
                ForEach(floatingMenuItems) { item in
                    Button {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()

                        withAnimation(.easeIn(duration: 0.2)) {
                            isSelected.toggle()
                        }
                        item.buttonAction()
                    } label: {
                        Image(item.iconName)
                    }
                    .frame(width: 50, height: 50)
                    .background(menuButtonColor)
                    .foregroundColor(menuIconColor)
                    .clipShape(Circle())
                    .transition(.move(edge: .bottom))
                }
            }
            
            Button {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeIn(duration: 0.2)) {
                    isSelected.toggle()
                }
            } label: {
                Image(isSelected ? "ic_close" : "ic_floating_menu")
            }
            .frame(width: 50, height: 50)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 2)
        }
    }
}

public struct FloatingMenuItem: Identifiable {
    public let id = UUID()
    public let iconName: String
    public let buttonAction: (() -> Void)
 
    public init(iconName: String, buttonAction: @escaping (() -> Void)) {
        self.iconName = iconName
        self.buttonAction = buttonAction
    }
}
