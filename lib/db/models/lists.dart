final String tableNameLists="lists";

class ListTableFields{
  static final List<String> values = [
    id,name
  ];

  static final String id="id";
  static final String name="name";
}


class Lists{
  final int ?id;
  final String ?name;

  const Lists({this.id, this.name});

  Lists copy({int ?id, String ?name})
  {
    return Lists(
      id: id ?? this.id,
      name:name ?? this.name
    );
  }

  Map<String,Object?> toJson()=> {
    ListTableFields.id: id,
    ListTableFields.name: name
  };

  static Lists fromJson(Map<String,Object?> json)=>Lists(
    id: json[ListTableFields.id] as int?,
    name: json[ListTableFields.name] as String?,
  );

}