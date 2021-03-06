import '../dmlocal.dart';

class ProdutosModel {
  factory ProdutosModel.fromJson(Map<String, dynamic> json) {
    Basedados.instance.addProduto(
      Produto(
        id: json['ID'],
        nome: json['NOME'],
        idcategoria: json['IDCATEGORIA'],
        unidade: json['UNIDADE'] ?? 'UND',
        preco: json['PRECO'] ?? 0,
        valorfmt: json['VALORFMT'] ?? 'R\$ 0.00',
        quant: 0,
        total: '',
      ),
    );
    return null;
  }
}
