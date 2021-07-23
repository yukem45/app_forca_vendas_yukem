import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../app_controller.dart';

class BotaoAcessar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrlApp = Modular.get<AppController>();
    return Observer(
      builder: (_) {
        return Visibility(
          visible: (ctrlApp.ip.isNotEmpty &&
              ctrlApp.usuario.isNotEmpty &&
              ctrlApp.senha.isNotEmpty),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xff46997D),
                  offset: Offset(1, 6),
                  blurRadius: 20,
                ),
              ],
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xff317183),
                  Color(0xff46997D),
                ],
              ),
            ),
            margin: EdgeInsets.only(top: 180),
            child: MaterialButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 42),
                  child: Text(
                    'ENTRAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                onPressed: () async {
                  await ctrlApp.gravarArqIni();
                  var url = ctrlApp.loginRemoto;
                  print(url);
                  print('login>>>> ' + ctrlApp.login);
                  print('id>>>> ' + ctrlApp.idUsuario.toString());
                  print('ip>>>> ' + ctrlApp.ip);
                  if (ctrlApp.idUsuario != 0) {
                    Modular.to.pushNamed('menu');
                  } else {
                    Modular.to.pushNamed('config');
                  }
                }),
          ),
        );
      },
    );
  }
}
