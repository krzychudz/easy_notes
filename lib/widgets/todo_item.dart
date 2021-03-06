import 'package:easy_notes/models/task.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_item_mange_modal.dart';

import '../widgets/delete_confirmation_dialog.dart' as DialogHelper;
import '../provider/tasks_provider.dart';

class TodoItem extends StatelessWidget {
  final String todoTitle;
  final String todoId;
  final Color backgroundColor;
  final bool isDone;
  final String workingTime;

  TodoItem({
    this.todoId,
    this.todoTitle,
    this.backgroundColor,
    this.isDone,
    this.workingTime,
  });

  void showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (bCtx) => MangeTodoItemModal(
        taskId: todoId,
        taskName: todoTitle,
        backgroundColor: backgroundColor,
        workingTime: workingTime,
        doneStatus: isDone,
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    DialogHelper.showConfirmationDialog(
        buildContext: context,
        title: !isDone
            ? "Are you sure you want to move this task to DONE section?"
            : "Do you want to mark this task as TODO?",
        negativeButtonCallback: () => Navigator.of(context).pop(false),
        possitiveButtonCallback: () async {
          Navigator.of(context).pop();
          setItemDoneState(!isDone, context);
        });
  }

  Future<void> setItemDoneState(bool isDone, BuildContext context) async {
    Provider.of<TasksProvider>(context, listen: false).updateTask(
      todoId,
      TaskModel.toObject(
        {
          "id": todoId,
          "title": todoTitle,
          "alpha": backgroundColor.alpha,
          "red": backgroundColor.red,
          "blue": backgroundColor.blue,
          "green": backgroundColor.green,
          "duration": workingTime,
          "isDone": isDone == true ? 1 : 0,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        padding: EdgeInsets.only(right: 16.0),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (dismissDirection) async {
        return await DialogHelper.showConfirmationDialog(
          buildContext: context,
          title: 'Do you want to remove this item?',
          possitiveButtonCallback: () => Navigator.of(context).pop(true),
          negativeButtonCallback: () => Navigator.of(context).pop(false),
        );
      },
      onDismissed: (direction) async {
        var removeResult =
            await Provider.of<TasksProvider>(context, listen: false)
                .removeTask(todoId);
        if (removeResult == 1) {
          return true;
        }
        return false;
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        color: backgroundColor,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Text(
                    todoTitle,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text('$workingTime min'),
                ],
              ),
              SizedBox(
                width: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: Icon(
                      !isDone ? Icons.done : Icons.close,
                      color: Theme.of(context).accentColor,
                      size: 18,
                    ),
                    onTap: () => showConfirmationDialog(context),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).accentColor,
                      size: 18,
                    ),
                    onTap: () => showEditBottomSheet(context),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
