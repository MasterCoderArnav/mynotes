import 'package:flutter/material.dart';
import '../../services/crud/notes_service.dart';
import '../../utilities/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  NotesListView({required this.notes, required this.onDeleteNote});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(
              notes[index].text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async{
                final shouldDelete = await showDeleteDialog(context);
                if(shouldDelete){
                  onDeleteNote(notes[index]);
                }
              },
            ),
          );
        }
    );
  }
}
