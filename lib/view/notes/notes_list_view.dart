import 'package:flutter/material.dart';
import '../../services/crud/notes_service.dart';
import '../../utilities/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  NotesListView({required this.notes, required this.onDeleteNote, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index){
          return ListTile(
            onTap: (){
              onTap(notes[index]);
            },
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
