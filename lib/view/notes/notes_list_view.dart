import 'package:flutter/material.dart';
import '../../services/cloud/cloud_note.dart';
import '../../utilities/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
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
              onTap(notes.elementAt(index));
            },
            title: Text(
              notes.elementAt(index).text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async{
                final shouldDelete = await showDeleteDialog(context);
                if(shouldDelete){
                  onDeleteNote(notes.elementAt(index));
                }
              },
            ),
          );
        }
    );
  }
}
