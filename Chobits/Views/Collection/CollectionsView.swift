//
//  CollectionsView.swift
//  Chobits
//
//  Created by Chuan Chuan on 2024/5/14.
//

import OSLog
import SwiftData
import SwiftUI

struct CollectionsView: View {
  var body: some View {
    ScrollView(showsIndicators: false) {
      LazyVStack(alignment: .leading) {
        ForEach(SubjectType.allTypes) { stype in
          VStack {
            HStack {
              Text("我的\(stype.description)").font(.title3)
              Spacer()
              NavigationLink(value: NavDestination.collectionList(stype)) {
                Text("更多 »")
                  .font(.caption)
              }.buttonStyle(.navLink)
            }.padding(.top, 8)
            CollectionSubjectTypeView(stype: stype)
          }.padding(.top, 5)
        }
      }
      Spacer()
    }
  }
}

#Preview {
  let container = mockContainer()

  return NavigationStack {
    ScrollView {
      CollectionsView()
        .modelContainer(container)
    }
    .padding(.horizontal, 8)
  }
}
