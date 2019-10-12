import SwiftUI

struct BackgroundImageView: View {
    @EnvironmentObject private var pictureStore: StreamPictureStore

    var body: some View {
        // TODO:
        //  - Better placeholder
        //  - Proper fit
        if let image = pictureStore.streamPicture {
            return Image(uiImage: image)
                .scaledToFill()
        }

        return Image(systemName: "photo")
            .scaledToFill()
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundImageView()
            Text("Hello World")
            Text("...........")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AnyView {
            ContentView().environmentObject(StreamPictureStore())
        }
    }
}
