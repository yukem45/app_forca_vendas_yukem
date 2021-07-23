import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app_controller.dart';
import 'botao_acessar.dart';

class PaginaAcessar extends StatelessWidget {
  final TextEditingController userControler;
  final TextEditingController senhaControler;

  const PaginaAcessar({Key key, this.userControler, this.senhaControler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrlApp = Modular.get<AppController>();
    userControler.text = ctrlApp.usuario;
    senhaControler.text = ctrlApp.senha;
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
                        child: TextField(
                          controller: userControler,
                          onChanged: ctrlApp.updUsuario,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(FontAwesomeIcons.user,
                                color: Colors.black, size: 22),
                            hintText: 'Usuário',
                            hintStyle:
                                TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 1,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                        child: Observer(
                          builder: (BuildContext context) {
                            return TextField(
                              obscureText: !ctrlApp.senhaVisivel,
                              controller: senhaControler,
                              onChanged: ctrlApp.updSenha,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(FontAwesomeIcons.lock,
                                      color: Colors.black, size: 22),
                                  hintText: 'Senha',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  suffixIcon: GestureDetector(
                                    onTap: ctrlApp.mudaSenha,
                                    child: Icon(
                                      !ctrlApp.senhaVisivel
                                          ? FontAwesomeIcons.eye
                                          : FontAwesomeIcons.eyeSlash,
                                      size: 22,
                                      color: Colors.black,
                                    ),
                                  )),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotaoAcessar(),
            ],
          ),
        ],
      ),
    );
  }
}
