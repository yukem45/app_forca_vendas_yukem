import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app_controller.dart';

class PaginaConfig extends StatelessWidget {
  final TextEditingController ipControler;

  const PaginaConfig({Key key, @required this.ipControler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrlApp = Modular.get<AppController>();
    ipControler.text = ctrlApp.ip;
    return Container(
      padding: EdgeInsets.only(top: 23),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: 300,
                  height: 190,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                        child: Observer(
                          builder: (BuildContext context) {
                            return TextField(
                              controller: ipControler,
                              onChanged: ctrlApp.updIP,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(FontAwesomeIcons.networkWired,
                                    color: Colors.black, size: 22),
                                hintText: 'Ip do servidor',
                                hintStyle: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 1,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15,
                          bottom: 10,
                          left: 25,
                          right: 25,
                        ),
                        child: Text(
                          'Força de vendas',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 15,
                          bottom: 10,
                          left: 25,
                          right: 25,
                        ),
                        child: Text(
                          'www.comtecnologia.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
