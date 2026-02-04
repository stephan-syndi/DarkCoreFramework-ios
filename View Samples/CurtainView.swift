import SwiftUI

struct CurtainView: View {
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                Image(ImageResource.logo)
                Spacer()
                Image(ImageResource.loader)
                ProgressView()
                    .tint(.white)
                    .scaleEffect(2)
                    .padding()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .background{
            GeometryReader{ geo in
                Image(ImageResource.back1)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    CurtainView()
}
