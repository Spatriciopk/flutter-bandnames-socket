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
    id: obj['id'], 
    name: obj['name'], 
    votes: obj['votes']
    );
}