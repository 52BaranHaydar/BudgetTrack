//
//  MapView.swift
//  BudgetTrack
//
//  Created by Baran on 20.03.2026.
//
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var transactionsWithLocation: [Transaction] {
        viewModel.transactions.filter {
            $0.latitude != nil && $0.longitude != nil
        }
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: transactionsWithLocation) { transaction in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: transaction.latitude!,
                longitude: transaction.longitude!
            )) {
                VStack(spacing: 4) {
                    Image(systemName: transaction.category.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(transaction.type == .income ? Color.green : Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    Text("₺\(transaction.amount, specifier: "%.0f")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(radius: 2)
                }
            }
        }
        .navigationTitle("Harcama Haritası")
        .navigationBarTitleDisplayMode(.large)
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .bottom) {
            if transactionsWithLocation.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "mappin.slash")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Henüz konumlu işlem yok")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(viewModel: BudgetViewModel())
    }
}
