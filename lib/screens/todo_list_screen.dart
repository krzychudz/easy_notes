import 'package:easy_notes/provider/tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/task_progress_bar/task_progress_bar.dart';
import '../widgets/todo_item_mange_modal.dart';
import '../helpers/todo_helper.dart' as TodoHelper;
import '../widgets/delete_confirmation_dialog.dart' as ConfirmationDialog;
import '../helpers/date_helper.dart' as Date;
import '../models/task.dart';

class TodoListScreen extends StatelessWidget {
  void _showBottomModalSheet(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (bCtx) => MangeTodoItemModal(),
    );
  }

  void _clearAllTasks(BuildContext ctx) {
    ConfirmationDialog.showConfirmationDialog(
      buildContext: ctx,
      title: 'Do you want to clear ALL tasks?',
      possitiveButtonCallback: () async {
        Provider.of<TasksProvider>(ctx, listen: false).removeAllTasks();
        Navigator.of(ctx).pop();
      },
      negativeButtonCallback: () {
        Navigator.of(ctx).pop();
      },
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, BuildContext context) {
    if (tasks == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Text("You have no todo task. To add one click on the + button."),
      );
    }

    List<Widget> list = TodoHelper.preapreFinalList(tasks, context);

    return ListView.builder(
      itemBuilder: (ctx, index) => list[index],
      itemCount: list.length,
    );
  }

  int recalculatePercentageOfDone(List<TaskModel> tasks) {
    if (tasks == null || tasks.length == 0) {
      return 0;
    }

    final numberOfTasks = tasks.length;
    final numberOfDone = tasks.where((element) => element.isDone).length;

    return numberOfTasks == 0 ? 0 : numberOfDone * 100 ~/ numberOfTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("${Date.getCurrentDate()}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.clear_all,
            ),
            onPressed: () => _clearAllTasks(context),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () => _showBottomModalSheet(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<TasksProvider>(
                builder: (ctx, tasksProvider, _) {
                  return _buildTaskList(tasksProvider.tasks, context);
                },
              ),
            ),
          ),
          Consumer<TasksProvider>(builder: (ctx, tasksProvider, _) {
            return TaskProgressBar(
              recalculatePercentageOfDone(tasksProvider.tasks),
            );
          }),
        ],
      ),
    );
  }
}
