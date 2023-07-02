//
//  ContentView.swift
//  FirebaseSetupDemo
//
//  Created by Tim Yoon on 7/2/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Combine

struct Todo: FBModelType, Equatable {
    @DocumentID var id: String? = UUID().uuidString
    var text: String = ""
    var isDone: Bool = false
}

class TodoListVM<DS: DataService> : ObservableObject where DS.Item == Todo {
    @Published private(set) var todos: [Todo] = []
    
    private let ds: DS
    private var cancellables = Set<AnyCancellable>()
    
    init(ds: DS) {
        self.ds = ds
        ds.getData()
            .sink { error in
                fatalError()
            } receiveValue: { [weak self] todos in
                self?.todos = todos
            }
            .store(in: &cancellables)
    }
    
    // CRUD
    
    func add(todo: Todo) {
        ds.add(todo)
    }
    func update(todo: Todo) {
        ds.update(todo)
    }
    func delete(indexSet: IndexSet) {
        var todosToDelete: [Todo] = []
        
        for index in indexSet {
            todosToDelete.append(todos[index])
        }
        
        for todo in todosToDelete {
            ds.delete(todo)
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    var save: (Todo) -> ()
    
    @State private var vm = Todo()
    
    var body: some View {
        HStack {
            Image(systemName: todo.isDone ? "checkmark.circle" : "circle")
                .onTapGesture {
                    vm.isDone.toggle()
                    save(todo)
                }
            TextField("Todo item", text: $vm.text)
                .textFieldStyle(.roundedBorder)
                .onChange(of: vm) { newValue in
                    save(newValue)
                }
        }
        .onAppear {
            vm = todo
        }
    }
}
struct ContentView: View {
    @StateObject var vm = TodoListVM(ds: FBDataService(path: "todolist"))
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.todos) { todo in
                    TodoRowView(todo: todo, save: vm.update)
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Todos")
            .toolbar {
                Button {
                    vm.add(todo: Todo())
                } label: {
                    Text("Add")
                }

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
