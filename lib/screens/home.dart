import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskova/model/storage.dart';
import 'package:taskova/model/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  // form fields
  String? _title;
  String? _description;
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  // initial loading variables section
  bool _initialLoadingBool = false;

  final _formKey = GlobalKey<FormState>();

  void sortTasks() {
    tasks.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
  }

  Future<void> _removeTask(Task task, int index) async {
    setState(() {
      tasks.remove(task);
    });
    _removeSnackBar(task, index);
    sortTasks();
    await StorageClass.saveTasks(tasks);
  }

  Future<void> _addNewTask(StateSetter updateBottomSheet) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTask = Task(
        _title!,
        _description!,
        dateTime: (_pickedDate != null && _pickedTime != null)
            ? DateTime(
                _pickedDate!.year,
                _pickedDate!.month,
                _pickedDate!.day,
                _pickedTime!.hour,
                _pickedTime!.minute,
              )
            : DateTime.now().add(Duration(days: 1)),
      );
      if (_taskCheck(newTask)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: EdgeInsets.all(15),
            elevation: 10,
            persist: false,
            duration: Duration(seconds: 1),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            content: Text(
              'Task already exists',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        setState(() {
          tasks.add(newTask);
        });
      }
      sortTasks();
      await StorageClass.saveTasks(tasks);
      _pickedDate = null;
      _pickedTime = null;
      updateBottomSheet(() {});
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  bool _taskCheck(Task task) {
    return tasks.any((item) => task.hashedValue == item.hashedValue);
  }

  Future<void> openDateTimePopUp(StateSetter updateBottomSheet) async {
    TimeOfDay? selectedTime;
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      _pickedDate = selectedDate;
      selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        _pickedTime = selectedTime;
      } else {
        DateTime currentTime = DateTime.now();
        _pickedTime = TimeOfDay(
          hour: currentTime.hour,
          minute: currentTime.minute,
        );
      }
    } else {
      DateTime currentDateTime = DateTime.now().add(Duration(days: 1));
      _pickedDate = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
      );
      _pickedTime =
          _pickedTime ??
          TimeOfDay(hour: currentDateTime.hour, minute: currentDateTime.minute);
    }
    setState(() {
      selectedDate = null;
      selectedTime = null;
      updateBottomSheet(() {});
    });
  }

  Future<void> _addModelSheet() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setBottomSheet) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        maxLength: 20,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Provide a Valid Title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value;
                        },
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Title',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        maxLength: 30,
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          _description = value;
                        },
                        decoration: InputDecoration(
                          label: Text('Description'),
                          labelStyle: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _pickedDate == null
                              ? TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                  label: Text('Pick Date & Time'),
                                  icon: Icon(Icons.lock_clock),
                                  onPressed: () =>
                                      openDateTimePopUp(setBottomSheet),
                                )
                              : TextButton(
                                  key: Key('ShowDateTimekey'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondary,
                                  ),
                                  onPressed: () =>
                                      openDateTimePopUp(setBottomSheet),
                                  child: Text(
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    DateFormat.yMMMMd().add_jm().format(
                                      DateTime(
                                        _pickedDate!.year,
                                        _pickedDate!.month,
                                        _pickedDate!.day,
                                        _pickedTime!.hour,
                                        _pickedTime!.minute,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondary,
                        ),
                        onPressed: () => _addNewTask(setBottomSheet),
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fetch Tasks at Initial Load
  Future<void> _getInitalTasks() async {
    setState(() {
      _initialLoadingBool = true;
    });
    tasks = await StorageClass.getTasks();
    setState(() {
      _initialLoadingBool = false;
    });
  }

  // Snack Bar After removal of the task
  void _removeSnackBar(Task task, int index) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            padding: EdgeInsets.all(10),
            elevation: 10,
            persist: false,
            duration: Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            content: Text(
              '${task.title} Task Removed',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
            action: SnackBarAction(
              key: Key('HomeUndoKey'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: 'Undo',
              onPressed: () => _undoSnackbar(task, index),
              textColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        )
        .closed
        .then((reason) {
          if (!mounted) return;
          if (!ScaffoldMessenger.of(context).mounted) return;
        });
  }

  Future<void> _undoSnackbar(Task task, int index) async {
    setState(() {
      tasks.insert(index, task);
    });
    await StorageClass.saveTasks(tasks);
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  // Init State of the Widget -> To Perform initialise activities before build
  @override
  void initState() {
    super.initState();
    _getInitalTasks();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_initialLoadingBool) {
      content = SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (tasks.isEmpty) {
      content = SliverFillRemaining(
        child: Center(
          child: Text(
            'No Tasks Present',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    } else {
      content = SliverList.builder(
        itemCount: tasks.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: Key(tasks[index].id),
            direction: DismissDirection.startToEnd,
            background: Container(color: Colors.redAccent),
            onDismissed: (direction) {
              _removeTask(tasks[index], index);
            },
            child: ListTile(
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat.yMMMMd().add_jm().format(tasks[index].dateTime!),
                  ),
                ],
              ),
              leadingAndTrailingTextStyle: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontWeight: FontWeight.bold),
              title: Text(tasks[index].title),
              titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: tasks[index].dateTime!.isAfter(DateTime.now())
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              subtitleTextStyle: Theme.of(context).textTheme.bodySmall!
                  .copyWith(
                    color: tasks[index].dateTime!.isAfter(DateTime.now())
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
              subtitle: Text(tasks[index].description),
            ),
          );
        },
      );
    }
    return Scaffold(
      body: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            padding: EdgeInsets.all(18),
          ),
          onPressed: _addModelSheet,
          label: Text('Task', style: Theme.of(context).textTheme.bodyLarge),
          icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
        ),
        body: RefreshIndicator(
          color: Theme.of(context).colorScheme.onSurface,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                title: Text(
                  'Taskova',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
