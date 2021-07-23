import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../app/datamodule/dmlocal.dart';
import '../../../app/modules/shared/icon_header.dart';

import '../../app_controller.dart';

class PedidoList extends StatefulWidget {
  @override
  _PedidoListState createState() => _PedidoListState();
}

class _PedidoListState extends ModularState<PedidoList, AppController> {
  final SlidableController slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                IconeHeader(
                  icone: Icons.shopping_cart,
                  titulo: 'Pedidos registrados',
                  cor1: Color(0xff317183),
                  cor2: Color(0xff46997D),
                  altura: 200,
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 40,
                    onPressed: () {
                      Modular.to.pop();
                    },
                    color: Colors.white,
                  ),
                ),
                Positioned(
                    bottom: 15,
                    right: 15,
                    child: Observer(
                      builder: (_) {
                        return Text(
                          controller.totPed.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w600),
                        );
                      },
                    ))
              ],
            ),
            SizedBox(height: 10),
            Observer(builder: (BuildContext context) {
              return Expanded(
                child: StreamBuilder<List<Pedido>>(
                  stream: Basedados.instance.getPedidos(),
                  initialData: [],
                  builder: (context, snapshot) {
                    List<Pedido> ped = snapshot.data;
                    if (!snapshot.hasData || snapshot.data.length == 0) {
                      return Center(child: Text('Nada encontrado'));
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: ped.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Slidable(
                                key: Key(ped[index].id),
                                controller: slidableController,
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
                                child: Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(
                                        Icons.account_circle,
                                        size: 40,
                                      ),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nr pedido: ' + ped[index].id,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          ped[index].nomecliente,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text(
                                          ped[index].datapedido,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Spacer(),
                                        Text(
                                          ped[index].totalfmt,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  IconSlideAction(
                                    caption: 'Excluir',
                                    color: Colors.red,
                                    icon: Icons.delete,
                                    closeOnTap: true,
                                    onTap: () async {
                                      String _id = ped[index].id;
                                      await Basedados.instance.delPedidoId(_id);
                                      await Basedados.instance
                                          .delItensPedido(_id);

                                      int _totPed =
                                          await Basedados.instance.countPe();
                                      controller.updTotPed(_totPed);
                                      controller.gravarArqIni();
                                    },
                                  ),
                                ],
                                // secondaryActions: [
                                //   IconSlideAction(
                                //     caption: 'Excluir',
                                //     color: Colors.red,
                                //     icon: Icons.delete,
                                //     closeOnTap: true,
                                //     onTap: () async {
                                //       String _id = ped[index].id;
                                //       await Basedados.instance.delPedidoId(_id);
                                //       await Basedados.instance
                                //           .delItensPedido(_id);

                                //       int _totPed =
                                //           await Basedados.instance.countPe();
                                //       controller.updTotPed(_totPed);
                                //       controller.gravarArqIni();
                                //     },
                                //   ),
                                // ],
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
