/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

// RemoveCardButton: 删除卡片的按钮组件
struct RemoveCardButton: View {
    @Binding var entryCopy: Entry      // 日记条目的副本
    var card: Card                     // 要删除的卡片
    var isEditing: Bool               // 是否处于编辑状态
    var row: Int                      // 卡片所在行
    var index: Int                    // 卡片在行中的索引
    var action: () -> Void = { }      // 点击后的回调操作
    
    var body: some View {
        Button() {
            entryCopy.removeCard(cards: entryCopy.entryRows[row].cards, row: row, index: index)
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(card.isPhoto ? .white : .darkBrown)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding([.top, .trailing])
        }
        .opacity(isEditing ? 1 : 0)
    }
}

// FontButton: 字体选择按钮
struct FontButton: View {
    @Binding var entry: Entry         // 当前日记条目
    var font: JournalFont            // 字体选项
    var action: () -> Void = { }

    var body: some View {
        Button() {
            entry.font = font
        } label: {
            HStack {
                Image(systemName: entry.font == font ? "circle.fill" : "circle")
                    .font(.caption)
                Text(font.rawValue)
                    .font(font.uiFont(18))
                    .padding(.leading, 5)
                    .foregroundColor(.darkBrown)
            }
        }
    }
}

// EditingButton: 编辑模式切换按钮
struct EditingButton: View {
    @Binding var entries: [Entry]     // 所有日记条目
    @Binding var entry: Entry         // 当前条目
    @Binding var entryCopy: Entry     // 当前条目的副本
    @Binding var isNew: Bool          // 是否是新条目
    @Binding var isEditing: Bool      // 是否处于编辑状态
    var action: () -> Void = { }
    
    // 判断条目是否已添加到列表中
    var isAdded: Bool {
        entries.filter({ $0.id == entryCopy.id }).first != nil
    }
    
    var body: some View {
        Button {
            if isNew && isEditing {
                if !isAdded {
                    entries.append(entryCopy)
                } else {
                    if let index = entries.firstIndex(where: { $0.id == entryCopy.id }){
                        entries[index].update(from: entryCopy)
                    }
                }
            } else if !isNew && isEditing {
                entry.update(from: entryCopy)
            } else if !isNew && !isEditing {
                entryCopy = entry
            }
            withAnimation(.spring()) {
                isEditing.toggle()
            }
        } label: {
            if isNew && isEditing {
                if isAdded {
                    Text("Done")
                        .fontWeight(.medium)
                } else {
                    Text("Add")
                        .fontWeight(.medium)
                }
            } else if !isNew && isEditing {
                Text("Done")
                    .fontWeight(.medium)
            } else if !isEditing {
                Text("Edit")
                    .fontWeight(.medium)
            }
        }
    }
}

// EntryDetail: 日记条目详情视图
struct EntryDetail: View {
    @Binding var entries: [Entry]     // 所有日记条目
    @Binding var entry: Entry         // 当前条目
    
    @State private var isNew: Bool    // 是否是新条目
    @State private var isEditing: Bool // 是否处于编辑状态
    @State private var entryCopy = Entry() // 编辑时的副本
    
    init(entries: Binding<[Entry]>, entry: Binding<Entry>, isNew: Bool) {
        self._entries = entries
        self._entry = entry
        self._isNew = State(initialValue: isNew)
        self._isEditing = State(initialValue: isNew ? true : false)
    }
    
    var body: some View {
        EntryView(entry: isNew ? $entryCopy : $entry, entryCopy: $entryCopy, isEditing: $isEditing)
            .navigationBarBackButtonHidden(isNew ? false: isEditing)
            .toolbar {
                ToolbarItem {
                    EditingButton(entries: $entries, entry: $entry, entryCopy: $entryCopy, isNew: $isNew, isEditing: $isEditing)
                }
                ToolbarItem (placement: .navigationBarLeading) {
                    if !isNew && isEditing {
                        Button("Cancel") {
                            withAnimation(.spring()) {
                                isEditing.toggle()
                            }
                        }
                    }
                }
            }
    }
}

// SettingsButton: 设置按钮组件
struct SettingsButton: View {
    @Binding var showSettings: Bool   // 控制设置视图的显示
    var currentEntry: Entry = Entry() // 当前条目
    var action: () -> Void = { }

    var body: some View {
        Button() {
            showSettings.toggle()
            action()
        } label: {
            SettingsButtonView(theme: currentEntry.theme)
        }
    }
}

// SettingsButtonView: 设置按钮的视觉表现
struct SettingsButtonView: View {
    var theme: JournalTheme          // 当前主题
    
    var body: some View {
        VStack (spacing: 0) {
            BackgroundIcon(forTheme: theme)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text("Theme >")
                .modifier(FontStyle(size: 12))
        }
        .padding(.vertical)
    }
}

// NewEntryLabel: 新建条目的标签组件
struct NewEntryLabel: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.tanBackground)
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.darkBrown, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            Text("+ New Entry")
                .modifier(FontStyle(size: 30))
        }
        .frame(height: 80)
    }
}
