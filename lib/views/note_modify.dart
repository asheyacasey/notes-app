import 'package:flutter/material.dart';
import 'package:yuson_api_exercise/services/note_service.dart';
import 'package:yuson_api_exercise/models/note_manipulation.dart';
import 'package:yuson_api_exercise/models/note.dart';

class NoteModify extends StatefulWidget {

  final String noteID;
  const NoteModify({required this.noteID});

  @override
  State<NoteModify> createState() => _NoteModifyState();
}

class _NoteModifyState extends State<NoteModify> {
  bool get isEditing => widget.noteID != '';

  final service=NotesService();
  String? errorMessage; bool _addLoading=false;
  Note? note; bool _isLoading=false;
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _contentController=TextEditingController();

  @override
  void initState() {
    super.initState();
    if(isEditing){
      setState(() { _isLoading=true; });

      service.getNote(widget.noteID).then((response){
        setState(() { _isLoading=false; });

        if(response.error){
          errorMessage=response.errorMessage??'an error occured';
        }
        note=response.data;
        _titleController.text=note!.noteTitle;
        _contentController.text=note!.noteContent;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(isEditing ? 'Edit note' : 'Create note')),
      body: _isLoading? const Center( child: SingleChildScrollView(child: CircularProgressIndicator())):
      Stack(
        children: [
         ListView(
            children: <Widget>[
              const SizedBox(height: 9,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  style: const TextStyle(fontSize: 21),
                  controller: _titleController,
                  decoration: const InputDecoration(
                      hintText: 'Note title',
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null, style: const TextStyle(fontSize: 20),
                    controller: _contentController,
                    decoration: const InputDecoration(
                        hintText: 'Note content',
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none
                    ),
                  ),
                ),
              ),

              // Spacer(),
              Container(
                width: double.infinity,
                height: 50,decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.pink,Colors.cyan
                      ]
                  )
              ),
                child: ElevatedButton(
                  child: const Text('Submit', style: TextStyle(color: Colors.white,fontSize: 20)),
                  // color: Colors.transparent,
                  onPressed: () async{
                    if(isEditing){

                      final noteUpdate = NoteManipulation(
                          noteTitle: _titleController.text,
                          noteContent: _contentController.text);
                      setState(()=> _addLoading=true);
                      final result = await service.updateNote(widget.noteID,noteUpdate);
                      setState(()=> _addLoading=false);
                      var content;
                      if(result.error){
                        content=result.errorMessage??'an error occered';
                      }else{
                        content='note updated';
                      }
                      showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: const Text('Done'),
                                content:Text(content),
                                actions: <Widget>[
                                 TextButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text('ok'))
                                ],
                              )).then((data) {
                        if(result.data!){
                          Navigator.of(context).pop(false);
                        }
                      });

                    }else {
                      final noteInsert = NoteManipulation(
                          noteTitle: _titleController.text,
                          noteContent: _contentController.text);
                      setState(()=> _addLoading=true);
                      final result = await service.createNote(noteInsert);
                      setState(()=> _addLoading=false);
                      String content=result.error?(result.errorMessage??"an error occured"):'note added';
                      showDialog(context: context,
                          builder: (_) =>
                              AlertDialog(
                                title: const Text('Done'),
                                content:Text(content),
                                actions: <Widget>[
                                  TextButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text('ok'))
                                ],
                              )).then((data) {
                        if(result.data!){
                          Navigator.of(context).pop(_titleController.text);
                        }
                      });
                    }
                  },
                ),
              )
            ],
          ),
          _addLoading?const Center(child: CircularProgressIndicator()):const SizedBox()
        ],
      ),
    );
  }
}