/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// EntryList: 日记条目列表视图
struct EntryList: View {
    @ObservedObject var journalData: JournalData   // 日记数据
    @State private var newEntry = Entry()          // 新条目
    @State private var selection: Entry?           // 当前选中的条目

    var body: some View{
        NavigationSplitView {
            // 左侧列表面板
            VStack(alignment: .leading) {
                JournalAppTitle()
                // 条目列表
                List(selection: $selection) {
                    // 新建条目按钮
                    NewEntryLabel()
                        .tag(newEntry)
                        .modifier(ListRowStyle())

                    // 现有条目列表
                    ForEach($journalData.entries){ $entry in
                        TitleView(entry: $entry)
                            .tag(entry)
                            .modifier(ListRowStyle())
                    }
                    // 删除条目功能
                    .onDelete(perform: { indexSet in
                        journalData.entries.remove(atOffsets: indexSet)
                    })
                }
                .modifier(EntryListStyle())
            }
            .navigationTitle("Journal")
            .toolbar(.hidden)
            .background(
                Image("MenuBackground")
                    .resizable()
                    .modifier(BackgroundStyle())
            )

        } detail: {
            // 右侧详情面板
            ZStack {
                // 显示选中条目或默认视图
                if let entry = selection, let entryBinding = journalData.getBindingToEntry(entry) {
                    EntryDetail(entries: $journalData.entries, entry: entryBinding, isNew: entry == newEntry)
                } else {
                    SelectEntryView()
                }
            }
        }
    }
}


struct EntryList_Previews : PreviewProvider {
    static var previews: some View {
        EntryList(journalData: JournalData())
    }
}

// JournalAppTitle: 应用标题组件
struct JournalAppTitle: View {
    var body: some View {
        Text("Journal")
            .modifier(FontStyle(size: 50))
            .padding()
            .padding(.top)
    }
}

// SelectEntryView: 未选中条目时的默认视图
struct SelectEntryView: View {
    var body: some View {
        Text("Select An Entry")
            .modifier(FontStyle(size: 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.tanBackground)
            .ignoresSafeArea()
    }
}


