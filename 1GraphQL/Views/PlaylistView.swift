//
//  PlaylistView.swift
//  1GraphQL
//
//  Created by Zinedine Megnouche on 03/10/2023.
//

import SwiftUI

struct PlaylistView: View {
    var body: some View {
        VStack(alignment: .trailing){
            HStack{
                Spacer()
                Button(action: {}, label: {
                    HStack{
                        Image(systemName: "plus")
                        Text("add playlist")
                    }
                    
                })
            }.padding()
            Spacer()
            
        }
    }
}

#Preview {
    PlaylistView()
}
