//
//  ViewController.swift
//  InfiniteScrollingWithUIViewControllerAndSwiftUI
//
//  Created by Namaswi Chandarana on 07/07/23.
//
import UIKit
import SwiftUI

struct ImageModel: Codable, Identifiable {
    let id: String
    let download_url: String
}

struct ContentView: View {
    @State private var images: [String] = []

    var body: some View {
        List(images, id: \.self) { imageUrl in
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "exclamationmark.icloud.fill")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
        }
        .onAppear {
            loadImages()
        }
    }

    func loadImages() {
        guard let url = URL(string: "https://picsum.photos/v2/list?page=1&limit=100") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            do {
                let images = try decoder.decode([ImageModel].self, from: data)
                DispatchQueue.main.async {
                    self.images.append(contentsOf: images.map { $0.download_url })
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
