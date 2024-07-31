import 'package:sozluk_projesi/db/models/lists.dart';
import 'package:sozluk_projesi/db/models/words.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB{

  static final DB instance = DB._init();
  static Database? _database;

  DB._init();

  Future<Database> get database async{

    if(_database != null) return _database!;

    _database = await _initDB('quezy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async{
    final path = join(await getDatabasesPath(),filePath);
    return await openDatabase(path,version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db,int version) async{

    final idType= 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType= 'BOOL NOT NULL';
    final integerType= 'INTEGER NOT NULL';
    final textType= 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS  $tableNameLists (
      ${ListTableFields.id} $idType,
      ${ListTableFields.name} $textType
      )
    ''');

    await db.execute('''
     CREATE TABLE IF NOT EXISTS  $tableNameWords (
     ${WordTableFields.id} $idType,
     ${WordTableFields.list_id} $integerType,
     ${WordTableFields.word_eng} $textType,
     ${WordTableFields.word_tr} $textType,
     ${WordTableFields.status} $boolType,
     FOREIGN KEY(${WordTableFields.list_id}) REFERENCES $tableNameLists (${ListTableFields.id}))
    ''');
  }

  // Liste eklemek için gerekli method
  Future<Lists> insertList(Lists lists) async{
    final db = await instance.database;
    final id =await db.insert(tableNameLists, lists.toJson());

    return lists.copy(id: id);
  }
// kelime eklemek için gerekli method
  Future<Word> insertWord(Word word) async{
    final db= await instance.database;
    final id =await db.insert(tableNameWords, word.toJson());

    return word.copy(id: id);
  }
  // listeye göre kelimeleri getirmek için gerekli method
  Future<List<Word>> readWordByList(int? listID) async{
    final db = await instance.database;
    final orderBy= '${WordTableFields.id} ASC';
    final result = await db.query(tableNameWords,orderBy: orderBy,where: '${WordTableFields.list_id} = ?',whereArgs: [listID]);

    return result.map((json) => Word.fromJson(json)).toList();
  }

  // tüm listeleri getiren method
  Future<List<Map<String,Object?>>> readListsAll() async{
    final db = await instance.database;

    List<Map<String,Object?>> res=[];
    List<Map<String,Object?>> lists= await db.rawQuery("SELECT id,name FROM lists");

    await Future.forEach(lists, (element) async {
      //burda listedeki kelime sayısı ve öğrenilmeyen kelime sayısnın alıyoruz.
      var wordInfoByList= await db.rawQuery(
          "SELECT(SELECT COUNT(*) FROM words where list_id=${element['id']}) as sum_word,"
          "(SELECT COUNT(*) FROM words where status=0 and list_id=${element['id']}) as sum_unlearned");

      Map<String,Object?> temp= Map.of(wordInfoByList[0]);
      temp["name"]=element["name"];
      temp["list_id"]=element["id"];
      res.add(temp);
    });
    print(res);

    return res;
  }

  Future<List<Word>> readWordByLists(List<int> listsID,{bool ?status}) async{
    final db = await instance.database;
    String idList="";
    for(int i =0; i<listsID.length;++i){
      if(i==listsID.length-1){
        idList+=(listsID[i].toString());
      }
      else{
        idList+=("${listsID[i]},");
      }
    }


    List<Map<String,Object?>> result;

    if(status!=null){
     // result= await db.rawQuery('SELECT * FROM WORDS  WHERE list_id IN('+idList+') and status='+(status?"1":"0")+'');
      result= await db.rawQuery('SELECT * FROM WORDS  WHERE list_id IN($idList) and status=${status?"1":"0"}');
    }
    else{
     // result= await db.rawQuery('SELECT * FROM WORDS  WHERE list_id IN('+idList+')');
      result= await db.rawQuery('SELECT * FROM WORDS  WHERE list_id IN($idList)');
    }

    return result.map((json) => Word.fromJson(json)).toList();
  }

  // kelime güncelleme
  Future<int> updateWord(Word word) async{
    final db = await instance.database;
    return db.update(tableNameWords, word.toJson(),where: '${WordTableFields.id} = ?', whereArgs: [word.id]);
  }

  // liste güncelleme
  Future<int> updateList(Lists lists) async{
    final db = await instance.database;
    return db.update(tableNameLists, lists.toJson(),where: '${ListTableFields.id} = ?', whereArgs: [lists.id]);
  }

  //kelime silme
  Future<int> deleteWord(int id) async{
    final db = await instance.database;
    return db.delete(tableNameWords,where: '${WordTableFields.id} = ?',whereArgs: [id]);
  }

  //Önce bir liste silen ve daha sonra silinen listedeki kelimeleri silen method
  Future<int> deleteListsAndWordByList(int id) async{
    final db = await instance.database;
    int result = await db.delete(tableNameLists,where: '${ListTableFields.id} = ?',whereArgs: [id]);
    if(result==1){
      await db.delete(tableNameWords,where: '${WordTableFields.id} = ?',whereArgs: [id]);
    }

    return result;

  }
  //bir kelimeyi öğrenildi olarak işaretleyen method
  Future<int> markAsLearned(bool mark,int id) async{
    final db=await instance.database;
    int result= mark ==true ? 1 :0;
    return db.update(tableNameWords,{WordTableFields.status:result},where: '${WordTableFields.id} = ?',whereArgs: [id]);
  }
  
  Future close() async{
    final db = await instance.database;
    db.close();
  }

}