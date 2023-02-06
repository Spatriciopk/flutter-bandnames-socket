class Band{
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes
  });

  /* El socket va devolver un mapa */

  /*Factory constructor que va a devolñver una nueva instancia
  de mi clase band */

  factory Band.fromMap(Map<String,dynamic> obj) 
  => Band(
    id: obj.containsKey("id") ? obj['id']:"no-id", 
    name: obj.containsKey("name") ? obj['name']:"no-name",
    votes: obj.containsKey("votes") ? obj['votes']:"no-votes",
    );
}