import Array "mo:base/Array";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Principal "mo:base/Principal";

actor TaskManager {

  type Task = {
    id : Nat;
    owner : Principal;
    description : Text;
    completed : Bool;
    important : Bool;
    date_added : Text;
    importance_level : Text;
  };

  stable var tasks : [Task] = [];
  stable var counter : Nat = 0;

  public shared ({ caller }) func addTask(
    description : Text,
    date : Text,
    importance : Bool,
  ) : async Task {

    let importance_level = if (importance) { "High Priority" } else {
      "Low Priority";
    };

    let task : Task = {
      id = counter;
      owner = caller;
      description;
      completed = false;
      important = importance;
      date_added = date;
      importance_level;
    };

    tasks := Array.append(tasks, [task]);
    counter += 1;

    return task;
  };

  public shared ({ caller }) func getTask(task_id : Nat) : async ?Task {
    Array.find<Task>(tasks, func(t) { t.id == task_id and t.owner == caller });
  };

  public shared ({ caller }) func toggleTaskCompletion(task_id : Nat) : async Bool {
    var found = false;
    tasks := Array.map<Task, Task>(
      tasks,
      func(t) {
        if (t.id == task_id and t.owner == caller) {
          found := true;
          { t with completed = not t.completed };
        } else {
          t;
        };
      },
    );
    return found;
  };

  public shared ({ caller }) func toggleTaskImportance(task_id : Nat) : async Bool {
    var found = false;
    tasks := Array.map<Task, Task>(
      tasks,
      func(t) {
        if (t.id == task_id and t.owner == caller) {
          found := true;
          {
            t with
            important = not t.important;
            importance_level = if (not t.important) { "High Priority" } else {
              "Low Priority";
            };
          };
        } else {
          t;
        };
      },
    );
    return found;
  };

  public shared ({ caller }) func getTasks() : async [Task] {
    Array.filter<Task>(tasks, func(t) { t.owner == caller });
  };
  public shared ({ caller }) func getImportantTasks() : async [Task] {
    Array.filter<Task>(tasks, func(t) { t.owner == caller and t.important });
  };

  public shared ({ caller }) func getCompletedTasks() : async [Task] {
    Array.filter<Task>(tasks, func(t) { t.owner == caller and t.completed });
  };

  public shared ({ caller }) func getTaskCountForDay(date : Text) : async Nat {
    let tasksForDay = Array.filter<Task>(
      tasks,
      func(t) {
        t.owner == caller and t.date_added == date
      },
    );
    return tasksForDay.size();
  };

  public shared ({ caller }) func deleteTask(task_id : Nat) : async Bool {
    let initialSize = tasks.size();
    tasks := Array.filter<Task>(tasks, func(t) { not (t.id == task_id and t.owner == caller) });
    return tasks.size() < initialSize;
  };
};
