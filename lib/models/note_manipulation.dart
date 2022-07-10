import 'package:json_annotation/json_annotation.dart';

part 'note_manipulation.g.dart';

@JsonSerializable()
class NoteManipulation{
  String noteTitle;
  String noteContent;
  NoteManipulation({required this.noteTitle,required this.noteContent});

  Map<String, dynamic> toJson() => _$NoteManipulationToJson(this);
}