import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_touch_spin/flutter_touch_spin.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:money2/money2.dart';
import 'package:intl/intl.dart';

import 'package:pedidos/app/modules/shared/format.dart';
import '../../../app/datamodule/dmlocal.dart';
import '../../app_controller.dart';

class PedProduto extends StatefulWidget {
  @override
  _PedProdutoState createState() => _PedProdutoState();
}

class _PedProdutoState extends ModularState<PedProduto, AppController> {
  TextEditingController _nomeProd = TextEditingController();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          color: Color(0xff46997D),
          child: Row(
            children: [
              SizedBox(
                height: 40,
                width: 15,
              ),
              OutlineButton(
                onPressed: () async {
                  var _t = await Basedados.instance.subtotalVenda();
                  int _ts = _t ?? 0;
                  if (_ts > 0) {
                    await Basedados.instance.zeraProduto();
                  }
                  Modular.to.popUntil(ModalRoute.withName('menu'));
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Spacer(),
              Observer(
                builder: (_) {
                  return Text(
                    controller.pedidoSubtotal,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  );
                },
              ),
              Spacer(),
              OutlineButton(
                onPressed: () async {
                  if (controller.pedidototal > 0) {
                    await Basedados.instance.addPedido(
                      Pedido(
                          id: controller.pedidoCodigo,
                          idvendedor: controller.idUsuario,
                          idcliente: controller.pedidoClienteId,
                          nomecliente: controller.pNomeCliente,
                          datapedido: Jiffy().format('dd[/]MM[/]yyyy'),
                          total: controller.pedidototal,
                          totalfmt: controller.pedidoSubtotal,
                          enviado: 0),
                    );
                    await Basedados.instance
                        .gravaItens(controller.pedidoCodigo);
                    await Basedados.instance.zeraProduto();

                    controller.updpedidototal(0);
                  }

                  int _totped = await Basedados.instance.countPe();
                  controller.updTotPed(_totped);
                  controller.gravarArqIni();

                  Modular.to.popUntil(ModalRoute.withName('menu'));
                },
                child: Text(
                  'Gravar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 15),
            Stack(
              children: [
                Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'N?? do Pedido: ${controller.pedidoCodigo}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          controller.pNomeCliente,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff317183),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Data do registro:' +
                              Jiffy().format('dd[/]MM[/]yyyy [??s] hh:mm'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Selecione os produtos do pedido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff317183),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 60,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: TextField(
                  controller: _nomeProd,
                  onChanged: (value) async {
                    controller.updnomeProduto(value);
                  },
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  style: TextStyle(
                    color: Color(0xff317183),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Color(0xff317183).withOpacity(0.2),
                    filled: true,
                    labelText: 'Localizar',
                    prefixIcon: Icon(
                      FontAwesomeIcons.search,
                      color: Color(0xff317183),
                      size: 30,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _nomeProd.clear();
                        controller.updnomeProduto('');
                        FocusScope.of(context).unfocus();
                      },
                      child: Icon(
                        FontAwesomeIcons.eraser,
                        color: Color(0xff317183),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Observer(builder: (BuildContext context) {
              return Expanded(
                child: StreamBuilder<List<Produto>>(
                  stream: Basedados.instance.getProduto(controller.nomeProduto),
                  initialData: [],
                  builder: (context, snapshot) {
                    List<Produto> prod = snapshot.data;
                    if (!snapshot.hasData || snapshot.data.length == 0) {
                      return Center(child: Text('Nada encontrado'));
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: prod.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: ExpansionTileCard(
                                title: Text(
                                  prod[index].nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xff317183),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      prod[index].valorfmt +
                                          ' - ' +
                                          prod[index].unidade,
                                      style: TextStyle(
                                        color: Color(0xff46997D),
                                      ),
                                    ),
                                    Spacer(),
                                    prod[index].quant > 0
                                        ? Text(
                                            prod[index].total,
                                            style: TextStyle(
                                              color: Color(0xff46997D),
                                            ),
                                          )
                                        : Text(''),
                                  ],
                                ),
                                children: [
                                  Divider(
                                    thickness: 1,
                                    height: 1,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: TouchSpin(
                                        min: 0,
                                        //max: 100,
                                        step: 1,
                                        value: 0,
                                        displayFormat: NumberFormat.currency(
                                            locale: 'en_US', symbol: ''),
                                        textStyle: TextStyle(fontSize: 36),
                                        iconSize: 48.0,
                                        addIcon: Icon(Icons.add_circle_outline),
                                        subtractIcon:
                                            Icon(Icons.remove_circle_outline),
                                        iconActiveColor: Colors.green,
                                        iconDisabledColor: Colors.grey,
                                        iconPadding: EdgeInsets.all(20),
                                        onChanged: (val) async {
                                          // print(val);
                                          double _sTotal =
                                              val * prod[index].preco / 100;
                                          String _totalFormatado;
                                          _sTotal < double.tryParse('10')
                                              ? _totalFormatado = 'R\$ ' +
                                                  _sTotal.toStringAsPrecision(3)
                                              : _totalFormatado = 'R\$ ' +
                                                  _sTotal
                                                      .toStringAsPrecision(4);
                                          print(_totalFormatado);

                                          Basedados.instance.updProduto(
                                            Produto(
                                              id: prod[index].id,
                                              idcategoria:
                                                  prod[index].idcategoria,
                                              unidade: prod[index].unidade,
                                              preco: prod[index].preco,
                                              nome: prod[index].nome,
                                              quant: val,
                                              valorfmt: prod[index].valorfmt,
                                              total: _totalFormatado,
                                            ),
                                          );

                                          var _t = await Basedados.instance
                                              .subtotalVenda();
                                          int _ts = _t ?? 0;

                                          controller.updpedidototal(_ts);

                                          Currency ptBr = Currency.create(
                                              'BRL', 2,
                                              symbol: 'R\$ ');
                                          String _totalGeralFmt =
                                              Money.fromInt(_ts, ptBr)
                                                  .toString();

                                          controller.updpedidoSubtotal(
                                              _totalGeralFmt);
                                          print(controller.pedidoSubtotal);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
