import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import '../../../app/datamodule/dm_remoto.dart';
import '../../../app/datamodule/dmlocal.dart';
import '../../../app/app_controller.dart';
import '../../../app/modules/shared/botao_customizado.dart';
import '../../../app/modules/shared/icon_header.dart';
import '../../../app/modules/shared/item_listtile.dart';
import '../../../app/modules/shared/show_message.dart';

String nome = '';
int idcli = 0;

ProgressDialog pr;

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends ModularState<ConfigPage, AppController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Observer(builder: (_) {
            return IconeHeader(
              icone: FontAwesomeIcons.edit,
              titulo: 'Configurações',
              cor1: Color(0xff317183),
              cor2: Color(0xff46997D),
            );
          }),
          SizedBox(height: 10),
          ItemList(
            cor: Color(0xff317183),
            titulo: 'Lembrar usuário',
            subtitulo: 'Acessar automaticamente',
            item: Observer(builder: (_) {
              return Switch(
                  activeColor: Color(0xff317183),
                  value: controller.lembrarUsuario,
                  onChanged: (bool vlr) {
                    controller.updLembrarUsuario(vlr);
                  });
            }),
            icone: FontAwesomeIcons.userLock,
          ),
          ItemList(
            cor: Color(0xff46997D),
            titulo: 'Envio e recebimento',
            subtitulo: 'Somente via wifi',
            item: Observer(builder: (_) {
              return Switch(
                  activeColor: Color(0xff317183),
                  value: controller.lembrarWifi,
                  onChanged: (bool vlr) {
                    //setState(() {
                    controller.updWifi(vlr);
                    // });
                  });
            }),
            icone: FontAwesomeIcons.wifi,
          ),
          Expanded(child: Container()),
          BotaoInfo(
            icone: Icons.settings,
            cor1: Color(0xff317183),
            cor2: Color(0xff46997D),
            texto: 'Salvar e continuar',
            onPress: () async {
              //controller.gravarArqIni();
              if (controller.idUsuario != 0) {
                //grava as preferencias
                controller.gravarArqIni();
                Modular.to.popAndPushNamed('menu');
              } else {
                //tentar fazer o login
                await loginUsuario();
                //controller.
                controller.updIdUsuario(idcli);
                controller.updLogin(nome);

                await controller.gravarArqIni();

                if (idcli != 0) {
                  //baixar as tabelas se necessário
                  int c = await Basedados.instance.countCl();
                  if (c <= 0) {
                    pr = ProgressDialog(context);
                    pr.update(message: 'Atualizando Categorias...');
                    pr.show();
                    await buscaCategorias(controller.categoriaRemoto);
                    int ca = await Basedados.instance.countCa();
                    controller.updTotCat(ca);
                    pr.update(message: 'Atualizando Clientes...');
                    await buscaClientes(controller.clienteRemoto);
                    int cl = await Basedados.instance.countCl();
                    controller.updtotCli(cl);
                    pr.update(message: 'Atualizando Produtos...');
                    await buscaProdutos(controller.produtoRemoto);
                    int p = await Basedados.instance.countPr();
                    controller.updTotPro(p);
                    pr.hide();
                  }
                  controller.gravarArqIni();
                  Modular.to.popAndPushNamed('menu');
                } else {
                  showMessage(2, 'Erro', 'Usuário ou senha inválidos', context);
                  Modular.to.pushReplacementNamed('/');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<Usuario>> loginUsuario() async {
    try {
      //final response = await http.get(controller.loginRemoto);
      final response = await http.post(controller.loginRemoto,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {"dwaccesstag": 'UVZGREVTT0tIMTAwSFhB'});
      if (response.statusCode == 200) {
        //var s  base64.decode(response.bodyBytes);
        // var data = base64.decode(response.body);
        //print(data);
        ///String source = Utf8Decoder().convert(response.bodyBytes);
        print('Response.body: ' + response.body);
        if (response.body != 'erro') {
          print('Response.body: ' + response.body);

          List _usuario = json.decode(utf8.decode(response.bodyBytes));
          //var decode = utf8.decode(_usuario);
          //print(decode);
          //print('_usuario : ' + utf8.decode(_usuario).toString());
          // print('_usuario: ' + utf8.decode(_usuario));
          return _usuario
              .map((_usuario) => Usuario.fromJson(_usuario))
              .toList();
        }
        print('Response.body: ' + response.body);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}

class Usuario {
  factory Usuario.fromJson(Map<String, dynamic> json) {
    nome = json['NOME'];
    idcli = json['CODIGO'];
    return null;
  }
}
