import SwiftData
import SwiftUI

struct ProgressTileView: View {
  let subjectType: SubjectType
  let search: String
  let width: CGFloat

  @AppStorage("progressLimit") var progressLimit: Int = 50

  @Environment(\.modelContext) var modelContext

  @Query var subjects: [Subject]

  init(subjectType: SubjectType, search: String, width: CGFloat) {
    self.subjectType = subjectType
    self.search = search
    self.width = width

    let stype = subjectType.rawValue
    let doingType = CollectionType.doing.rawValue
    var descriptor = FetchDescriptor<Subject>(
      predicate: #Predicate<Subject> {
        (stype == 0 || $0.type == stype) && $0.ctype == doingType
          && (search == "" || $0.name.localizedStandardContains(search)
            || $0.alias.localizedStandardContains(search))
      },
      sortBy: [
        SortDescriptor(\.collectedAt, order: .reverse)
      ])
    if progressLimit > 0 {
      descriptor.fetchLimit = progressLimit
    }
    self._subjects = Query(descriptor)
  }

  var cols: Int {
    let cols = Int((width - 8) / (150 + 24))
    return max(cols, 1)
  }

  var cardWidth: CGFloat {
    let cols = CGFloat(self.cols)
    let cw = (width - 8) / cols - 24
    return max(cw, 150)
  }

  var columns: [GridItem] {
    Array(repeating: .init(.flexible()), count: cols)
  }

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(subjects) { subject in
        CardView(padding: 8) {
          ProgressTileItemView(subjectId: subject.subjectId, width: cardWidth)
            .environment(subject)
            .frame(width: cardWidth)
        }.frame(width: cardWidth + 16)
      }
    }
    .animation(.default, value: subjects)
    .padding(.horizontal, 8)
    .frame(width: width)
  }
}

struct ProgressTileItemView: View {
  let subjectId: Int
  let width: CGFloat

  @Environment(Subject.self) var subject
  @Environment(\.modelContext) var modelContext

  var imageHeight: CGFloat {
    width * 1.4
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ImageView(img: subject.images?.resize(.r400))
        .imageStyle(width: width, height: imageHeight)
        .imageType(.subject)
        .imageBadge(show: subject.interest?.private ?? false) {
          Image(systemName: "lock")
        }
        .imageLink(subject.link)

      VStack(alignment: .leading, spacing: 4) {
        VStack(alignment: .leading) {
          NavigationLink(value: NavDestination.subject(subjectId)) {
            Text(subject.name).font(.headline)
          }.buttonStyle(.plain)
          if !subject.nameCN.isEmpty {
            Text(subject.nameCN)
              .foregroundStyle(.secondary)
              .font(.subheadline)
          }
        }

        Spacer()

        switch subject.typeEnum {
        case .anime, .real:
          EpisodeRecentView(subjectId: subjectId)
            .environment(subject)
        case .book:
          SubjectBookChaptersView(mode: .tile)
            .environment(subject)

        default:
          Label(
            subject.typeEnum.description,
            systemImage: subject.typeEnum.icon
          )
          .foregroundStyle(.accent)
        }

        switch subject.typeEnum {
        case .book:
          VStack(spacing: 1) {
            ProgressView(
              value: Float(min(subject.eps, subject.interest?.epStatus ?? 0)),
              total: Float(subject.eps))
            ProgressView(
              value: Float(min(subject.volumes, subject.interest?.volStatus ?? 0)),
              total: Float(subject.volumes))
          }.progressViewStyle(.linear)

        case .anime, .real:
          ProgressView(
            value: Float(min(subject.eps, subject.interest?.epStatus ?? 0)),
            total: Float(subject.eps)
          ).progressViewStyle(.linear)

        default:
          ProgressView(value: 0, total: 0).progressViewStyle(.linear)
        }
      }.frame(height: 120)
    }
  }
}

#Preview {
  let container = mockContainer()

  let subject = Subject.previewAnime
  let episodes = Episode.previewAnime
  container.mainContext.insert(subject)
  for episode in episodes {
    container.mainContext.insert(episode)
  }

  return ScrollView {
    LazyVStack(alignment: .leading) {
      CardView(padding: 8) {
        ProgressTileItemView(subjectId: subject.subjectId, width: 320)
          .environment(subject)
          .modelContainer(container)
      }
    }.padding()
  }
}
