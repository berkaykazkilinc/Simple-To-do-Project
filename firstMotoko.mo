import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor Assistant {
  // -> canister (icpdeki akıllı sözleşme) , smart conctract

  type ToDo = {
    // olabildiğince kısa tutuluyor
    description : Text;
    completed : Bool;
  };

  func natHash(n : Nat) : Hash.Hash {
    // default'u private  Nat-> doğal sayı
    Text.hash(Nat.toText(n)) // return Text.hash(Nat.toText(n)); (2.yol)
  };

  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash); // let-> immutable, var-> mutable , ToDo(default,)
  var nextId : Nat = 0;

  public query func getTodos() : async [ToDo] {
    Iter.toArray(todos.vals());
  };

  // Returns the ID that was given to the ToDo item
  public func addTodo(description : Text) : async Nat {
    let id = nextId;
    todos.put(id, { description = description; completed = false });
    nextId += 1;
    id // return id;
  };

  public func completeTodo(id : Nat) : async () {
    ignore do ? {
      let description = todos.get(id)!.description;
      todos.put(id, { description; completed = true });
    };
  };

  public query func showTodos() : async Text {
    var output : Text = "\n___TO-DOs___";
    for (todo : ToDo in todos.vals()) {
      output #= "\n" # todo.description;
      if (todo.completed) { output #= " ✔" };
    };
    output # "\n";
  };

  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(
      todos,
      Nat.equal,
      natHash,
      func(_, todo) { if (todo.completed) null else ?todo },
    );
  };

};
