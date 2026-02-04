import SwiftUI
import DarkCoreFramework

struct PermissionView: View {
    var viewModel: PermissionProtocol
    
    init(viewModel: PermissionProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [Color.black,
                         Color.black.opacity(0.3)],
                startPoint: .bottom,
                endPoint: .center)
            .ignoresSafeArea()
            
            VStack{
                Spacer()
                
                Image(ImageResource.logo)
                Spacer()
                Text("Allow notifications about bonuses and promos")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundStyle(.white)
                
                Text("Stay tuned with best offers from our casino")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 6)
                
                Button{
                    viewModel.onRequestNotificationPermission()
                } label: {
                    Text("Yes, I Want Bonuses!")
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(Color(ColorResource.permissionBtn))
                        .padding(.horizontal, 60)
                )
                .foregroundColor(.permissionApplyFont)
                
                Button{
                    viewModel.onSkip()
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.clear)
                    }
                    .padding(.horizontal, 60)
                )
                .foregroundColor(Color.permissionText)
            }
        }
        .background(
            GeometryReader{ geo in
                Image(ImageResource.back)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
                .ignoresSafeArea()
        )
    }
}

#Preview {
    PermissionView(viewModel: TestPermissionViewModel())
}

class TestPermissionViewModel: PermissionProtocol {
    func onRequestNotificationPermission() {
        
    }
    
    func onSkip() {
        
    }
}
