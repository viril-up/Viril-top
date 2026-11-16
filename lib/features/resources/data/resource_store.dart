import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ResourceStore extends ChangeNotifier{
  ResourceStore._();static final instance=ResourceStore._();
  static const _favoritesKey='viril.resource_favorites.v1',_notesKey='viril.resource_notes.v1',_progressKey='viril.book_progress.v1',_bookmarksKey='viril.bookmarks.v1',_bookNotesKey='viril.book_notes.v1';
  Set<String> _favorites={};Map<String,String> _notes={};Map<String,int> _progress={};Map<String,List<int>> _bookmarks={};Map<String,String> _bookNotes={};String _journal='';bool _ready=false;
  bool get isReady=>_ready;Set<String> get favorites=>Set.unmodifiable(_favorites);Map<String,String> get notes=>Map.unmodifiable(_notes);
  bool isFavorite(String id)=>_favorites.contains(id);String noteFor(String id)=>_notes[id]??'';
  int pageForBook(String id)=>_progress[id]??1;List<int> bookmarksForBook(String id)=>List.unmodifiable(_bookmarks[id]??const []);
  String noteForBookPage(String id,int page)=>_bookNotes['$id:$page']??'';
  String get journal=>_journal;
  Future<void> initialize()async{
    if(_ready)return;final p=await SharedPreferences.getInstance();_favorites=(p.getStringList(_favoritesKey)??[]).toSet();_notes={};
    for(final k in p.getKeys().where((k)=>k.startsWith(_notesKey))){final v=p.getString(k);if(v!=null)_notes[k.substring(_notesKey.length)]=v;}
    _progress={};for(final e in p.getStringList(_progressKey)??[]){final i=e.lastIndexOf('|');if(i>0)_progress[e.substring(0,i)]=int.tryParse(e.substring(i+1))??1;}
    _bookmarks={};for(final e in p.getStringList(_bookmarksKey)??[]){final i=e.lastIndexOf('|');if(i>0){final id=e.substring(0,i),page=int.tryParse(e.substring(i+1));if(page!=null)(_bookmarks[id]??=[]).add(page);}}
    _bookNotes={};for(final k in p.getKeys().where((k)=>k.startsWith(_bookNotesKey))){final v=p.getString(k);if(v!=null)_bookNotes[k.substring(_bookNotesKey.length)]=v;}
    _journal=p.getString(_journalKey)??'';_ready=true;notifyListeners();
  }
  Future<void> toggleFavorite(String id)async{_favorites.contains(id)?_favorites.remove(id):_favorites.add(id);final p=await SharedPreferences.getInstance();await p.setStringList(_favoritesKey,_favorites.toList());notifyListeners();}
  Future<void> saveNote(String id,String note)async{final s=note.trim(),p=await SharedPreferences.getInstance();if(s.isEmpty){_notes.remove(id);await p.remove('$_notesKey$id');}else{_notes[id]=s;await p.setString('$_notesKey$id',s);}notifyListeners();}
  Future<void> saveBookPage(String id,int page)async{_progress[id]=page<1?1:page;final p=await SharedPreferences.getInstance();await p.setStringList(_progressKey,_progress.entries.map((e)=>'${e.key}|${e.value}').toList());notifyListeners();}
  Future<void> toggleBookBookmark(String id,int page)async{final a=_bookmarks[id]??=[];a.contains(page)?a.remove(page):a.add(page);a.sort();final p=await SharedPreferences.getInstance();await p.setStringList(_bookmarksKey,_bookmarks.entries.expand((e)=>e.value.map((n)=>'${e.key}|$n')).toList());notifyListeners();}
  Future<void> saveJournal(String value)async{_journal=value;final p=await SharedPreferences.getInstance();await p.setString(_journalKey,value);notifyListeners();}
  Future<void> saveBookPageNote(String id,int page,String note)async{final k='$id:$page',s=note.trim(),p=await SharedPreferences.getInstance();if(s.isEmpty){_bookNotes.remove(k);await p.remove('$_bookNotesKey$k');}else{_bookNotes[k]=s;await p.setString('$_bookNotesKey$k',s);}notifyListeners();}
}
