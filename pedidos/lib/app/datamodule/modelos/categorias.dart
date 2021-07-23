import '../dmlocal.dart';

class CategoriasModel {
  factory CategoriasModel.fromJson(Map<String, dynamic> json) {
    Basedados.instance.addCategoria(
      Categoria(
        id: json['ID'],
        nome: json['NOME'],
      ),
    );
    return null;
  }
}
