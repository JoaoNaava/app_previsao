class CityModel {
  int? id;
  String? nome;

  CityModel({this.id, this.nome});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }
}
